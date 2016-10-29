class Admin::ElectionsController < ApplicationController

  before_filter :authorize_rsec_or_username, :except => [:details]
  before_filter :authorize_candplus, :only => [:details]

    ELECTION_DETAILS = {
      :person   => [ #:username,        # this isn't working atm
                    :phone_number,
                    :aim,
                    :email,
                    :local_address,
                    :date_of_birth ],
      :election => [:non_hkn_email,
                    :desired_username,
                    :txt,
                    :sid,
                    :keycard,
                    :midnight_meeting ]
    }

  def details
    @elections = Election.current_semester.ordered.all.ordered_group_by(&:position)
  end

  def edit_details
    # @user is set by authorize_rsec_or_username
    return redirect_to admin_election_details_path, :notice => "invalid username #{params[:username]}" unless @user

    @election = @user.current_election
    return redirect_to admin_election_details_path, :notice => "#{@user.full_name} has not been elected this semester" unless @election

    @details = ELECTION_DETAILS

    Election.find_or_create_by(person_id: @user.id, semester: Property.current_semester)
  end

  def update_details
    obj, pheedback = nil, []
    user = Person.find_by_username(params[:username]) || Person.find(params[:username])
    redirect_to admin_election_details_path, :notice => "Segfault!" unless user
    if params[:election].present? then
        pheedback << "Post-election info"
        pheedback << (obj=user.current_election).update_attributes(params[:election])
    elsif params[:person].present? then
        obj = Person.find_by_username(params[:username]) || Person.find_by_id(params[:username])

        # Need to reset crypted password if username changed
        unless params[:person][:username] == obj.username
            obj.change_username :username => params[:person][:username], :password => params[:person][:password]
        end
        params[:person].delete :password
        params[:person].delete :username

        pheedback << "User profile"
        pheedback << obj.valid? && obj.update_attributes(params[:person])
    else
        # wat happened?
        redirect_to admin_election_details_path, :notice => "Segfault!"
    end

    pheedback.push({true=>"updated successfully.", false=>"failed because #{obj.errors.to_a.to_ul}"}[pheedback.pop])
    pheedback = pheedback * ' '

    redirect_to admin_election_edit_details_path, :notice => pheedback
  end

private
  def authorize_rsec_or_username
      @user = Person.find_by_username(params[:username]) || Person.find_by_id(params[:username])
      @user = nil unless (@current_user && @current_user.id == @user.id) || @auth['rsec']
      return redirect_to admin_election_details_path, :notice => "Access violation!" unless @user
  end

end
