# == Schema Information
#
# Table name: alumnis
#
#  id            :integer          not null, primary key
#  grad_semester :string(255)
#  grad_school   :string(255)
#  job_title     :string(255)
#  company       :string(255)
#  salary        :integer
#  person_id     :integer
#  created_at    :datetime
#  updated_at    :datetime
#  perm_email    :string(255)
#  location      :string(255)
#  suggestions   :text
#  mailing_list  :boolean
#

class Alumni < ActiveRecord::Base

  belongs_to :person
  validates_uniqueness_of :person_id
  validates_inclusion_of :salary, :in => 0...5000000000000000000, :message=>"must be within 0 and 5 quintillion", :allow_nil=>true
  validates_presence_of :perm_email, :grad_semester

  MAILING_LIST_URL = 'https://hkn.eecs.berkeley.edu/mailman/listinfo/alumni'
  SEASONS = ['Fall', 'Spring', 'Summer']

  def subscribe
    agent = Mechanize.new
    agent.get(MAILING_LIST_URL) do |page|
      page.form_with(:action => '../subscribe/alumni') do |form|
        form['email'] = self.perm_email
        form['fullname'] = self.person.fullname
      end.submit
    end
  end

  def unsubscribe
    agent = Mechanize.new
    agent.get(MAILING_LIST_URL) do |page|
      options_page = page.form_with(:action => '../options/alumni') do |form|
        form['email'] = self.perm_email
      end.submit
      options_page.form_with(:action => '../options/alumni') do |form|
        form.click_button(form.button_with(:value => 'Unsubscribe'))
      end
    end
  end

  def self.years
    current = Time.now.year
    return (1915..current).to_a.reverse
  end

  def self.grad_semester(semester, year)
    return semester + ' ' + year
  end
end
