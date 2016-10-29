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
      link_function = proc { Rails.application.routes.url_helpers.root_path }
    end

    def generate_course(course_chart, link_function)
      course = course_chart.course
      c = {
        :id => course.id,
        :department_id => course.department_id,
        :name => course.full_course_number,
        :link => link_function.call(course.department_id == 2 ? "CS" : "EE", course.full_course_number),
        :prereqs => CoursePrereq.where(:course_id => course.id).select("id, course_id, prereq_id, is_recommended"),
        :type_id => course.course_type_id,
        :bias_x => course_chart.bias_x,
        :bias_y => course_chart.bias_y,
        :depth => course_chart.depth
      }
      return c
    end

    course_info = courses.all.map{|x| generate_course(x, link_function)}
    json = {
      :types => CourseType.all.select("id, chart_pref_x, chart_pref_y, color, name"),
      :cs_courses => course_info.select{|x| x[:department_id] == cs_department.id},
      :ee_courses => course_info.select{|x| x[:department_id] == ee_department.id}
    }
    return json
  end
end
