# frozen_string_literal: true

module Api
  class LessonsController < Api::ApplicationController
    before_action :set_lesson, only: %i[show update]

    def index
      lessons = current_studio.lessons.published.includes(:instructor, :reservations)

      render json: lessons, each_serializer: LessonSerializer
    end

    def show
      render json: {
        id: @lesson.id,
        name: @lesson.name,
        description: @lesson.description,
        start_at: @lesson.start_at,
        capacity: @lesson.capacity,
        instructor_name: @lesson.instructor.name,
        remaining_seats: @lesson.capacity - @lesson.reservations.size,
        cancel_policy: @lesson.cancel_policy,
      }
    end

    def create
      lesson = current_studio.lessons.create!(lesson_params)

      render json: lesson, serializer: MerchantDashboard::LessonSerializer, status: :created
    end

    def update
      @lesson.update!(lesson_params)

      render json: @lesson, serializer: MerchantDashboard::LessonSerializer
    end

    private

    def set_lesson
      @lesson = current_studio.lessons.find(params[:id])
    end

    def lesson_params
      params.expect(lesson: [:name, :description, :start_at, :capacity])
    end
  end
end
