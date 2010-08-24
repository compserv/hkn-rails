class IndrelMailer < ActionMailer::Base
  def infosession_registration(fields, hostname)
    @fields = fields
    mail(
      :from => "infosessions-registration@hkn.eecs.berkeley.edu",
      :to => "indrel@#{hostname}",
      :subject => "Infosession registration from #{fields['company_name']}"
    )
  end
end
