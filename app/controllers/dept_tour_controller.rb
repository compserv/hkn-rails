class DeptTourController < ApplicationController
  def signup
    if request.post?
      @errors = {}

      # Mandatory
      @errors[:email]              = "Invalid email address"            unless (params[:email] =~ Authlogic::Regex.email)
      @errors[:email_confirmation] = "Email confirmation did not match" unless params[:email] == params[:email_confirmation]
      @errors[:name]               = "Name must not be blank"           if params[:name].length == 0
      @errors[:recaptcha]          = "Captcha validation failed"        unless verify_recaptcha
      @errors[:date]               = "Invalid date or time specified"   unless params[:date]
      @errors[:phone]              = "Phone must not be blank"          if params[:phone].blank?

      # Optional
      params[:comments] ||= ''

      if @errors.empty?
        begin
          @messages << params[:date]
          date = "#{params[:date][:year]}-#{params[:date][:month]}-#{params[:date][:day]} #{params[:date][:hour]}:#{params[:date][:minute]}:#{params[:date][:second]}"

          mail = DeptTourMailer.dept_tour_email params[:name], date, params[:email], params[:phone], params[:comments]
          mail.deliver
          r = DeptTourRequest.new({
            :name      => params[:name],
            :date      => date,
            :submitted => Time.now,
            :contact   => params[:email],
            :phone     => params[:phone],
            :comments  => params[:comments],
          })
          unless r.save
            Rails.logger.warn "ERROR saving DeptTourRequest #{r.inspect}"
            raise
          end
          redirect_to dept_tour_success_path
        rescue => e
          flash[:notice] = "There was a problem submitting your request. Please try again, or email us directly if the problem persists."
        end
      end # @errors.empty?
    end # authenticity_token
  end

  def success
  end

end
