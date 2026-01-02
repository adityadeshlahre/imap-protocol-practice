class MailController < ApplicationController
  def index
    begin
      @emails = GmailImapService.new.list_emails(limit: 10)
      flash[:notice] = "Successfully fetched #{@emails.count} emails" if @emails.any?
    rescue Net::IMAP::Error => e
      if e.message.include?("Authentication failed")
        flash[:alert] = "Gmail login failed. Check your app password."
      elsif e.message.include?("connection")
        flash[:alert] = "Cannot connect to Gmail. Check your internet."
      else
        flash[:alert] = "IMAP error: #{e.message}"
      end
      @emails = []
    rescue => e
      flash[:alert] = "Unexpected error: #{e.message}"
      @emails = []
    end
  end
end
