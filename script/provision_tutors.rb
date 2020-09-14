num_tutors = 4000
for i in 0..num_tutors
    p = Person.create(
        first_name: "test_first_name_#{i}",
        last_name: "test_last_name_#{i}",
        username: "test_username_#{i}",
        email: "test_email_#{i}@hkn.eecs.berkeley.edu",
        password: "test_password_#{i}",
        password_confirmation: "test_password_#{i}",
    );
    p.get_tutor
end
