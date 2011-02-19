class AccountMailer < ActionMailer::Base
  def account_approval(person)
    @person = person
    mail(
      :from => "no-reply@hkn.eecs.berkeley.edu",
      :to => person.email,
      :subject => "[HKN] Account approved"
    )
  end
end
