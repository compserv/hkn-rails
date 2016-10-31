class CompanySession < Authlogic::Session::Base
  # configuration here, see documentation for sub modules of Authlogic::Session
  after_save :reset_persistence_token

  authenticate_with(Company)

  login_field :name

  # Rename single access token parameter to "access_key"
  params_key "access_key"
  single_access_allowed_request_types :any


  # Resets the token responsible for persisting sessions.
  #
  # Note: Since companies cannot "login" to create sessions, this is merely for
  # potential future capabilities where indrel would want to log out companies.
  def reset_persistence_token
    record.reset_persistence_token
  end
end
