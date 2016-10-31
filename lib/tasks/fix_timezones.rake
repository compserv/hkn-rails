namespace :time do
namespace :zones do

  def migrate_timezones(dest_tz)
    models = {
      Availability    => [:time],
      Block           => [:start_time, :end_time],
      DeptTourRequest => [:date, :submitted],
      Event           => [:start_time, :end_time],
      IndrelEvent     => [:time],
      ResumeBook      => [:cutoff_date],
      SlotChange      => [:date],
      Slot            => [:time],

      Announcement    => [],
      Coursesurvey    => [],
      Resume          => [],
      Rsvp            => []
    }

    # set time zone 'America/Los_Angeles';
    # update events set start_time=(start_time + time '8:00' ) where id='1';

    offset = (dest_tz == :pst ? 8.hours : -8.hours)

    ActiveRecord::Base.transaction do
      models.each_pair do |c, cols|
        c.find(:all, readonly: false).each do |m|   # why readonly? no idea. that's just the way it is. Event has issues.
          puts "Updating #{c.to_s} #{m.id}"
          m.update_attributes cols.zip((cols+[:created_at,:updated_at]).collect {|col| m.send(col)+offset})
        end
      end

      Availability.all.each do |a|
        a.update_attribute(:time, Availability.time_for_weekday_and_hour(a.time.wday, a.time.hour)  )#Time.local(1,1,a.time.wday,a.time.hour,0))
      end
    end #transaction

    puts "\nMigrated to #{dest_tz.to_s.upcase!}\n"
    puts "Availabilities might not be showing up. If they're not, check for an off-by-8-hour error, and fix in console manually."
  end # migrate_timezones

  desc "Migrates from UTC => PST"
  task :utc_to_pst do
    migrate_timezones(:pst)
  end # utc_to_pst

  desc "Migrates from PST => UTC"
  task :pst_to_utc do
    migrate_timezones(:utc)
  end

end # zones
end # time
