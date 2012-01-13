require 'authlogic/test_case'
include Authlogic::TestCase
activate_authlogic

def admin_user(stubs = {})
  @current_user = mock_model(Person, stubs.merge({
    :admin? =>true}))
end

# TODO replace with Factory
def current_user(stubs = {})
  #@current_user ||= mock_model(Person, stubs)
  stubs = {
    :username => 'somebody',
    :password => 'password',
    :password_confirmation => 'password',
    :email => 'some@body.com',
    :first_name => 'Some',
    :last_name => 'Body',
    :approved => true
  }.merge(stubs)
  @current_user ||= Person.create!(stubs)
end

def user_session(stubs = {}, user_stubs = {})
  @user_session ||= mock_model('UserSessionFake', {:person => current_user(user_stubs)}.merge(stubs))
end

def login(session_stubs = {}, user_stubs = {})
  UserSession.stub!(:find).and_return(user_session(session_stubs, user_stubs))
end

def logout
  session.destroy if session = UserSession.find
  @user_session = nil
end

def login_as(user, auth={})
  controller.current_user = user
  user.stub(:in_group?) { |group| auth.include? group }
  user.stub(:groups) { auth.map{|k,v| v && stub_model(Group, :name => k)}.reject }
end

def login_as_officer(auth={})
	@current_user = stub_model(Person)
	login_as @current_user, auth.merge({'officers' => true, 'comms' => true})
end
