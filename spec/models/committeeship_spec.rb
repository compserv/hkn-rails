require 'spec_helper'

describe Committeeship do
  before(:each) do
    @good_opts = {:committee => 'compserv',
      :semester => '20103',
      :title => 'officer'
    }
    end
  it "should accept valid parameters" do
    committeeship = Committeeship.create(@good_opts)
    committeeship.should be_valid
  end
  it "should require a valid semester" do
    committeeship = Committeeship.create(@good_opts.merge(:semester => '20105'))
    committeeship.should_not be_valid
  end
  it "should require a valid committee" do
    committeeship = Committeeship.create(@good_opts.merge(:committee => 'pubrel'))
    committeeship.should_not be_valid
  end
  it "should require a valid title" do
    committeeship = Committeeship.create(@good_opts.merge(:title => 'hoser'))
    committeeship.should_not be_valid
  end  
end
