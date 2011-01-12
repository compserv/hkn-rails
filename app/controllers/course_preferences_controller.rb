class CoursePreferencesController < ApplicationController

  def destroy
    if @course_preference = CoursePreference.find(params[:id])
      @course_preference.destroy
      respond_to do |format|
        format.html { redirect_to :back, :notice => "Course removed."}
        format.xml {head :ok }
      end
    end
  end

end
