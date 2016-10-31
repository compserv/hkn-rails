class NotificationsController < ApplicationController
  before_filter :authorize

  def index
    @notifications = []

    @notifications |= @current_user.requested_challenges.pending

    @notifications.sort_by(&:updated_at)
    @notifications.collect!(&:to_notification)

    respond_to do |format|
      format.html { render :index, layout: false }
      format.json { render json: @notifications.collect(&:to_json) }
    end
  end

end
