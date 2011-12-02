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

    @search_opts ||= {}
    @search_opts = {
      'sort'           => params[:sort] || sort_variable,
      'sort_direction' => params[:sort_direction] || 'down'
    }.merge(@search_opts)

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
  var History = window.History;
  var container = $(document.body)

  if (container) {
    container.click( function(e) {
      var el = e.target
      if ($(el).is('.#{class_name} a')) {
        $('#spinner').show();
        if (History.enabled) {
          History.pushState(null, '', el.href);
        } else {
          $('#spinner').show();
          $.ajax({
            url: el.href,
            method: 'get',
            dataType: 'script',
            success: function(data) {
              $('#ajax-wrapper').html(data);
            }
          });
        }
        e.preventDefault();
      }
    })
  }
})

$(window).bind('statechange', function(){
  var History = window.History;
  if (History.enabled) {
    var rootUrl = History.getRootUrl();
    var state = History.getState();
    var url = state.url;
    var relativeUrl = url.replace(rootUrl, '');
    $('#spinner').show();
    $.ajax({
      url: url,
      method: 'get',
      //dataType: 'script',
      success: function(data) {
        var newContent = $(data).find('#ajax-wrapper');
        $('#ajax-wrapper').html(newContent);
      }
    });
  }
})"
  end

  def spinner
    raw '<div id="spinner"><img src="/images/site/spinner.gif" alt="Loading..."/></div>'
  end
end # ApplicationHelper


# Other general helpers
class String
  def pluralize_for(n=1)
    n==1 ? self : self.pluralize 
  end

  def is_int?
    !self.blank? && self.to_i.to_s.eql?(self)
  end
  
  def semi_escape
    m = { '<' => '&lt;',
          '>' => '&gt;',
          /^\"|\"$/ => '',
          '\\"' => '"'
        }
    s = self.dup
    m.each_pair {|old,new| s.gsub! old, new }
    s
  end

  def to_ul
    [self].to_ul
  end

  def titleize_with_dashes
    ActiveSupport::Inflector.titleize_with_dashes(self)
  end

end

module ActiveSupport
  module Inflector
    def titleize_with_dashes(word)
      # Because titleize kills the - in Sangiovanni-Vincentelli
      word.downcase.gsub(/\b('?[a-z])/) { $1.capitalize }
    end
  end
end

class Array
# This borks activerecord's average
  def avg
    return nil if self.empty?
    self.sum.to_f / self.count.to_f
  end

  def to_ul(tag='ul')
    # Converts a nested array to <ul>
    ["<#{tag}>",
     self.collect do |e| case
     when e.is_a?(Array):
       e.to_ul tag
     else
       "<li>#{e.inspect.semi_escape}</li>"
     end end.join,
     "</#{tag}>"
    ].join
  end

  def ordered_group_by  # until we upgrade to ruby 1.9 to get chunk...
    ary = []

    self.each do |e|
      k = yield e
      unless sub_ary = ary.assoc(k)
        sub_ary = [k, []]
        ary << sub_ary
      end
      sub_ary[1] << e
    end

    ary
  end
end

class Hash
  def -(keys)   # I can't believe this isn't in Ruby already
    keys = [keys] unless keys.is_a? Array
    self.reject {|k,v| keys.include? k}
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
      custom_key   = options.delete(:key)

      actions.each do |a|
        caches_action a, {:layout => false, :cache_path => Proc.new do |c|
            can_admin = c.current_user_can_admin?(groups)
            case when custom_key.present?
              can_admin ? custom_key.to_s+cache_suffix : custom_key
            else
              can_admin ? {:admin_tag => cache_suffix} : nil
            end #case
          end }.merge(options)
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
#if defined? Rails::Configuration::SSL && Rails::Configuration::SSL
#  module ActionDispatch
#    module Routing
#      class RouteSet
#        $__SECURE_DEFAULT_ = true    # C++ style ftw
#        def url_for_with_secure_default(options = {})
#          options[:secure] ||= true
#          url_for_without_secure_default(options) 
#        end
#
#        alias_method_chain :url_for, :secure_default unless $__SECURE_DEFAULT_ #defined? url_for_without_secure_default
#      end
#    end
#  end
#end
