class IndrelMailer < ActionMailer::Base
  def infosession_registration(fields, hostname)
    @fields = fields
    mail(
      :from => "infosessions-registration@hkn.eecs.berkeley.edu",
      :to => "indrel@#{hostname}",
      :subject => "Infosession registration from #{fields['company_name']}"
    )
  end

  def resume_book_order(fields, hostname)
    @fields = fields
    mail(
      :from => "resume-book-order@hkn.eecs.berkeley.edu",
      :to => "indrel@#{hostname}",
      :subject => "Resume book order from #{fields['company_name']}"
    )
  end
end
