class Admin::VpController < Admin::AdminController
  before_filter :authorize_vp

  def eligibilities
    es = params[:semester].eql?('all') ? Eligibility.all : Eligibility.current
    @eligibilities = {}
    Eligibility::Groups.each {|g|@eligibilities[g] = []}

    es.each do |e|
      @eligibilities[Eligibility::Groups[e.group]] << e
    end

  end #eligibilities

  def update_eligibilities
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
