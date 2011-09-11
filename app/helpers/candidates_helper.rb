module CandidatesHelper
    def promote_candidate(email)
        member_group = Group.find_by_name('members')
        candidate_group = Group.find_by_name('candidates')
        account = Person.find_by_email(email)
        account.delete(candidate_group)
        account |= member_group
        if account.save()
            # good to go
        else
            # return some info of who failed to migrate
        end
    end

    def promote_candidates(email_list)
        email_list.each {|email| promote_candidate(email)}

    end
end
