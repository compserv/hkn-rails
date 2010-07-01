require 'spec_helper'

describe Committeeship do
  before(:each) do
    @good_opts = {:committee => 'compserv',
      :semester => 'fa10',
      :title => 'officer'
    }
    end
  it "should accept valid parameters" do
    committeeship = Committeeship.create(@good_opts)
    committeeship.should be_valid
  end
  it "should require a valid semester" do
    committeeship = Committeeship.create(@good_opts.merge(:semester=>'fa100'))
    committeeship.should_not be_valid
  end
end
