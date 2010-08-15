class DeptTourMailer < ActionMailer::Base
  default :from => "deprel@hkn.eecs.berkeley.edu"
  
  def dept_tour_email(name, email_address, phone, comments)
	@name = name
	@email_address = email_address
	@phone = phone
	@comments = comments
	mail :to => 'ibrahima@hkn.eecs.berkeley.edu', :subject => 'Department Tour Request',
      :from => email_address
  end
end
