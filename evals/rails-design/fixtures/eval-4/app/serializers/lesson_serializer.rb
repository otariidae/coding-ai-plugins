# frozen_string_literal: true

class LessonSerializer < ActiveModel::Serializer
  attributes :id, :name, :description, :start_at, :capacity

  attribute :instructor_name do
    object.instructor.name
  end

  attribute :remaining_seats do
    object.capacity - object.reservations.size
  end
end
