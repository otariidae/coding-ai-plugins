class Employee < ApplicationRecord
  belongs_to :department
  has_many :attendances, dependent: :destroy
  has_many :leave_requests, dependent: :destroy

  validates :employee_code, presence: true, uniqueness: true
  validates :last_name, :first_name, presence: true

  scope :active, -> { where(retired: false) }

  def full_name
    "#{last_name} #{first_name}"
  end
end
