class UserSession < Authlogic::Session::Base
  # configuration here, see documentation for sub modules of Authlogic::Session

  verify_password_method :valid_password?
  authenticate_with(Person)
end
