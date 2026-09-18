class EquipmentLoanRegistrar
  class Error < StandardError; end

  def initialize(employee)
    @employee = employee
  end

  def register(attrs)
    EquipmentLoan.create!(attrs.merge(employee: @employee))
  rescue ActiveRecord::RecordInvalid => e
    raise Error, e.message
  end
end
