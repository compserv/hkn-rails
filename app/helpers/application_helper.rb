module ApplicationHelper
  # http://unixmonkey.net/?p=20
  # HTML encodes ASCII chars a-z, useful for obfuscating
  # an email address from spiders and spammers
  def html_obfuscate(string)
    output_array = []
    lower = %w(a b c d e f g h i j k l m n o p q r s t u v w x y z)
    upper = %w(A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)
    char_array = string.split('')
    char_array.each do |char|  
      output = lower.index(char) + 97 if lower.include?(char)
      output = upper.index(char) + 65 if upper.include?(char)
      if output
        output_array << "&##{output};"
      else 
        output_array << char
      end
    end
    return output_array.join
  end

  # This is for the pagination sort links
  # This could probably be cleaned up a bit more...
  def sort_link(inner_text, sort_variable, opts = {})
    sort_direction = 'up'
    if sort_variable == @search_opts['sort'] and @search_opts['sort_direction'] != 'down'
      sort_direction = 'down'
    end
    arrow = (sort_variable == @search_opts['sort']) ? (@search_opts['sort_direction'] == 'down') ? image_tag('site/arrow_desc.gif') : image_tag('site/arrow_asc.gif') : ''
    link_to(inner_text, @search_opts.merge('sort' => sort_variable, 'sort_direction' => sort_direction).merge(opts)) + arrow
  end

  # http://wiki.github.com/mislav/will_paginate/ajax-pagination
  # http://brandonaaron.net/blog/2009/02/24/jquery-rails-and-ajax
  # Embedding this in a view will automatically make links which are descendants
  # of an element with the class 'class_name' into AJAX links
  # Note: You need to have an element with the id "spinner" for for spinner
  # graphic. If you don't, then the script will error out and won't perform an
  # AJAX request.
  def ajaxify_links(class_name='ajax-controls')
    javascript_tag \
"$(document).ready( function() {
  var container = $(document.body)

  if (container) {
    container.click( function(e) {
      var el = e.target
      if ($(el).is('.#{class_name} a')) {
        $('#spinner').show();
        $.ajax({ 
          url: el.href, 
          method: 'get', 
          dataType: 'script', 
          success: function(data) {
            $('#ajax-wrapper').html(data);
          } 
        });
        e.preventDefault();
      }
    })
  }
})"
  end

  def spinner
    raw '<div id="spinner"><img src="/images/site/spinner.gif" alt="Loading..."/></div>'
  end
end


# Other general helpers
class String
  def pluralize_for(n=1)
    n==1 ? self : self.pluralize 
  end
end

# Used as a quick and dirty hack when solr isn't running
class FakeSearch
  attr_accessor :results
end

module ActionController
  module Helpers
    # Removes unwanted params from your GET request.
    # Arguments:
    #  params: array of params you want to remove. default: [:utf8]
    # Returns:
    #  true if redirected (in controller, say 'return if strip_params')
    #
    # Note: this is a HACK.
    #
    def strip_params(params=[:utf8])
      retval = false
      params.each do |p|
        p = p.to_s
        if request.url =~ /#{p}=/i
          new_url = request.url.gsub(/&?#{p}=[^&]*&?/i, '')
          redirect_to new_url
          retval = true
        end
      end
      return retval
    end

    # Removes the badness from a query, by allowing only common chars.
    # For example, you could break a query by searching for ".
    #
    def sanitize_query(q)
      return '' if q.nil?
      q.gsub(/\s+/, ' ').gsub(/[^a-zA-Z 0-9\*\?\"]/i, '?')
    end

    # Returns true if the user is logged in and authorized for the
    # specified groups (superusers always have permission).
    def current_user_can_admin?(groups=[])
      groups ||= []
      @current_user && (%w(superusers) | groups).any?{|g| @auth[g]}
    end

    module ClassMethods

    # This method will automagically cache admin and non-admin versions
    # of the actions specified, as determined by current_user_can_admin?.
    #
    # This should be used for actions that render significantly differently
    # for admins than for the general public.
    #
    # Options:
    #  cache_suffix: Cache tag suffix for admin pages [default '_admin']
    #  groups      : Array of group names to pass to current_user_can_admin?
    #  layout      : default false
    #  other params: passed directly to caches_action
    #
    def caches_action_for_admins(actions=[], options={})
      actions      = [actions] unless actions.is_a? Array
      cache_suffix = options.delete(:cache_suffix) || '_admin'
      groups       = options.delete(:groups) || []

      actions.each do |a|
        caches_action a, {:layout => false, :cache_path => Proc.new {|c| {:admin_tag => cache_suffix} if c.current_user_can_admin?(groups)}}.merge(options)
      end
    end
    end # ClassMethods
    
  end #Helpers
end #ApplicationController

module ActionView
  module Helpers
    def captcha
      recaptcha_tags :ssl=>true, :display=>{:theme=>'clean'}
    end
  end # Helpers
end # ActionView

# SSL links by default
module ActionDispatch
  module Routing
    class RouteSet
      def url_for_with_secure_default(options = {})
        options[:secure] ||= true
        url_for_without_secure_default(options) 
      end

      alias_method_chain :url_for, :secure_default unless defined? url_for_without_secure_default
    end
  end
end
