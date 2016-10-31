# == Schema Information
#
# Table name: properties
#
#  id                   :integer          not null, primary key
#  semester             :string(255)      default("20103")
#  created_at           :datetime
#  updated_at           :datetime
#  tutoring_enabled     :boolean          default(FALSE)
#  tutoring_message     :text             default("")
#  tutoring_start       :integer          default(11)
#  tutoring_end         :integer          default(16)
#  coursesurveys_active :boolean          default(FALSE), not null
#

require 'rails_helper'

describe Property do
  before(:each) do
    Property.destroy_all
    @good_opts = {
      tutoring_enabled: true,
      semester: 'fa10'
	  }
  end

  it "should require a valid semester" do
    prop = Property.get_or_create
    prop.semester = "fa100"
    prop.should_not be_valid
    prop.errors[:semester].should include("Not a valid semester.")
  end

  it "should know next/prev semesters" do
     #          old    new    opts
     { next: [ [20111, 20113, nil],
               [20113, 20121, nil],
               [20112, 20113, nil],
               [20111, 20112, { summer: true }]
             ],
       prev: [ [20121, 20113, nil],
               [20113, 20111, nil],
               [20112, 20111, nil],
               [20113, 20112, { summer: true }]
             ]
     }.each_pair do |dir, data|
       data.each do |old, new, opts|
         Property.send("#{dir}_semester", *[old.to_s, opts].compact).should == new.to_s
       end
     end # each_pair
  end # next/prev semesters
end
