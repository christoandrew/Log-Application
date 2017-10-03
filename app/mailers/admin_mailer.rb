class AdminMailer < ApplicationMailer

  def notify_email(subject,message)
    @mail_list = MailingList.all
    @message = message
    @mail_list.each do |mail|
      mail(to: mail.email, :subject => subject)
    end
  end
end
