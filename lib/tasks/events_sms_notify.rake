namespace :events do
  task :sms_notify => :environment do
    describe "Sends an SMS text message reminding people of events happening in 2 hours"
    now = Time.now
    now = Time.local(now.year, now.month, now.day, now.hour)
    lower_bound = now + 1.hour
    upper_bound = now + 2.hours
    events = Event.where('start_time >= ?', lower_bound).where('start_time < ?', upper_bound)
    events.each do |event|
      event.rsvp_notify_people!
    end
  end
end
