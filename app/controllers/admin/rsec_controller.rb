class Admin::RsecController < Admin::AdminController

  def elections
    #@groups is a list of hashes in the form of {:name => "pres", :positions => [@Person, @Person]}
    @groups = [{:name=>"pres", :positions=>[nil]}]
  end

  def find_members
    render :json => Group.find_by_name("candplus").people.map {|c| {:name => c.full_name, :id => c.id } }
  end

  def submit_info 
  end

  # POST add_elected/:id/:position
  # Registers the Person with the specified ID as being elected
  # for the POSITION.
  #
  def add_elected
    unless Election.create(:person_id => params[:id], :position => params[:position])
      # TODO: error
    end
  end # add_elected

end # Admin::RsecController

