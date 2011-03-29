class AddIndexes < ActiveRecord::Migration
  # The purpose of this migration is to add indexes to a couple of
  # tables that previously allowed duplicate entries, mostly the HABTM tables.
  # This would be ok in rails, but loading a direct SQL backup breaks things.
  # Also, might as well add indexes for some tables that need speeding up.

  Uniques = [ # Things that need unique
              [:slots_tutors,         [:slot_id,         :tutor_id ]],
              [:blocks_rsvps,         [:block_id,        :rsvp_id  ]],
              [:badges_people,        [:badge_id,        :person_id]],
              [:coursesurveys_people, [:coursesurvey_id, :person_id]],
              [:groups_people,        [:group_id,        :person_id]],
              [:instructors_klasses,  [:instructor_id,   :klass_id ]],
              [:klasses_tas,          [:instructor_id,   :klass_id ]],
              [:course_preferences,   [:course_id,       :tutor_id ]]
            ]
  Indexes = [ # Things that need indexes
              [:survey_answers, [:klass_id]],
              [:tutors,         [:person_id]],
              [:slots,          [:time]]
            ]

##  def self.iname(cols)
##    # Index name
##    cols.collect(&:to_s).join('_')
##  end

  def self.up
    Uniques.each do |table_name, columns|
      #execute "ALTER TABLE '#{table_name}' ADD UNIQUE '#{iname columns}' (#{columns.collect{|c| "'#{c.to_s}'"}.join(',')})"
      add_index table_name, columns, :unique => true
    end
    Indexes.each do |table_name, columns|
      add_index table_name, columns
    end
  end

  def self.down
    (Uniques+Indexes).each do |table_name, columns|
      remove_index table_name, :column => columns
    end
  end
end
