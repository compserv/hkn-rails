class ConsoleController < ApplicationController
  include ConsoleHelper

  before_filter :authorize

  def open
  end

  def command

    # messages holds text for stdout
    # js holds arbitrary javascript to execute
    @resp = { :messages => [], :js => [] }

    begin
      c = Console::Command.new(self, params[:command])
      if response = c.run
        # Success
        @resp[:messages] << response.message if response.message
        @resp[:js]       << response.js      if response.js
      end
    rescue Console::Error
      @resp[:messages] << $!.message
    rescue
      @resp[:messages] << "< server error >"
      @resp[:messages] << $!.inspect if Rails.env == 'development'
      raise if Rails.env == 'development'
    end

    respond_to do |format|
      format.js
    end
  end

end
