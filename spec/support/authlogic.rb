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
  allow(UserSession).to receive(:find) { user_session(session_stubs, user_stubs) }
end

def logout
  session.destroy if session = UserSession.find
  @user_session = nil
end

def unlogin
  allow(UserSession).to receive(:find).and_call_original
  @user_session = nil
end

def login_as(user, auth={})
  controller.current_user = user
  @current_user = user
  # user.stub(:in_group?) { |group| auth.include? group }
  allow(user).to receive(:in_group?) { |group| auth.include? group }

  # user.stub(:groups) { auth.map{|k,v| v && stub_model(Group, :name => k.to_s)}.reject }
  allow(user).to receive(:groups) { auth.map{|k,v| v && stub_model(Group, :name => k.to_s)}.reject }
end

def login_as_officer(auth={})
  login_as stub_model(Person), auth.merge({'officers' => true, 'comms' => true})
end
