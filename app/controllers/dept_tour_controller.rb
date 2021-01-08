class DeptTourController < ApplicationController
  def signup
    if request.post?
      @errors = {}
      # Mandatory
      @errors[:email]              = "Invalid email address"            unless (params[:email] =~ Authlogic::Regex.email)
      @errors[:email_confirmation] = "Email confirmation did not match" unless params[:email] == params[:email_confirmation]
      @errors[:name]               = "Name must not be blank"           if params[:name].length == 0
      @errors[:recaptcha]          = "Captcha validation failed"        unless verify_recaptcha
      @errors[:date]               = "Invalid date or time specified. Must be in the future, when HKN is open (not during school breaks), and on the times listed above"   unless params[:date] && valid_date?(params[:date])
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
      end
    end
  end

  def success
  end

  private
    def valid_date?(date)
      dt = Time.parse(date)
      # Make sure to update this (along with the date/time restrictions in
      # datetimepicker.js.erb to match only times and dates that we want to
      # give tours)

      # Thursday (4) at 6pm, Saturday (6) at 10 am and Saturday at 12 pm
      if dt.thursday?
        return (dt.hour == (12 + 6) and dt > DateTime.now)
      end
      if dt.saturday?
        return ((dt.hour == 10 or dt.hour == 12) and dt > DateTime.now)
      end
      # return ((11..17).include?(dt.hour) and dt > DateTime.now)
    rescue ArgumentError
      # If this isn't something that can be parsed as a time, it's obviously invalid
      return false
    end
end
