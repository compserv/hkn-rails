class CreateInstructorships < ActiveRecord::Migration

  #                table name               is ta?
  OldTables = [ ["instructors_klasses", "FALSE"],
                ["klasses_tas",         "TRUE"]
              ]
  def self.up
    create_table :instructorships do |t|
      t.references :klass
      t.references :instructor
      t.boolean    :ta,           null: false

      t.timestamps
    end

    # Migrate data to new table
    OldTables.each do |table_name, is_ta|
      execute "INSERT INTO instructorships (klass_id, instructor_id, ta)
               SELECT #{table_name}.klass_id, #{table_name}.instructor_id, #{is_ta}
               FROM #{table_name}"
    end

    # Drop old tables
    drop_table :instructors_klasses
    drop_table :klasses_tas

  end

  def self.down
    # Restore data to old tables
    create_table "instructors_klasses", id: false, force: true do |t|
      t.integer "instructor_id"
      t.integer "klass_id"
    end
    add_index "instructors_klasses", ["instructor_id", "klass_id"], name: "index_instructors_klasses_on_instructor_id_and_klass_id", unique: true

    create_table "klasses_tas", id: false, force: true do |t|
      t.integer "instructor_id"
      t.integer "klass_id"
    end
    add_index "klasses_tas", ["instructor_id", "klass_id"], name: "index_klasses_tas_on_instructor_id_and_klass_id", unique: true

    # Migrate data
    OldTables.each do |table_name, is_ta|
      execute "INSERT INTO #{table_name} (klass_id, instructor_id)
               SELECT instructorships.klass_id, instructorships.instructor_id
               FROM instructorships
               WHERE instructorships.ta = #{is_ta}"
    end

    drop_table :instructorships
  end
end
