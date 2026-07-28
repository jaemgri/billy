class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("GMAIL_ADDRESS", "billy@example.com")
  layout "mailer"
end
