require 'single_sign_on'

class DiscourseSsoController < ApplicationController

  before_filter :authorize, :only => [:sso]

  def sso
    begin
      sso = SingleSignOn.parse(request.query_string, secret)
    rescue
      redirect_to :root, :notice => "There was an issue with the SSO request."
      return
    end

    sso.email = @current_user.email

    # HKN email users should be registered using their @hkn address
    #
    # Unfortunately, this will cause account fragmentation if a user uses this
    # SSO endpoint before and after becoming a "comms" member
    if @current_user.in_group? "comms"
      sso.email = @current_user.username + "@hkn.eecs.berkeley.edu"
    end

    sso.name        = @current_user.full_name
    sso.username    = @current_user.username
    sso.external_id = @current_user.id
    sso.sso_secret  = secret

    redirect_to sso.to_url(Rails.configuration.discourse[:sso_url])
  end

  private

    def secret
      Rails.configuration.discourse[:sso_secret]
    end

end
