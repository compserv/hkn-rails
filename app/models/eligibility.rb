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
  #   first_reg      : date 
  #   candidate_id   : integer 
  #   created_at     : datetime 
  #   updated_at     : datetime 
  # =======================

  Groups      = [:unknown,    :candidate,    :member   ]
  GroupValues = {:unknown=>0, :candidate=>1, :member=>2}
  TableFields = [:last_name, :first_name, :email, :address, :class_level]

  validates_presence_of :semester
  validates_presence_of :group
  validates_numericality_of :group

  scope :current, lambda{ where(:semester=>Property.get_or_create.semester) }

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
   not Eligibility.exists? unique_info
  end

  def unique_info
    id_fields = [:first_name, :middle_initial, :last_name, :email, :first_reg]
    info = {}
    id_fields.each {|f| info[f] = self.send f}
    info
  end

  def auto_assign_group
    self.group = case
      when p = Person.find(unique_info.delete(:first_reg))
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
      begin
        Eligibility.transaction do
          fields = file.readline.strip.split(',')
          fieldmap = {:email_address=>:email, :local_street1=>:address1, :local_street2=>:address2, :local_city=>:city, :local_state=>:state, :local_zip=>:zip, :ucb_1st_reg=>:first_reg}

          saw_header = false
          current_semester = Property.get_or_create.semester
          CSV.open(file.path, 'r', ',') do |row|
            unless saw_header then saw_header=true; next; end
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
            unless el.is_unique? && el.save
              el.auto_assign_group
              ret[:errors] << "Error parsing #{el.inspect}" unless el.save
            end # exists?
            ret[:count] += 1
          end # CSV
        end # transaction
      rescue
        # Something went wrong
        ret[:errors] << "Aborted."
      ensure
        file.close if file
      end
      return ret
    end
  end

end
