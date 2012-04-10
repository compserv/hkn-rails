namespace :events do
  task :sms_notify => :environment do
    describe "Sends an SMS text message reminding people of events happening in 2 hours"
    now = Time.now
    now = Time.local(now.year, now.month, now.day, now.hour)
    start_time = now + 1.hour
    end_time = now + 2.hours
    events = Event.where('start_time >= ?', start_time).where('end_time < ?', end_time)
    events.each do |event|
      event.rsvp_notify_people!
    end
  end
end
