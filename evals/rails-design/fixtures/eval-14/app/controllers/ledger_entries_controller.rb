class LedgerEntriesController < ApplicationController
  before_action :set_fiscal_year

  def index
    @entries = LedgerEntry.for_current_fiscal_year.order(posted_at: :desc)
  end

  def new
    @entry = LedgerEntry.new
  end

  def create
    @entry = LedgerEntry.new(entry_params)

    if @entry.save
      @entry.post!
      RecalculateLedgerJob.perform_later(@entry.account_id)
      redirect_to @entry, notice: "登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_fiscal_year
    Current.fiscal_year = params[:fiscal_year].presence || FiscalYear.current.year
  end

  def entry_params
    params.expect(ledger_entry: %i[account_id amount memo])
  end
end
