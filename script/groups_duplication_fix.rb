#!/usr/bin/env ruby

# This script will fix the group data duplication problem where some groups are duplicated in hkn_rails_production.

a = []
Group.all.each do |group|

  group_name = group.name
  group_id = group.id
  if a.member?(group_id)
    next
  end
  Group.all.each do |another_group|
    another_group_name = another_group.name
    another_group_id = another_group.id
    if group_name == another_group_name && group_id != another_group_id
      a << another_group_id
      peoples = another_group.people
      peoples.each do |person|
        if !group.people.find_by_id(person.id)
          group.people << person
        end
      end
    end
  end
end

for group_id in a
  Group.find_by_id(group_id).destroy
end

