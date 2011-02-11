class DeptTourController < ApplicationController
  def signup
    if params[:authenticity_token]
      @errors = {}
      if not (params[:email] =~ Authlogic::Regex.email)
        @errors[:email] = "Invalid email address"
      end
      if params[:name].length == 0
        @errors[:name] = "Name must not be blank"
      end
      @errors[:recaptcha] = "Captcha validation failed" unless verify_recaptcha
      if @errors.empty?
        @messages << params[:date]
        date = params[:date][:month] + "/" + params[:date][:day] + "/" + params[:date][:year]
        mail = DeptTourMailer.dept_tour_email params[:name], date, params[:email],
          params[:phone], params[:comments]
        mail.deliver
        DeptTourRequest.create!({
          :name => params[:name],
          :date => date,
          :submitted => Time.now,
          :contact => params[:email],
          :phone => params[:phone],
          :comments => params[:comments],
        })
        redirect_to :success
      end
    end
  end

  def success
  end

end
