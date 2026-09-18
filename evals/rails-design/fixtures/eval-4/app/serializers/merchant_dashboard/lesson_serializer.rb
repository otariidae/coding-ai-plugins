# frozen_string_literal: true

module MerchantDashboard
  class LessonSerializer < ActiveModel::Serializer
    attributes :id, :name, :description, :start_at, :capacity, :published

    attribute :instructor_name do
      object.instructor.name
    end

    attribute :reserved_count do
      object.reservations.size
    end
  end
end
