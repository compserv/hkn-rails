require 'spec_helper'

describe Block, "when created with blank parameters" do
  before(:each) do
    @block = Block.create
  end

  it "should not require any fields to be valid" do
    @block.should be_valid
  end

  it "should" do
    
  end
end
