class AddCommitteeshipsToFa2011Officers < ActiveRecord::Migration
  def self.up

    say "About to process #{Election.elected.count} elections"
    Election.elected.all.each do |e|
      e.update_attribute(:semester, "20113") if e.semester == "20111"  # oops
      say "  #{e.person.username}"

      c = Committeeship.new({
        committee: e.position,
        semester:  e.semester,
        title:     'officer',
        person_id: e.person_id
      })
      c.save || raise("Failed to save #{c.inspect} #{e.inspect}")
    end
  end

  def self.down
    say "This is a bugfix. Why would you want to undo it?"
  end
end
