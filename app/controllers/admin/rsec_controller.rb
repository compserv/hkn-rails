class Admin::RsecController < Admin::AdminController
  before_filter :authorize_rsec, :only => [:find_members, :add_elected]

  def elections
    #@groups is a list of hashes in the form of {:name => "pres", :positions => [@Person, @Person]}
    grouped_elections = Election.current_semester.group_by(&:position)
    @groups = Group.committees.collect do |g|
        {:name => g.name, :positions => (grouped_elections[g.name] || [])}
    end
  end

  def find_members
    render :json => Group.find_by_name("candplus").people.map {|c| {:name => c.full_name, :id => c.id } }
  end

  # POST add_elected/:id/:position
  # Registers the Person with the specified ID as being elected
  # for the POSITION.
  #
  def add_elected
    e = Election.new(:person_id => params[:person_id].to_i, :position => params[:position])
    unless e.save
      return redirect_to admin_rsec_elections_path, :notice => "Failed to elect: #{e.person} because #{e.errors.inspect}"
    end
    redirect_to admin_rsec_elections_path
  end # add_elected

  # POST unelect [:election_id]
  #
  def unelect
    e = Election.find(params[:election_id])
    msg = "Successfully un-elected #{e.person.full_name} from #{e.position}"
    if e then
        e.destroy || msg = "Failed to un-elect #{e.person.full_name}..."
    end
    redirect_to admin_rsec_elections_path, :notice => msg
  end

end # Admin::RsecController

