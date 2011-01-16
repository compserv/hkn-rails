class BlocksController < ApplicationController
  def index
    @event = Event.with_permission(@current_user).find(params[:event_id])
  end
end
