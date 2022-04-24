class Rack::Attack
    Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

    spammers = ENV['RACK_ATTACK_BLOCK_IPS'].try(:split, /,\s*/)
    if spammers.present?
        spammer_regexp = Regexp.union(spammers)
        Rack::Attack.blocklist('block spam ip') do |req|
            req.ip =~ spammer_regexp
        end
    end
    attack_ban_retries  = ENV['RACK_ATTACK_RETRY'].try(:to_i) || 1
    attack_ban_findtime = ENV['RACK_ATTACK_FIND_TIME'].try(:to_i) || 10
    attack_ban_bandtime = ENV['RACK_ATTACK_BAND_TIME'].try(:to_i) || 60
    if attack_ban_retries > 0
      Rack::Attack.blocklist('allow2ban login scrapers') do |req|
        Rack::Attack::Allow2Ban.filter(req.ip, maxretry: attack_ban_retries, findtime: attack_ban_findtime, bantime: attack_ban_bandtime) do
            req.path == '/'
        end
       end
    end
    ActiveSupport::Notifications.subscribe(/rack_attack/) do |name, start, finish, request_id, payload|
        req         = payload[:request]
        remote_ip   = req.env["HTTP_X_FORWARDED_FOR"].presence || req.env["REMOTE_ADDR"].presence
        url         = req.env["REQUEST_URI"].presence
        baned_time  = ENV['RACK_ATTACK_BAND_TIME'].try(:to_i)
        if %i[throttle blocklist].include?(req.env['rack.attack.match_type'])
            Rails.logger.info "[Rack::Attack][PostApp]" <<
                      " remote_ip: \"#{remote_ip}\"," <<
                      " banned time: #{baned_time} seconds"
        end
    end    
    Rack::Attack.blocklisted_responder = lambda do |env|
        [503, {}, ["Server Error\n"]]
    end
end
    