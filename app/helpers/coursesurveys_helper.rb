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

    color = (width > 75) ?  "#77c265" : (width > 50) ? "#f6e68b" : "#ed8d86"
    inner_html_options = { :class => "subbar", :style => "width: #{width}%; background-color: #{color}; margin-left: 0px;" }

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

  def rating_and_bar(score, max, url=nil, inverted=nil)
    contents = "
    <span class=\"rating\">#{sprintf "%.1f", score}</span><span class=\"rating2\"> / #{max}</span>\n
    #{rating_bar(score/max.to_f)}
    "
 
    content_tag(:span, contents.html_safe)
  end

  def frequency_bar(rating)
    rating = 0 if rating.to_f.nan? || rating.to_f.infinite?
    width = (rating*100).to_int

    outer_html_options = { :class => "frequencybar" }
    inner_html_options = { :class => "subbar", :style => "width: #{width}%;" }
    content_tag(:span, outer_html_options) do
      content_tag("span", "", inner_html_options)
    end
  end

  def instructor_cache_path(instructor)
    "instructor_#{instructor.id}"
  end

  def surveys_klass_path(klass)
    if klass.section.blank? || klass.has_other_sections?
      coursesurveys_klass_path klass.course.dept_abbr, klass.course.full_course_number, klass.url_semester, klass.section
    else
      coursesurveys_klass_path klass.course.dept_abbr, klass.course.full_course_number, klass.url_semester
    end
  end

  def surveys_course_path(course)
    coursesurveys_course_path(course.dept_abbr, course.full_course_number)
  end

  def surveys_instructor_path(instructor)
    coursesurveys_instructor_path("#{instructor.last_name},#{instructor.first_name}")
  end

  def surveys_rating_path(rating)
    coursesurveys_rating_path(rating.id)
  end
  
  def decode_frequencies(f)
    # If key is a String(Integer), make it just an integer.
    # "5"=>17 becomes 5=>17
    # This is needed because JSON.encode puts quotes around integer keys, and
    # the data is easier to use with integer keys.
    # Keys like "N/A" and "Omit" are left alone.
    h = {}
    ActiveSupport::JSON.decode(f).each_pair do |key,value|
        key = key.to_i if key.eql?(key.to_i.to_s)
        h[key] = value
    end
    h
  end
end
