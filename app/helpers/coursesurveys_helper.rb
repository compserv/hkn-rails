module CoursesurveysHelper
  # rating should be a float that represents the rating out of 1.00
  def rating_bar(rating, url=nil, inverted=nil)


    outer_html_options = { :class => "ratingbar" }
    if inverted
      width = 100-(rating*100).to_int
      margin_left = 100-width
    else
      width = (rating*100).to_int
      margin_left = 0
    end

    color = (width > 75) ?  "green" : (width > 50) ? "orange" : "red"
    inner_html_options = { :class => "subbar", :style => "width: #{width}%; background-color: #{color}; margin-left: #{margin_left}%;" }

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

  def frequency_bar(rating)
    width = (rating*100).to_int

    outer_html_options = { :class => "frequencybar" }
    inner_html_options = { :class => "subbar", :style => "width: #{width}%;" }
    content_tag(:span, outer_html_options) do
      content_tag("span", "", inner_html_options)
    end
  end

  def surveys_klass_path(klass)
    coursesurveys_klass_path klass.course.dept_abbr, klass.course.full_course_number, klass.url_semester
  end

  def surveys_course_path(course)
    coursesurveys_course_path(course.dept_abbr, course.full_course_number)
  end

  def surveys_instructor_path(instructor)
    coursesurveys_instructor_path(instructor.last_name+","+instructor.first_name)
  end

  def surveys_rating_path(rating)
    coursesurveys_rating_path(rating.id)
  end
end
