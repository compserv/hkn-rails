require 'spec_helper'

describe Resume, "when created with blank parameters" do
  before(:each) do
    @resume = Resume.create
  end

  it "should have a file" do
    @resume.should_not be_valid
    @resume.errors[:file].should include("can't be blank")
  end

  it "should have an overall GPA" do
    @resume.should_not be_valid
    @resume.errors[:overall_gpa].should include("can't be blank")
  end

  it "should have a graduation year and semester" do
    @resume.should_not be_valid
    @resume.errors[:graduation_semester].should include("can't be blank")
    @resume.errors[:graduation_year].should include("can't be blank")
  end 
end

describe Resume do
  before(:each) do
    @good_params = {:overall_gpa => 4.0,
                    :major_gpa => 4.0,
                    :resume_text => "The resume of Genius McGenius",
                    :graduation_year => 2016,
                    :graduation_semester => "Spring",
                    :file => "private/resumes/geniusmcgenius.pdf",
                    :person => mock_model(Person)
    }
  end

  it "should accept valid parameters" do
    resume = Resume.create(@good_params)
    resume.should be_valid
  end

  it "should reject invalid GPAs" do
    resume = Resume.create(@good_params)
    resume.update_attribute(:overall_gpa, 5.0)
    resume.should_not be_valid
    resume.errors[:overall_gpa].
      should include("must be less than or equal to 4.0")
    
    resume = Resume.create(@good_params)
    resume.update_attribute(:major_gpa, 5.0)
    resume.should_not be_valid
    resume.errors[:major_gpa].
      should include("must be less than or equal to 4.0")

    resume = Resume.create(@good_params)
    resume.update_attribute(:overall_gpa, -1.0)
    resume.should_not be_valid
    resume.errors[:overall_gpa].
      should include("must be greater than or equal to 0.0")

    resume = Resume.create(@good_params)
    resume.update_attribute(:major_gpa, -1.0)
    resume.should_not be_valid
    resume.errors[:major_gpa].
      should include("must be greater than or equal to 0.0")
  end

  it "should reject non numeric graduation years" do
    resume = Resume.create(@good_params)
    resume.update_attribute(:graduation_year, "Nineteen Eighty-Four")
    resume.should_not be_valid
    resume.errors[:graduation_year].
      should include("is not a number")
  end

  it "should reject non integer graduation years" do
    resume = Resume.create(@good_params)
    resume.update_attribute(:graduation_year, 2012 + Math::PI)
    resume.should_not be_valid
    resume.errors[:graduation_year].
      should include("is not a number")
  end
end
