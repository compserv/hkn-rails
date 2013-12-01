class Admin::BridgeController < Admin::AdminController
  # before_filter :authorize_bridge

  def index
  end

  def photo_upload
    @Officers = Committeeship.current.map(&:person).uniq
  end

  def photo_upload_post
    @Officers = Committeeship.current.officers.map(&:person)
    p = Person.find_by_id(params[:person][:id])    
    file_name = "public/pictures/#{p.username}.png"

    unless file = params[:file_info]
      flash[:notice] = "Please attach picture"
      render ("photo_upload")
      return
    end
    File.open(file_name,"wb") do |f|
      f.write(file.read)
    end
    p.picture = "/pictures/#{p.username}.png"
    p.save
    flash[:notice] = "Picture Uploaded"
    render ("photo_upload") 
  end
end
