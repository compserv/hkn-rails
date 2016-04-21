class Resource < ActiveRecord::Base

  # === List of columns ===
  #   id          : integer 
  #   klass_id    : integer 
  #   course_id   : integer 
  #   topic       : string 
  #   type        : integer 
  #   description : string 
  #   linkfilename: string 
  #   created_at  : datetime 
  #   updated_at  : datetime 
  # =======================

  #TODO add tags
  belongs_to :klass
  belongs_to :course
  
  validates :klass, :presence => true
  validates :course, :presence => true
  validates :linkfilename, :presence => true
  validates :type, :presence => true

  @@TYPE_NAMES = { 0 => 'link', 1 => 'pdf'}
  #@@TYPE_NUMS = {'link' => 0, 'pdf' => 1}

  #Returns the name of the exam type
  def type_name
    @@TYPE_NAMES[type]
  end

  def file_type
    filename.split('.').last
  end

end
