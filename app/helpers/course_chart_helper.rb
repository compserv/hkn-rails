module CourseChartHelper
  def get_coursechart_json(chart_type)
    cs_department = Department.find_by_nice_abbr("CS")
    ee_department = Department.find_by_nice_abbr("EE")
    courses = CourseChart.where(:show => true)
    link_function = proc {|dept, num| courseguide_show_path(dept, num)} 
    case chart_type
    when "course_guide"
      link_function = proc {|dept, num| courseguide_show_path(dept, num)} 
    when "course_survey"
      link_function = proc {|dept, num| coursesurveys_course_path(dept, num)} 
    else
      link_function = proc { "http://hkn.eecs.berkeley.edu" }
    end

    def generate_course(course_chart, link_function)
      c = {}
      course = course_chart.course
      c[:id] = course.id
      c[:department_id] = course.department_id
      c[:name] = course.full_course_number
      c[:link] = link_function.call(course.department_id == 2 ? "CS" : "EE", c[:name])
      c[:prereqs] = CoursePrereq.where(:course_id => course.id).select("id, course_id, prereq_id, is_recommended")
      c[:type_id] = course.course_type_id
      c[:bias_x] = course_chart.bias_x
      c[:bias_y] = course_chart.bias_y
      c[:depth] = course_chart.depth
      return c
    end

    course_info = courses.all.map{|x| generate_course(x, link_function)}
    json = {}
    json[:types] = CourseType.all.select("id, chart_pref_x, chart_pref_y, color, name")
    json[:cs_courses] = course_info.select{|x| x[:department_id] == cs_department.id}
    json[:ee_courses] = course_info.select{|x| x[:department_id] == ee_department.id}
    return json
  end
end
