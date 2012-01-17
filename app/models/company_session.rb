class CompanySession < Authlogic::Session::Base
  # configuration here, see documentation for sub modules of Authlogic::Session

  authenticate_with(Company)

  login_field :name

  # Rename single access token parameter to "access_key"
  params_key "access_key"
  single_access_allowed_request_types :any
end
