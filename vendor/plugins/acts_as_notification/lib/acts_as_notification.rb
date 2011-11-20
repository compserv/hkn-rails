# ActsAsNotification

module Notifications

  class Notification
    attr_writer :image, :desc, :url, :obj

    def initialize(obj=nil, options={})
      @image = nil
      @desc  = nil
      @url   = nil
      @obj   = obj
    end

    def image
      @image.is_a?(Proc) ? @image.call(@obj) : @image
    end

    def desc
      @desc.is_a?(Proc) ? @desc.call(@obj) : @desc
    end

    def url
      @url.is_a?(Proc) ? @url.call(@obj) : @url
    end

    def to_json
      h = {}

      [:image, :desc, :url].each do |attr|
        h[attr] = self.send(attr)
      end

      return h
    end

  end

  class NotificationBuilder

    # @param klass [ActiveRecord::Base]
    # @param options [Hash]
    # @param block Configuration options
    def initialize(klass, options={}, &block)
      @klass = klass
      @prototype = @klass.notification

      self.instance_eval(&block)
    end

    # @param description [String,Symbol] Description of this {Notification},
    #   e.g. 'has been requested'
    def desc(desc="do something")
      #@config[:description] = desc
      @prototype.desc = desc
    end

    # @param url [String] URL
    def image(url=nil)
      #@config[:image] = url
      @prototype.image = url
    end

    # @param url [String] URL
    def url(url=nil)
      @prototype.url = url
    end

  end

  module ActsAsNotification
    extend ActiveSupport::Concern

    included do
    end

    # Instance methods


    def to_notification
      n = self.class.notification.dup
      n.obj = self
      return n

#      h = {}
#
#      h[:image] = self.class.notification[:image]
#      h[:description] = self.class.notification[:description]
#
#      return h
    end

    module ClassMethods

      # @param options [Hash]
      # @param block Configuration options
      # @see NotificationBuilder
      def acts_as_notification(options={}, &block)
        class_inheritable_accessor :notification
        self.notification = Notification.new
        NotificationBuilder.new(self, &block)
      end

    end

  end

end

ActiveRecord::Base.send :include, Notifications::ActsAsNotification
