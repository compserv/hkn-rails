Sunspot.config.pagination.default_per_page = 50

# Fake out sunspot if the server isn't running.
# Otherwise, model save/destroy will throw an error.
$SUNSPOT_ENABLED = false
unless RAILS_ENV.eql?('production')
  begin
    File.file?(pidfile=Sunspot::Rails::Server.new.pid_path)
    pid=IO.read(pidfile).to_i
    Process.kill(0,pid) # check if running (doesn't actually kill)
    # must be running...
    $SUNSPOT_ENABLED = true
  rescue Exception # not running
    # puts "Note: Sunspot server isn't running. Search may be crippled, and your indices may be incomplete if you create or destroy any ActiveRecord::Bases." unless RAILS_ENV.eql?('test')
    Sunspot.session = Sunspot::Rails::StubSessionProxy.new(Sunspot.session)
  end
end
