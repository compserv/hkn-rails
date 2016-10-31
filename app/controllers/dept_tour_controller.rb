class DeptTourController < ApplicationController
  def signup
    if request.post?
      @errors = {}
      # Mandatory
      @errors[:email]              = "Invalid email address"            unless (params[:email] =~ Authlogic::Regex.email)
      @errors[:email_confirmation] = "Email confirmation did not match" unless params[:email] == params[:email_confirmation]
      @errors[:name]               = "Name must not be blank"           if params[:name].length == 0
      @errors[:recaptcha]          = "Captcha validation failed"        unless verify_recaptcha
      @errors[:date]               = "Invalid date or time specified. Must be in the future, and between 10 (10am) and 18 (6pm)"   unless params[:date] && valid_date?(params[:date])
      @errors[:phone]              = "Phone must not be blank"          if params[:phone].blank?

      # Optional
      params[:comments] ||= ''

      if @errors.empty?
        begin
          @messages << params[:date]
          date = "#{params[:date]}"

          mail = DeptTourMailer.dept_tour_email params[:name], date, params[:email], params[:phone], params[:comments]
          mail.deliver
          r = DeptTourRequest.new({
            name:      params[:name],
            date:      date,
            submitted: Time.now,
            contact:   params[:email],
            phone:     params[:phone],
            comments:  params[:comments],
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

  private
  def valid_date?(date)
    dt = Time.parse(date)
    return (10..17).include?(dt.hour) && dt > Time.now
  end

end
