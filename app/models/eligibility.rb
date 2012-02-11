class Eligibility < ActiveRecord::Base

  # === List of columns ===
  #   id             : integer 
  #   first_name     : string 
  #   last_name      : string 
  #   middle_initial : string 
  #   major          : string 
  #   email          : string 
  #   address1       : string 
  #   address2       : string 
  #   city           : string 
  #   state          : string 
  #   zip            : string 
  #   semester       : string 
  #   group          : integer 
  #   class_level    : integer 
  #   confidence     : integer 
  #   first_reg      : date 
  #   candidate_id   : integer 
  #   created_at     : datetime 
  #   updated_at     : datetime 
  # =======================

  Groups      = [:unknown,    :candidate,    :member   ]
  GroupValues = {:unknown=>0, :candidate=>1, :member=>2}
  TableFields = [:last_name, :first_name, :email, :address, :class_level]

  validates_presence_of :semester

  [:group, :confidence].each do |f|
    validates_presence_of f
    validates_numericality_of f
  end

  scope :current, lambda{ where(:semester=>Property.get_or_create.semester) }
  GroupValues.each_pair do |g,v|  # auto-generate group scopes
    scope g.to_s.pluralize.to_sym, lambda{ where(:group=>v) }
  end

  def full_name
    [first_name, middle_initial, last_name].join(' ').gsub!(/\s+/,' ')
  end

  def address
    return "" if address1.blank?
    "#{address1}#{"\n"+address2 if address2.present?}\n#{city}, #{state} #{zip}"
  end

  ###################
  # Utility methods #
  ###################
  def is_unique?
   not Eligibility.exists?(unique_info)
  end

  def unique_info
    id_fields = [:first_name, :middle_initial, :last_name, :email, :first_reg]
    info = {}
    id_fields.each {|f| info[f] = self.send f}
    info
  end

  def auto_assign_group
    # Also sets confidence level
  
    self.confidence = case
      when p = Person.find(:first, :conditions => {:email => email}) then 3
      when p = Person.find(:first, :conditions => {:first_name => first_name, :last_name => last_name}) then 2
      when p = Person.find_by_username([first_name.first,last_name].join.downcase) then 1
      else self.confidence
    end

    self.group = case
      when p.present?
        p.candidate.present? ? GroupValues[:candidate] : GroupValues[:member]
      else 0
    end
  end


  ####################
  # Enhanced setters #
  ####################
  def class_level=(c)
    unless c.is_a? Integer then
      c = {'junior'=>3, 'senior'=>4}[c.to_s.downcase] || c
    end
    super(c)
  end

  def first_reg=(d)
    d = d.to_date if d.is_a? DateTime
    unless d.nil? || d.is_a?(Date)
      d = ActiveRecord::ConnectionAdapters::Column.string_to_date(d.to_s)
      # hack for e.g. -09 => 0009 instead of 2009
      d = (d.to_datetime + 2000.years).to_date if d.year/100 == 0
    end
    super(d)
  end

  ####################
  # Import from CSV  #
  ####################
  class Importer
    require 'csv'

    def self.import(file)
      ret = {:errors => [], :count=>0}
      last_row = 0
      begin
        Eligibility.transaction do
          fields = []
          fieldmap = {:email_address=>:email, :local_street1=>:address1, :local_street2=>:address2, :local_city=>:city, :local_state=>:state, :local_zip=>:zip, :ucb_1st_reg=>:first_reg}
          saw_header = false
          current_semester = Property.current_semester
          CSV.open(file.path, 'r').each do |row|
            last_row += 1
            unless saw_header
              fields = row.collect(&:downcase)
              saw_header = true
              next
            end
            next unless row.length == fields.length
            e = {}
            for i in 0..fields.length-1 do
              field = fields[i].gsub(/\s+/,'_').underscore.to_sym 
              field = fieldmap[field] if fieldmap[field]
              e[field] = row[i]
            end

            e[:semester] = current_semester
            puts e.inspect
            el = Eligibility.new(e)
            if el.is_unique?
              el.auto_assign_group
              ret[:errors] << "Error parsing #{el.inspect}" unless el.save
            end # exists?
            ret[:count] += 1
          end # CSV
        end # transaction
      rescue => e
        # Something went wrong
        ret[:errors] << "Aborted."
        ret[:errors] << e.inspect.gsub(/[<>]/, ' ')
        ret[:errors] << "Last row was: #{last_row.inspect}"
      ensure
        file.close if file
      end
      return ret
    end
  end

end
