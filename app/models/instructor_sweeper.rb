class InstructorSweeper < ActionController::Caching::Sweeper
  observe Instructor

  def after_update(instructor)
    expire_cache_for instructor
  end

  private
  def expire_cache_for(instructor)
    expire_fragment instructor_cache_path(instructor) 
  end
end
