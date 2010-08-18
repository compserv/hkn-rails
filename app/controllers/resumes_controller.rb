class ResumesController < ApplicationController
  def show
    send_file Rails.root+"private/resumes/random.pdf", :type=>'application/pdf', :x_sendfile=>true
  end
end
