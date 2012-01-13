#!/usr/bin/env ruby

# With Rails 3.1, they changed the JSON gem to multi_json. Since JSON doesn't
# have a uniform standard that everyone follows, different implementors may 
# choose to have different grammar rules. As far as I know, these are the 
# differences between multi_json and the previous JSON gem:
# * All keys of objects (equivalent to Ruby Hashes) must be strings that are 
#   surrounded by double quotes.
#   Previously, numbers and single-quoted strings were accepted

# Note: You MUST have the environment variable $RAILS_ENV set to 'production'
# if you want to load in the course surveys to the production server.
require File.expand_path('../../../config/environment', __FILE__)

def fix_format(str)
  # Since I don't want to implement a parser for a CFG, I'm really hoping that
  # we did not put any colons in the frequencies string
  inner = str[1...-1] # strip braces {}
  kv_pairs = inner.split(',')
  new_kv_pairs = kv_pairs.map do|x|
    k,v = x.split(':')
    k.strip!
    k = k[1...-1] if k =~ /^'.*'$/
    k = %Q["#{k}"] unless k =~ /^".*"$/
    "#{k}:#{v}"
  end
  new_frequencies = "{" + new_kv_pairs.join(',') + "}"
  unless ENV['SKIP_CHECK']
    #puts new_frequencies
    #p ActiveSupport::JSON.decode(new_frequencies)
    new_frequencies = ActiveSupport::JSON.encode(ActiveSupport::JSON.decode(new_frequencies))
  end
  return new_frequencies
end

# Okay, Rails is probably most of the overhead here, so my method isn't any faster
def fast_fix_format(s)
  # Okay, other one is too slow, try again.
  return nil if s.getbyte(1) == 34 # If the second character is a ", then assume it's properly encoded
  i = 0
  c = []
  f = false
  # Scan by character
  s.codepoints do |a|
    if a == 123 # If {, then copy { and insert a ". Assumes no space after {, which is true, I think
      c[i] = 123
      c[i+1] = 34
      i += 2
    elsif a == 58 # If :, then insert a " and then copy. Assumes no space before :
      c[i] = 34
      c[i+1] = 58
      i += 2
    elsif a == 32 # If space not after comma, then insert "
      if f
        c[i] = 34
        i += 1
        f = false
      end
    elsif a == 44 # If comma, then copy and set flag
      c[i] = 44
      i += 1
      f = true
    elsif a == 39
      # Do nothing if see single quote. Other cases should properly insert "
    else
      c[i] = a
      i += 1
    end
  end
  return c.pack('U*')
end

#puts fast_fix_format("{0: 1}")
#puts fast_fix_format("{'0': 1}")
#puts fast_fix_format("{\"0\": 1}")
#puts fast_fix_format("{0: 1, \"Omit\": 3}")
#puts fast_fix_format("{'0': 1, \"Omit\": 3}")
#puts fast_fix_format("{\"0\": 1, \"Omit\": 3}")
#puts fast_fix_format("{1: 0, 2: 0, 3: 1, 4: 0, 5: 7, 6: 13, 7: 8, 'Omit': 0, 'N/A': 0}")
#puts fast_fix_format("{\"6\":10,\"N/A\":0,\"Omit\":0,\"7\":5,\"1\":0,\"2\":0,\"3\":0,\"4\":4,\"5\":5}")

total = SurveyAnswer.count
update_frequency = (total/100).to_i
i = 0
SurveyAnswer.all.each do |sa|
  output = fix_format(sa.frequencies)
  #output = fast_fix_format(sa.frequencies)
  sa.update_attributes!(:frequencies => output) unless output.nil?
  i += 1
  if i % update_frequency == 0
    puts "%.2f%% complete" % (i*100.0/total)
  end
end
