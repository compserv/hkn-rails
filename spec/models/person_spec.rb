require 'spec_helper'

describe Person, "when created with blank parameters" do
  before(:each) do
    @person = Person.create
  end

  it "should require a first name" do
    @person.should_not be_valid
    @person.errors[:first_name].should include("can't be blank")
  end

  it "should require a last name" do
    @person.should_not be_valid
    @person.errors[:last_name].should include("can't be blank")
  end

  it "should require an email of correct length" do
    @person.should_not be_valid
    #@person.errors[:email].should include("is too short (minimum is 6 characters)")
    @person.errors[:email].should include("should look like an email address.")
  end

  it "should require a username of correct length" do
    @person.should_not be_valid
    @person.errors[:username].should include("is too short (minimum is 2 characters)")
  end

  it "should require a password of correct length" do
    @person.should_not be_valid
    @person.errors[:password].should include("is too short (minimum is 8 characters)")
  end
end

describe Person do
  before(:each) do
    @good_opts = { :first_name => "Jim",
      :last_name => "Raynor",
      :email => "jraynor@battle.net",
      :username => "jraynor",
      :password => "zergkiller",
      :password_confirmation => "zergkiller"}
  end

  it "should accept valid parameters" do
    person = Person.create(@good_opts)
    person.should be_valid
  end

  it "should require a username to be at least 2 characters long" do
    person = Person.create(@good_opts.merge(:username => "a"))
    person.should_not be_valid
    person.errors[:username].should include("is too short (minimum is 2 characters)")
  end

  it "should require an email to be correctly formatted" do
    person = Person.create(@good_opts.merge(:email => "no_at_sign_and_no_domain"))
    person.should_not be_valid
    person.errors[:email].should include("should look like an email address.")
  end

  it "should require the password to be at least 8 characters long" do
    person = Person.create(@good_opts.merge(:password => "1234567"))
    person.should_not be_valid
    person.errors[:password].should include("is too short (minimum is 8 characters)")
  end

  it "should require the password and password_confirmation to match" do
    person = Person.create(@good_opts.merge(:password => "12345678", :password_confirmation => "12345679"))
    person.should_not be_valid
    person.errors[:password].should include("doesn't match confirmation")
  end

  it "should not allow two people to have the same username" do
    person1 = Person.create(@good_opts)
    person1.should be_valid
    person1.save
    person2 = Person.create(@good_opts)
    person2.should_not be_valid
    person2.errors[:username].should include("has already been taken")
  end

  it "should not allow two people to have the same email" do
    person1 = Person.create(@good_opts)
    person1.should be_valid
    person1.save
    person2 = Person.create(@good_opts)
    person2.should_not be_valid
    person2.errors[:email].should include("has already been taken")
  end
end

describe Person do
  context "phone number validation" do
    describe "#phone_number_is_valid?" do
      it "should be true for 10-digit phone numbers" do
        person = Person.new(:phone_number => "5555555555")
        person.phone_number_is_valid?.should be_true
      end

      it "should be true for 10-digit phone numbers ignoring extra characters" do
        person = Person.new(:phone_number => "(555) 555-5555")
        person.phone_number_is_valid?.should be_true
      end

      it "should be invalid for 9-digit phone numbers" do
        person = Person.new(:phone_number => "123456789")
        person.phone_number_is_valid?.should be_false
      end
    end

    describe "#phone_number_compact" do
      it "should return phone numbers without extra characters" do
        person = Person.new(:phone_number => "(555) 555-5555")
        person.phone_number_compact.should == "5555555555"
      end
    end

    describe "#sms_email_address" do
      it "should return sms email address" do
        person = Person.new(:phone_number => "(555) 555-5555")
        mc = mock_model(MobileCarrier)
        mc.should_receive(:sms_email).and_return("@example.com")
        person.mobile_carrier = mc
        person.sms_email_address.should == "5555555555@example.com"
      end
    end
  end
end
