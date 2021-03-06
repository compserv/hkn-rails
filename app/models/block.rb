# == Schema Information
#
# Table name: blocks
#
#  id         :integer          not null, primary key
#  rsvp_cap   :integer
#  start_time :datetime
#  end_time   :datetime
#  created_at :datetime
#  updated_at :datetime
#  event_id   :integer
#

class Block < ActiveRecord::Base
  # Nonpositive rsvp_cap implies no limit (since there's no reason to set an
  # rsvp_cap of 0, you might as well not have rsvps enabled)
  has_and_belongs_to_many :rsvps
  belongs_to :event

  validate :valid_time_range
  validates_presence_of :event, :start_time, :end_time

  default_scope -> { order('start_time') }

  def valid_time_range
    if !start_time.blank? and !end_time.blank?
      errors[:end_time] << "must be after start time" unless start_time < end_time
    end
  end

  def nice_time_range
    if start_time.to_date == end_time.to_date
      "#{start_time.strftime('%a %m/%d %I:%M%p')} - #{end_time.strftime('%I:%M%p')}"
    else
      "#{start_time.strftime('%a %m/%d %I:%M%p')} - #{end_time.strftime('%a %m/%d %I:%M%p')}"
    end
  end

  def full?
    # rsvp_cap < 1 implies no limit
    !rsvp_cap.nil? and (rsvp_cap < 1 or rsvps.count >= rsvp_cap)
  end
end
