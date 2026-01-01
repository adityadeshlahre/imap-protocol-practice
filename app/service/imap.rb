require "net/imap"
class GmailImapService
  def initialize
    @email = Rails.application.credentials.dig(:gmail, :email)
    @password = Rails.application.credentials.dig(:gmail, :app_password)
  end

  def list_emails(limit: 5)
    imap = Net::IMAP.new("imap.gmail.com", 993, true)
    imap.login(@email, @password)
    imap.select("INBOX")

    ids = imap.search([ "ALL" ]).last(limit)

    ids.each do |id|
      envelope = imap.fetch(id, "ENVELOPE")[0].attr["ENVELOPE"]
      puts "ID: #{id}"
      puts "From: #{envelope.from[0].mailbox}@#{envelope.from[0].host}"
      puts "Subject: #{envelope.subject}"
      puts "Date: #{envelope.date}"
      puts "---------------------------"
    end

    imap.logout
    imap.disconnect
  end

  def delete_email(id)
    imap = Net::IMAP.new("imap.gmail.com", 993, true)
    imap.login(@email, @password)
    imap.select("INBOX")

    imap.store(id, "+FLAGS", [ :Deleted ])
    imap.expunge

    imap.logout
    imap.disconnect
  end
end
