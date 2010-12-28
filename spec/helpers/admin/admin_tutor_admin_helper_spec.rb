require 'spec_helper'

# Specs in this file have access to a helper object that includes
# the Admin::TutorAdminHelper. For example:
# 
# describe Admin::TutorAdminHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       helper.concat_strings("this","that").should == "this that"
#     end
#   end
# end
describe Admin::TutorAdminHelper do 
  describe "format slot" do
	it "should format a slot properly" do
	  helper.formatslot('Thursday', '11').should == 'Thu11'
	end
  end
end
