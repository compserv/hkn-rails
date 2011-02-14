class Admin::VpController < Admin::AdminController
  before_filter :authorize_vp

  def eligibilities
    es = params[:semester].eql?('all') ? Eligibility.all.order(:last_name) : Eligibility.current.order(:last_name)
    @eligibilities = {}
    Eligibility::Groups.each {|g|@eligibilities[g] = []}

    es.each do |e|
      @eligibilities[Eligibility::Groups[e.group]] << e
    end
  end #eligibilities

  def reprocess_eligibilities
    Eligibility.current.unknowns.each do |e|
      g = e.group
      e.auto_assign_group
      e.save if e.group != g
    end
    redirect_to admin_eligibilities_path
  end

  def update_eligibilities
    params[:eligibilities].each_pair do |eid,g|
      eid, g = eid.to_i, g.to_i
      return redirect_to admin_eligibilities_path, :notice => "Missing eligibility ##{eid}" unless e = Eligibility.find(:first, :conditions=>{:id=>eid}, :select=>'"id","group"')

      next if e.group == g
      e.update_attribute :group, g
    end

    redirect_to admin_eligibilities_path, :notice => "Updated."
  end #update_eligibilities

  def upload_eligibilities
    if params[:file].nil?
      return redirect_to admin_eligibilities_path, :notice => "Please select a file to upload."
    end

    results = Eligibility::Importer.import(params[:file].tempfile)

    unless results[:errors].empty?
      return redirect_to admin_eligibilities_path, :notice => "There was #{results[:errors].length} #{'error'.pluralize_for results[:errors].length} parsing that file:\n#{results[:errors].join('
')}"   # wtf. it won't take '\n'.
    end

    redirect_to admin_eligibilities_path, :notice => "Successfully parsed #{results[:count]} eligibilities."
  end #upload_eligibilities

end # VpController
