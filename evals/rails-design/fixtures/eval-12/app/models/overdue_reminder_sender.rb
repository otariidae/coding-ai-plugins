class OverdueReminderSender
  TEMPLATES = %i[first_notice second_notice final_notice].freeze

  def initialize(organization)
    @organization = organization
    @failed_templates = []
  end

  def call
    @organization.invoices.overdue.find_each do |invoice|
      TEMPLATES.each do |template|
        next if already_sent?(invoice, template)

        begin
          Billing::Client.new.send_reminder(invoice_id: invoice.external_id, template: template)
          invoice.update!(reminder_email_sent: true)
        rescue
          @failed_templates << template
        end
      end
    end

    @failed_templates
  end

  private

  def already_sent?(invoice, template)
    template == :first_notice && invoice.reminder_email_sent?
  end

  def current_contact_email(invoice)
    invoice.organization.billing_contact.email
  rescue => e
    Rails.logger.warn("failed to resolve contact: #{e.message}")
    nil
  end
end
