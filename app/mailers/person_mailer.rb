class PersonMailer < ActionMailer::Base
  def send_sms(person, msg)
    mail(:from => "sms-alerts@hkn.eecs.berkeley.edu",
         :to => person.sms_email_address,
         :subject => "") do |format|
      format.text { render :text => msg}
    end
  end
end
