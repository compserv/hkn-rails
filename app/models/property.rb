class Property < ActiveRecord::Base

  # === List of columns ===
  #   id            : integer 
  #   tutor_version : integer 
  #   semester      : string 
  #   created_at    : datetime 
  #   updated_at    : datetime 
  # =======================

  Semester = /^(fa|sp)\d{2,2}$/	#A regex which validates the semester
  validates_format_of :semester, :with => Semester, :message => "Not a valid semester."
  validate :there_is_only_one, :on => :create
  validates :tutor_version, :numericality => {}
  def self.tutor_version=(version)
    prop = Property.first
    if prop.nil?
      prop = Property.new(:tutor_version => version, :semester => 'fa10')
    else
      prop.tutor_version = version
    end
	prop.save!
  end
  
  def self.tutor_version
    prop = Property.first
    if prop.nil?
      return -1
    else
      return prop.tutor_version
    end
  end

  def self.semester=(semester)
    prop = Property.first
    if prop.nil?
      prop = Property.new(:semester => semester, :tutor_version => -1)
    else
      prop.semester = semester
    end
	prop.save!
  end
  
  def self.semester
    prop = Property.first
    if prop.nil?
      return 'fa10'
    else
      return prop.semester
    end
  end
  
  def there_is_only_one
    if Property.count > 0
      errors.add(:base, "There can only be one property entry")
    end
  end
end
