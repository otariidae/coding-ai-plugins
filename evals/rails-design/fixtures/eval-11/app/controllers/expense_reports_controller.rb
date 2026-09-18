class ExpenseReportsController < ApplicationController
  before_action :set_expense_report, only: %i[show edit update approve reject]

  def index
    @expense_reports = ExpenseReport.all
  end

  def show
  end

  def new
    @expense_report = ExpenseReport.new
  end

  def create
    @expense_report = ExpenseReport.new(expense_report_params)
    if @expense_report.save
      redirect_to @expense_report, notice: "申請しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @expense_report.update(expense_report_params)
      redirect_to @expense_report
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def approve
    ActiveRecord::Base.transaction do
      @expense_report.update!(approved: true, approved_at: Time.current)
      @expense_report.employee.increment!(:approved_reports_count)

      if @expense_report.amount >= 100_000
        @expense_report.update!(requires_audit: true)
        AuditLog.create!(
          expense_report: @expense_report,
          kind: :high_amount_approval,
          recorded_at: Time.current
        )
      end

      ApprovalNotificationService.new(@expense_report).call
      AccountingExportJob.perform_later(@expense_report.id)
    end

    redirect_to @expense_report, notice: "承認しました"
  end

  def reject
    @expense_report.update(approved: false, rejected_at: Time.current)
    redirect_to @expense_report
  end

  private

  def set_expense_report
    @expense_report = ExpenseReport.find(params[:id])
  end

  def expense_report_params
    params.require(:expense_report).permit(:title, :amount, :spent_on)
  end
end
