module CoursesurveysHelper
  # rating should be a float that represents the rating out of 1.00
  def rating_bar(rating, url=nil, inverted=nil)
    width = (rating*100).to_int
    color = (rating > 0.75) ?  "green" : (rating > 0.5) ? "orange" : "red"
    
    # I appologize for forcing a span to be displayed as a block, I can't 
    # think of a better way of making it clickable with a link
    outer_html_options = { :class => "ratingbar" }
    inner_html_options = { :class => "subbar", :style => "width: #{width}%; background-color: #{color};" }
    if url.nil?
      content_tag(:span, outer_html_options) do
        content_tag("span", "", inner_html_options)
      end
    else
      link_to url do
        content_tag(:span, outer_html_options) do
          content_tag("span", "", inner_html_options)
        end
      end
    end
  end

  def surveys_klass_path(klass)
    coursesurveys_klass_path klass.course.dept_abbr, klass.course.full_course_number, klass.url_semester
  end

  def surveys_course_path(course)
    coursesurveys_course_path(course.dept_abbr, course.full_course_number)
  end

  def surveys_instructor_path(instructor)
    coursesurveys_instructor_path(instructor.name.gsub(/\s/, '_'))
  end
end
