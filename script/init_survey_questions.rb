#!/usr/bin/env ruby

# This script will initialize the course survey questions if they aren't
# already in the database.
#
# -richardxia

# Trick Ruby into loading all of our Rails configurations
# Note: You MUST have the environment variable $RAILS_ENV set to 'production'
# if you want to load in the course surveys to the production server.
require File.expand_path('../../config/environment', __FILE__)

questions = [
  {"inverted"=>false,"text"=>"Rate the overall teaching effectiveness of this instructor","max"=>7,"important"=>true},
  {"inverted"=>false,"text"=>"How worthwhile was this course compared with others at U.C.?","max"=>7,"important"=>true},
  {"inverted"=>false,"text"=>"Gives lectures that are well organized","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Is enthusiastic about the subject matter","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Identifies what he/she considers important","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Has an interesting style of presentation","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Uses visual aids and blackboards effectively","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Encourages questions from students","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Is careful and precise in answering questions","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Relates to students as individuals","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Is accessible to students outside of class","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Is amicable and helpful to students during office hours","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Gives interesting and stimulation assignments","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Gives exams that permit students to show their understanding","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Uses a grading system that is clearly defined and equitable","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Required course material is sufficiently covered in lecture","max"=>5,"important"=>false},
  {"inverted"=>true,"text"=>"Pace of the course is too fast","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"The required text/notes is beneficial","max"=>5,"important"=>false},
  {"inverted"=>true,"text"=>"Workload is heavier than for courses of comparable credit","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Is well prepared","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Communicates ideas effectively","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Appears to have a good knowledge of the subject matter","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Answers questions accurately","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Encourages questions and/or class discussion","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Is aware when students are having difficulty","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Is accessible during office hours","max"=>5,"important"=>false},
  {"inverted"=>false,"text"=>"Rate the T.A.'s overall teaching effectiveness","max"=>5,"important"=>false}
]

questions.each do|question|
  unless SurveyQuestion.find_by_text(question["text"])
    puts "Did not find #{question[:text]}. Creating now."
    SurveyQuestion.create(question)
  end
end
