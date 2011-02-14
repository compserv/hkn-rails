class Admin::EligibilitiesController < Admin::AdminController
  before_filter :authorize_vp

  def list
    es = params[:semester].eql?('all') ? Eligibility.order(:last_name) : Eligibility.current.order(:last_name)
    @eligibilities = {}
    Eligibility::Groups.each {|g|@eligibilities[g] = []}

    es.each do |e|
      @eligibilities[Eligibility::Groups[e.group]] << e
    end
  end #eligibilities

  def reprocess
    case
    when params[:reprocess].present?
      Eligibility.current.unknowns.each do |e|
        g = e.group
        e.auto_assign_group
        e.save if e.group != g
      end
    when params[:clear_all].present?
      Eligibility.current.destroy_all
    end
    redirect_to admin_eligibilities_path
  end

  def update
    return redirect_to admin_eligibilities_path, :notice => "No eligibilities found." if params[:eligibilities].blank?

    params[:eligibilities].each_pair do |eid,g|
      eid, g = eid.to_i, g.to_i
      return redirect_to admin_eligibilities_path, :notice => "Missing eligibility ##{eid}" unless e = Eligibility.find_by_id(eid)

      next if e.group == g
      c = g==Eligibility::GroupValues[:unknown] ? 0 : 3
      e.update_attributes :group=>g, :confidence=>c
    end

    redirect_to admin_eligibilities_path, :notice => "Updated."
  end #update_eligibilities

  def upload
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

end # controller
