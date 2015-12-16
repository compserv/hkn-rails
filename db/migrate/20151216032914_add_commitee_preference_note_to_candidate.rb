class AddCommiteePreferenceNoteToCandidate < ActiveRecord::Migration
  def change
    add_column :candidates, :committee_preference_note, :text
  end
end
