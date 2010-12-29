class DeptTourMailer < ActionMailer::Base
  default :from => "deprel@hkn.eecs.berkeley.edu"
  
  def dept_tour_email(name, date, email_address, phone, comments)
	@name = name
	@date = date
	@email_address = email_address
	@phone = phone
	@comments = comments
	mail :to => 'conorh@hkn.eecs.berkeley.edu', :subject => "Department Tour Request on #{date}"
  end
end
