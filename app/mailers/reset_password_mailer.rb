class ResetPasswordMailer < ActionMailer::Base
  def reset_password(person)
    @person = person
    mail(
      from: "no-reply@hkn.eecs.berkeley.edu",
      to: person.email,
      subject: "[HKN] Password reset"
    )
  end
end
