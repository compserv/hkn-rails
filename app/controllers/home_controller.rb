class HomeController < ApplicationController
  helper EventsHelper
  require 'flickraw'
  def index
    @events = Event.upcoming_events(0, @current_user)
    @show_searcharea = true
    prop = Property.get_or_create
    @tutoring_enabled = prop.tutoring_enabled
    @hours = prop.tutoring_start .. prop.tutoring_end
    time = Time.now
    time = time.tomorrow if time.hour > prop.tutoring_end
    time = time.next_week unless (1..5).include? time.wday
    @day = time.wday
    @tutor_title = "#{time.strftime("%A")}'s Tutoring Schedule"
    if @tutoring_enabled
      @course_mapping = {}
      @slots = Slot.includes(:tutors).where(:wday => time.wday)
    else
      @tutoring_message = prop.tutoring_message
    end
  
    FlickRaw.api_key="bb6eccbf731a58f02b4acacfcb36e85d"
    FlickRaw.shared_secret="aa8d976469254029"
    default_photos = [ActionController::Base.helpers.asset_path('site/hkn_members.png'), ActionController::Base.helpers.asset_path('site/hkn_tutoring.png'), ActionController::Base.helpers.asset_path('site/hkn_faculty.png'), ActionController::Base.helpers.asset_path('site/hkn_banquet.png')]
    @photo_links = []
    photo_indices = []
    for i in 0..3
      photo_index = rand(1000)
      while photo_indices.include? photo_index
        photo_index = rand(1000)
      end
      photo = flickr.people.getPublicPhotos(:user_id => '121225723@N05', :per_page => '1', :page => photo_index.to_s)
      break if photo.nil?
      photo_id = photo[0].id
      sizes = flickr.photos.getSizes(:photo_id => photo_id)
      link = sizes[5].source
      photo_indices << photo_index
      @photo_links << link
    end
    if @photo_links.length < 4
      @photo_links = default_photos
    end
  end

  def factorial
    x = params[:x].to_i
    y = case
    when x < 0
      'u dumb'
    when x > 9000
      redirect_to "http://www.youtube.com/watch?v=SiMHTK15Pik"
      return
    else
      y = x.downto(1).inject(:*)
    end
    redirect_to :root, :notice => y
  end

end
