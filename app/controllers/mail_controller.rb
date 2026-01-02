class MailController < ApplicationController
  def index
    @emails = []

    begin
      service = GmailImapService.new
      output = capture_output { service.list_emails(limit: 10) }
      @emails = parse_email_output(output)
    rescue => e
      flash[:alert] = "Error fetching emails: #{e.message}"
    end
  end

  private

  def capture_output
    original_stdout = $stdout
    $stdout = StringIO.new
    yield
    $stdout.string
  ensure
    $stdout = original_stdout
  end

  def parse_email_output(output)
    emails = []
    current_email = {}

    output.each_line do |line|
      line = line.strip

      if line.match?(/^ID: \d+$/)
        if current_email.any?
          emails << current_email
          current_email = {}
        end
        current_email[:id] = line.split(": ").last
      elsif line.match?(/^From: /)
        current_email[:from] = line.split(": ").last
      elsif line.match?(/^Subject: /)
        current_email[:subject] = line.split(": ").last
      elsif line.match?(/^Date: /)
        current_email[:date] = line.split(": ").last
      end
    end

    emails << current_email if current_email.any?
    emails
  end
end
