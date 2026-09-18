module Admin
  class EquipmentLoanCancellationsController < ApplicationController
    def create
      @loan = EquipmentLoan.find(params[:equipment_loan_id])
      @loan.cancel_before_shipment!

      redirect_to admin_equipment_loan_path(@loan), notice: "キャンセルしました"
    end
  end
end
