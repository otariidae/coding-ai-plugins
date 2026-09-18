class EquipmentLoanForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :equipment_id, :integer
  attribute :due_on, :date

  validates :equipment_id, presence: true

  def initialize(employee, attrs = {})
    @employee = employee
    super(attrs)
  end

  def save
    return false unless valid?

    EquipmentLoanRegistrar.new(@employee).register(equipment_id: equipment_id, due_on: due_on)
    true
  rescue EquipmentLoanRegistrar::Error => e
    errors.add(:base, e.message)
    false
  end
end
