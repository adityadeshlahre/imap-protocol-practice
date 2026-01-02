class MailController < ApplicationController
  def index
    begin
      @emails = GmailImapService.new.list_emails(limit: 10)
    rescue => e
      flash[:alert] = "Error fetching emails: #{e.message}"
      @emails = []
    end
  end
end
