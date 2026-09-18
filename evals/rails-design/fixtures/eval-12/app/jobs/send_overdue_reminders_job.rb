class SendOverdueRemindersJob < ApplicationJob
  queue_as :default

  def perform(organization_id)
    organization = Organization.find(organization_id)
    failed = OverdueReminderSender.new(organization).call

    if failed.any?
      Rails.logger.warn("some reminders failed: #{failed.join(',')}")
    end
  end
end
