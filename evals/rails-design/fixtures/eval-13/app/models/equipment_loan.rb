class EquipmentLoan < ApplicationRecord
  belongs_to :employee
  belongs_to :equipment

  enum :status, { draft: 0, requested: 1, shipped: 2, returned: 3, cancelled: 4 }, default: :draft

  validates :due_on, presence: true

  def request!
    raise "下書き以外からは申請できません" unless draft?
    raise "貸出期限が未設定です" if due_on.blank?
    raise "この備品は貸出停止中です" if equipment.suspended?
    raise "同じ備品をすでに借りています" if employee.equipment_loans.where(equipment_id: equipment_id).shipped.exists?

    update!(status: :requested, requested_at: Time.current)
  end

  def cancel_before_shipment!
    raise "すでに発送済みのためキャンセルできません" if shipped?
    raise "返却済みの貸出はキャンセルできません" if returned?
    raise "すでにキャンセルされています" if cancelled?
    raise "申請前の貸出はキャンセルではなく削除してください" if draft?

    update!(status: :cancelled, cancelled_at: Time.current)
  end
end
