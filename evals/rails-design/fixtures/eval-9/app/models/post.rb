class Post < ApplicationRecord
  include Searchable

  belongs_to :user
  has_many :comments, dependent: :destroy
  has_and_belongs_to_many :tags

  validates :title, presence: true

  scope :visible, -> { where(deleted: false, archived: false) }

  def publish!
    update!(published: true, published_at: Time.current)
  end
end
