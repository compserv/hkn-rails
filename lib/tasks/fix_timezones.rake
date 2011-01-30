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
        c.all.each do |m|
          puts "Updating #{c.to_s} #{m.id}"
          m.update_attributes cols.zip((cols+[:created_at,:updated_at]).collect {|col| m.send(col)+offset})
        end
      end
    end #transaction

    puts "\nMigrated to #{dest_tz.to_s.upcase!}\n"
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
