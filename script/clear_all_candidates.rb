#!/usr/bin/env ruby

candidate_group = Group.find_by_name("candidates")

candidate_group.people.each do |person|
  person.groups.destroy(candidate_group)
end
