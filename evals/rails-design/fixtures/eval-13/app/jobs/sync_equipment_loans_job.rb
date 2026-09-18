class SyncEquipmentLoansJob < ApplicationJob
  queue_as :default

  def perform(office_id)
    office = Office.find(office_id)

    office.equipment_loans.requested.find_each do |loan|
      begin
        result = Inventory::ConsoleClient.new.reserve_equipment(loan.equipment.code, loan.employee.code)
        loan.update!(external_code: result["code"])
      rescue Inventory::ConsoleClient::FetchError => e
        raise "備品の同期に失敗しました: #{e.message}"
      end
    end

    office.touch(:synced_at)
  rescue ActiveRecord::RecordNotFound => e
    raise e
  end
end
