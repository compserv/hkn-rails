class FixHabtmDuplicates < ActiveRecord::Migration
  Dups = [  [:slots_tutors, [:slot_id, :tutor_id]],
            [:blocks_rsvps, [:block_id, :rsvp_id]],
            [:badges_people, [:badge_id, :person_id]],
            [:groups_people, [:group_id, :person_id]],
            [:instructors_klasses, [:instructor_id, :klass_id]],
            [:course_preferences, [:course_id, :tutor_id]],
         ]

  def self.up
    Dups.each do |table_name, columns|
      puts "Removing #{columns.collect(&:to_s).join(',')} from #{table_name.to_s}..."
      execute "delete from #{table_name.to_s} t1 where t1.ctid not in (select max(t2.ctid) from #{table_name.to_s} t2 group by #{columns.collect{|c| "t2.#{c.to_s}"}.join(',')});"
    end
  end

  def self.down
    puts "NOTICE: As this migration is a bugfix, no changes will be made for this DOWN migration."
  end
end
