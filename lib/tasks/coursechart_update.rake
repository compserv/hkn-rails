namespace :course_chart do

  desc "Scrape a schedule.berkeley url into this semester's course surveys to be surveyed"
  task :update do
    # establish database connection
    Course.connection

    # cs course types
    def gen_cs_types
      @cs_type_core = CourseType.new
      @cs_type_core.chart_pref_x = 0.5
      @cs_type_core.chart_pref_y = 0
      @cs_type_core.name = "core"
      @cs_type_core.color = "#E57373"

      @cs_type_hardware = CourseType.new
      @cs_type_hardware.chart_pref_x = 1.0
      @cs_type_hardware.chart_pref_y = -0.2
      @cs_type_hardware.name = "hardware"
      @cs_type_hardware.color = "#FFF176"

      @cs_type_software = CourseType.new
      @cs_type_software.chart_pref_x = 0.5
      @cs_type_software.chart_pref_y = 0
      @cs_type_software.name = "software"
      @cs_type_software.color = "#90CAF9"

      @cs_type_theory = CourseType.new
      @cs_type_theory.chart_pref_x = 0.8
      @cs_type_theory.chart_pref_y = 0
      @cs_type_theory.name = "theory"
      @cs_type_theory.color = "#80CBC4"

      @cs_type_applications = CourseType.new
      @cs_type_applications.chart_pref_x = 0
      @cs_type_applications.chart_pref_y = 0
      @cs_type_applications.name = "applications"
      @cs_type_applications.color = "#CE93D8"
    end

    def save_cs_types
      @cs_type_core.save
      @cs_type_hardware.save
      @cs_type_software.save
      @cs_type_theory.save
      @cs_type_applications.save
    end

    # ee course types
    def gen_ee_types
      @ee_type_core = CourseType.new
      @ee_type_core.chart_pref_x = 0.5
      @ee_type_core.chart_pref_y = 0
      @ee_type_core.name = "core"
      @ee_type_core.color = "#E57373"

      @ee_type_circuits = CourseType.new
      @ee_type_circuits.chart_pref_x = 0.5
      @ee_type_circuits.chart_pref_y = 0
      @ee_type_circuits.name = "circuits"
      @ee_type_circuits.color = "#FFF176"

      @ee_type_devices = CourseType.new
      @ee_type_devices.chart_pref_x = 1.0
      @ee_type_devices.chart_pref_y = 0
      @ee_type_devices.name = "devices"
      @ee_type_devices.color = "#90CAF9"

      @ee_type_optics = CourseType.new
      @ee_type_optics.chart_pref_x = 0.6
      @ee_type_optics.chart_pref_y = 0
      @ee_type_optics.name = "optics"
      @ee_type_optics.color = "#80CBC4"

      @ee_type_bioelectronics = CourseType.new
      @ee_type_bioelectronics.chart_pref_x = 0.5
      @ee_type_bioelectronics.chart_pref_y = 0
      @ee_type_bioelectronics.name = "bioelectronics"
      @ee_type_bioelectronics.color = "#CE93D8"

      @ee_type_power = CourseType.new
      @ee_type_power.chart_pref_x = 0.8
      @ee_type_power.chart_pref_y = 0
      @ee_type_power.name = "power"
      @ee_type_power.color = "#9FA8DA"

      @ee_type_signals = CourseType.new
      @ee_type_signals.chart_pref_x = 0
      @ee_type_signals.chart_pref_y = 0
      @ee_type_signals.name = "signals"
      @ee_type_signals.color = "#80DEEA"

      @ee_type_robotics = CourseType.new
      @ee_type_robotics.chart_pref_x = 0.3
      @ee_type_robotics.chart_pref_y = 0
      @ee_type_robotics.name = "robotics"
      @ee_type_robotics.color = "#FFCC80"

      @ee_type_required = CourseType.new
      @ee_type_required.chart_pref_x = 0.5
      @ee_type_required.chart_pref_y = 0
      @ee_type_required.name = "required"
      @ee_type_required.color = "#E0E0E0"
    end

    def save_cs_types
      @cs_type_core.save
      @cs_type_hardware.save
      @cs_type_software.save
      @cs_type_theory.save
      @cs_type_applications.save
    end

    def save_ee_types
      @ee_type_core.save
      @ee_type_circuits.save
      @ee_type_devices.save
      @ee_type_optics.save
      @ee_type_bioelectronics.save
      @ee_type_power.save
      @ee_type_signals.save
      @ee_type_robotics.save
      @ee_type_required.save
    end


    @courses = []
    @course_nodes = []
    # cs courses

    # need types to be saved before this can be run successfully
    def gen_courses
      @cs61a = Course.where(:course_number => 61, :suffix => "A")[0]
      @cs61a.course_type_id = @cs_type_core.id
      @cs61a_node = CourseChart.new
      @cs61a_node.course_id = @cs61a.id
      @cs61a_node.bias_x = 0
      @cs61a_node.bias_y = 0
      @cs61a_node.depth = 1
      @cs61a_node.show = true
      @courses.push(@cs61a)
      @course_nodes.push(@cs61a_node)

      @cs61b = Course.where(:course_number => 61, :suffix => "B")[0]
      @cs61b.course_type_id = @cs_type_core.id
      @cs61b_node = CourseChart.new
      @cs61b_node.course_id = @cs61b.id
      @cs61b_node.bias_x = -50
      @cs61b_node.bias_y = 0
      @cs61b_node.depth = 2
      @cs61b_node.show = true
      @courses.push(@cs61b)
      @course_nodes.push(@cs61b_node)

      @cs61c = Course.where(:course_number => 61, :suffix => "C")[0]
      @cs61c.course_type_id = @cs_type_core.id
      @cs61c_node = CourseChart.new
      @cs61c_node.course_id = @cs61c.id
      @cs61c_node.bias_x = 50
      @cs61c_node.bias_y = 0
      @cs61c_node.depth = 2
      @cs61c_node.show = true
      @courses.push(@cs61c)
      @course_nodes.push(@cs61c_node)

      @cs70 = Course.where(:course_number => 70)[0]
      @cs70.course_type_id = @cs_type_core.id
      @cs70_node = CourseChart.new
      @cs70_node.course_id = @cs70.id
      @cs70_node.bias_x = 0
      @cs70_node.bias_y = 0
      @cs70_node.depth = 5
      @cs70_node.show = true
      @courses.push(@cs70)
      @course_nodes.push(@cs70_node)

      @cs150 = Course.where(:course_number => 150)[0]
      @cs150.course_type_id = @cs_type_hardware.id
      @cs150_node = CourseChart.new
      @cs150_node.course_id = @cs150.id
      @cs150_node.bias_x = 0
      @cs150_node.bias_y = 0
      @cs150_node.depth = 3
      @cs150_node.show = true
      @courses.push(@cs150)
      @course_nodes.push(@cs150_node)

      @cs152 = Course.where(:course_number => 152)[0]
      @cs152.course_type_id = @cs_type_hardware.id
      @cs152_node = CourseChart.new
      @cs152_node.course_id = @cs152.id
      @cs152_node.bias_x = 0
      @cs152_node.bias_y = 0
      @cs152_node.depth = 3
      @cs152_node.show = true
      @courses.push(@cs152)
      @course_nodes.push(@cs152_node)

      @cs160 = Course.where(:course_number => 160)[0]
      @cs160.course_type_id = @cs_type_software.id
      @cs160_node = CourseChart.new
      @cs160_node.course_id = @cs160.id
      @cs160_node.bias_x = 0
      @cs160_node.bias_y = 0
      @cs160_node.depth = 3
      @cs160_node.show = true
      @courses.push(@cs160)
      @course_nodes.push(@cs160_node)

      @cs161 = Course.where(:course_number => 161)[0]
      @cs161.course_type_id = @cs_type_software.id
      @cs161_node = CourseChart.new
      @cs161_node.course_id = @cs161.id
      @cs161_node.bias_x = 0
      @cs161_node.bias_y = 0
      @cs161_node.depth = 3
      @cs161_node.show = true
      @courses.push(@cs161)
      @course_nodes.push(@cs161_node)

      @cs162 = Course.where(:course_number => 162)[0]
      @cs162.course_type_id = @cs_type_software.id
      @cs162_node = CourseChart.new
      @cs162_node.course_id = @cs162.id
      @cs162_node.bias_x = 0
      @cs162_node.bias_y = 0
      @cs162_node.depth = 3
      @cs162_node.show = true
      @courses.push(@cs162)
      @course_nodes.push(@cs162_node)

      @cs164 = Course.where(:course_number => 164)[0]
      @cs164.course_type_id = @cs_type_software.id
      @cs164_node = CourseChart.new
      @cs164_node.course_id = @cs164.id
      @cs164_node.bias_x = 0
      @cs164_node.bias_y = 0
      @cs164_node.depth = 3
      @cs164_node.show = true
      @courses.push(@cs164)
      @course_nodes.push(@cs164_node)

      # cs168 is not in the database yet
      # @cs168 = Course.where(:course_number => 168)[0]
      # @cs168.course_type_id = @cs_type_software.id
      # @cs168_node = CourseChart.new
      # @cs168_node.course_id = @cs168.id
      # @cs168_node.bias_x = 0
      # @cs168_node.bias_y = 0
      # @cs168_node.depth = 3
      # @cs168_node.show = true
      # @courses.push(@cs168)
      # @course_nodes.push(@cs168_node)

      @cs169 = Course.where(:course_number => 169)[0]
      @cs169.course_type_id = @cs_type_software.id
      @cs169_node = CourseChart.new
      @cs169_node.course_id = @cs169.id
      @cs169_node.bias_x = 0
      @cs169_node.bias_y = 0
      @cs169_node.depth = 3
      @cs169_node.show = true
      @courses.push(@cs169)
      @course_nodes.push(@cs169_node)

      @cs170 = Course.where(:course_number => 170)[0]
      @cs170.course_type_id = @cs_type_theory.id
      @cs170_node = CourseChart.new
      @cs170_node.course_id = @cs170.id
      @cs170_node.bias_x = 0
      @cs170_node.bias_y = 0
      @cs170_node.depth = 3
      @cs170_node.show = true
      @courses.push(@cs170)
      @course_nodes.push(@cs170_node)

      @cs172 = Course.where(:course_number => 172)[0]
      @cs172.course_type_id = @cs_type_theory.id
      @cs172_node = CourseChart.new
      @cs172_node.course_id = @cs172.id
      @cs172_node.bias_x = 0
      @cs172_node.bias_y = 0
      @cs172_node.depth = 4
      @cs172_node.show = true
      @courses.push(@cs172)
      @course_nodes.push(@cs172_node)

      @cs174 = Course.where(:course_number => 174)[0]
      @cs174.course_type_id = @cs_type_theory.id
      @cs174_node = CourseChart.new
      @cs174_node.course_id = @cs174.id
      @cs174_node.bias_x = 0
      @cs174_node.bias_y = 0
      @cs174_node.depth = 4
      @cs174_node.show = true
      @courses.push(@cs174)
      @course_nodes.push(@cs174_node)

      @cs176 = Course.where(:course_number => 176)[0]
      @cs176.course_type_id = @cs_type_theory.id
      @cs176_node = CourseChart.new
      @cs176_node.course_id = @cs176.id
      @cs176_node.bias_x = 0
      @cs176_node.bias_y = 0
      @cs176_node.depth = 4
      @cs176_node.show = true
      @courses.push(@cs176)
      @course_nodes.push(@cs176_node)

      @cs184 = Course.where(:course_number => 184)[0]
      @cs184.course_type_id = @cs_type_applications.id
      @cs184_node = CourseChart.new
      @cs184_node.course_id = @cs184.id
      @cs184_node.bias_x = 0
      @cs184_node.bias_y = 0
      @cs184_node.depth = 3
      @cs184_node.show = true
      @courses.push(@cs184)
      @course_nodes.push(@cs184_node)

      @cs186 = Course.where(:course_number => 186)[0]
      @cs186.course_type_id = @cs_type_applications.id
      @cs186_node = CourseChart.new
      @cs186_node.course_id = @cs186.id
      @cs186_node.bias_x = 0
      @cs186_node.bias_y = 0
      @cs186_node.depth = 3
      @cs186_node.show = true
      @courses.push(@cs186)
      @course_nodes.push(@cs186_node)

      @cs188 = Course.where(:course_number => 188)[0]
      @cs188.course_type_id = @cs_type_applications.id
      @cs188_node = CourseChart.new
      @cs188_node.course_id = @cs188.id
      @cs188_node.bias_x = 0
      @cs188_node.bias_y = 0
      @cs188_node.depth = 3
      @cs188_node.show = true
      @courses.push(@cs188)
      @course_nodes.push(@cs188_node)

      @cs189 = Course.where(:course_number => 189)[0]
      @cs189.course_type_id = @cs_type_applications.id
      @cs189_node = CourseChart.new
      @cs189_node.course_id = @cs189.id
      @cs189_node.bias_x = 0
      @cs189_node.bias_y = 0
      @cs189_node.depth = 4
      @cs189_node.show = true
      @courses.push(@cs189)
      @course_nodes.push(@cs189_node)

      #ee @courses
      @ee20 = Course.where(:course_number => 20)[0]
      @ee20.course_type_id = @ee_type_required.id
      @ee20_node = CourseChart.new
      @ee20_node.course_id = @ee20.id
      @ee20_node.bias_x = -50
      @ee20_node.bias_y = 0
      @ee20_node.depth = 1
      @ee20_node.show = true
      @courses.push(@ee20)
      @course_nodes.push(@ee20_node)

      @ee40 = Course.where(:course_number => 40, :suffix => "", :prefix => "")[0]
      @ee40.course_type_id = @ee_type_required.id
      @ee40_node = CourseChart.new
      @ee40_node.course_id = @ee40.id
      @ee40_node.bias_x = 50
      @ee40_node.bias_y = 0
      @ee40_node.depth = 1
      @ee40_node.show = true
      @courses.push(@ee40)
      @course_nodes.push(@ee40_node)

      @ee126 = Course.where(:course_number => 126)[0]
      @ee126.course_type_id = @ee_type_signals.id
      @ee126_node = CourseChart.new
      @ee126_node.course_id = @ee126.id
      @ee126_node.bias_x = 0
      @ee126_node.bias_y = 0
      @ee126_node.depth = 2
      @ee126_node.show = true
      @courses.push(@ee126)
      @course_nodes.push(@ee126_node)

      @ee120 = Course.where(:course_number => 120, :suffix => "", :prefix => "")[0]
      @ee120.course_type_id = @ee_type_core.id
      @ee120_node = CourseChart.new
      @ee120_node.course_id = @ee120.id
      @ee120_node.bias_x = -50
      @ee120_node.bias_y = 0
      @ee120_node.depth = 1.5
      @ee120_node.show = true
      @courses.push(@ee120)
      @course_nodes.push(@ee120_node)

      @eec145b = Course.where(:course_number => 145, :prefix => "C", :suffix => "B")[0]
      @eec145b.course_type_id = @ee_type_bioelectronics.id
      @eec145b_node = CourseChart.new
      @eec145b_node.course_id = @eec145b.id
      @eec145b_node.bias_x = 0
      @eec145b_node.bias_y = 0
      @eec145b_node.depth = 2
      @eec145b_node.show = true
      @courses.push(@eec145b)
      @course_nodes.push(@eec145b_node)

      @ee144 = Course.where(:course_number => 144)[0]
      @ee144.course_type_id = @ee_type_signals.id
      @ee144_node = CourseChart.new
      @ee144_node.course_id = @ee144.id
      @ee144_node.bias_x = 0
      @ee144_node.bias_y = 0
      @ee144_node.depth = 2
      @ee144_node.show = true
      @courses.push(@ee144)
      @course_nodes.push(@ee144_node)

      @ee149 = Course.where(:course_number => 149)[0]
      @ee149.course_type_id = @ee_type_robotics.id
      @ee149_node = CourseChart.new
      @ee149_node.course_id = @ee149.id
      @ee149_node.bias_x = 0
      @ee149_node.bias_y = 0
      @ee149_node.depth = 3
      @ee149_node.show = true
      @courses.push(@ee149)
      @course_nodes.push(@ee149_node)

      @ee105 = Course.where(:course_number => 105)[0]
      @ee105.course_type_id = @ee_type_core.id
      @ee105_node = CourseChart.new
      @ee105_node.course_id = @ee105.id
      @ee105_node.bias_x = 50
      @ee105_node.bias_y = 0
      @ee105_node.depth = 1.5
      @ee105_node.show = true
      @courses.push(@ee105)
      @course_nodes.push(@ee105_node)

      @ee117 = Course.where(:course_number => 117)[0]
      @ee117.course_type_id = @ee_type_power.id
      @ee117_node = CourseChart.new
      @ee117_node.course_id = @ee117.id
      @ee117_node.bias_x = 0
      @ee117_node.bias_y = 0
      @ee117_node.depth = 2
      @ee117_node.show = true
      @courses.push(@ee117)
      @course_nodes.push(@ee117_node)

      @ee130 = Course.where(:course_number => 130)[0]
      @ee130.course_type_id = @ee_type_devices.id
      @ee130_node = CourseChart.new
      @ee130_node.course_id = @ee130.id
      @ee130_node.bias_x = 0
      @ee130_node.bias_y = 0
      @ee130_node.depth = 2
      @ee130_node.show = true
      @courses.push(@ee130)
      @course_nodes.push(@ee130_node)

      @ee134 = Course.where(:course_number => 134)[0]
      @ee134.course_type_id = @ee_type_devices.id
      @ee134_node = CourseChart.new
      @ee134_node.course_id = @ee134.id
      @ee134_node.bias_x = 0
      @ee134_node.bias_y = 0
      @ee134_node.depth = 2
      @ee134_node.show = true
      @courses.push(@ee134)
      @course_nodes.push(@ee134_node)

      @ee143 = Course.where(:course_number => 143)[0]
      @ee143.course_type_id = @ee_type_devices.id
      @ee143_node = CourseChart.new
      @ee143_node.course_id = @ee143.id
      @ee143_node.bias_x = 0
      @ee143_node.bias_y = 0
      @ee143_node.depth = 2
      @ee143_node.show = true
      @courses.push(@ee143)
      @course_nodes.push(@ee143_node)

      @eec145l = Course.where(:course_number => 145, :prefix => "C", :suffix => "L")[0]
      @eec145l.course_type_id = @ee_type_bioelectronics.id
      @eec145l_node = CourseChart.new
      @eec145l_node.course_id = @eec145l.id
      @eec145l_node.bias_x = 0
      @eec145l_node.bias_y = 0
      @eec145l_node.depth = 2
      @eec145l_node.show = true
      @courses.push(@eec145l)
      @course_nodes.push(@eec145l_node)


      # ee C145M isn't in the database
      # @eec145m = Course.where(:course_number => 145, :prefix => "C", :suffix => "M")[0]
      # @eec145m.course_type_id = @ee_type_bioelectronics.id
      # @eec145m_node = CourseChart.new
      # @eec145m_node.course_id = @eec145m.id
      # @eec145m_node.bias_x = 0
      # @eec145m_node.bias_y = 0
      # @eec145m_node.depth = 2
      # @eec145m_node.show = true
      # @courses.push(@eec145m)
      # @course_nodes.push(@eec145m_node)

      @ee137a = Course.where(:course_number => 137, :suffix => "A")[0]
      @ee137a.course_type_id = @ee_type_power.id
      @ee137a_node = CourseChart.new
      @ee137a_node.course_id = @ee137a.id
      @ee137a_node.bias_x = 0
      @ee137a_node.bias_y = 0
      @ee137a_node.depth = 3
      @ee137a_node.show = true
      @courses.push(@ee137a)
      @course_nodes.push(@ee137a_node)

      @ee137b = Course.where(:course_number => 137, :suffix => "B")[0]
      @ee137b.course_type_id = @ee_type_power.id
      @ee137b_node = CourseChart.new
      @ee137b_node.course_id = @ee137b.id
      @ee137b_node.bias_x = 0
      @ee137b_node.bias_y = 0
      @ee137b_node.depth = 3
      @ee137b_node.show = true
      @courses.push(@ee137b)
      @course_nodes.push(@ee137b_node)

      @ee140 = Course.where(:course_number => 140)[0]
      @ee140.course_type_id = @ee_type_circuits.id
      @ee140_node = CourseChart.new
      @ee140_node.course_id = @ee140.id
      @ee140_node.bias_x = 0
      @ee140_node.bias_y = 0
      @ee140_node.depth = 3
      @ee140_node.show = true
      @courses.push(@ee140)
      @course_nodes.push(@ee140_node)

      @ee141 = Course.where(:course_number => 141)[0]
      @ee141.course_type_id = @ee_type_circuits.id
      @ee141_node = CourseChart.new
      @ee141_node.course_id = @ee141.id
      @ee141_node.bias_x = 0
      @ee141_node.bias_y = 0
      @ee141_node.depth = 3
      @ee141_node.show = true
      @courses.push(@ee141)
      @course_nodes.push(@ee141_node)

      @ee113 = Course.where(:course_number => 113)[0]
      @ee113.course_type_id = @ee_type_power.id
      @ee113_node = CourseChart.new
      @ee113_node.course_id = @ee113.id
      @ee113_node.bias_x = 0
      @ee113_node.bias_y = 0
      @ee113_node.depth = 3
      @ee113_node.show = true
      @courses.push(@ee113)
      @course_nodes.push(@ee113_node)

      @ee142 = Course.where(:course_number => 142)[0]
      @ee142.course_type_id = @ee_type_circuits.id
      @ee142_node = CourseChart.new
      @ee142_node.course_id = @ee142.id
      @ee142_node.bias_x = 0
      @ee142_node.bias_y = 0
      @ee142_node.depth = 4
      @ee142_node.show = true
      @courses.push(@ee142)
      @course_nodes.push(@ee142_node)

      @ee119 = Course.where(:course_number => 119)[0]
      @ee119.course_type_id = @ee_type_optics.id
      @ee119_node = CourseChart.new
      @ee119_node.course_id = @ee119.id
      @ee119_node.bias_x = 0
      @ee119_node.bias_y = 0
      @ee119_node.depth = 4
      @ee119_node.show = true
      @courses.push(@ee119)
      @course_nodes.push(@ee119_node)

      @ee122 = Course.where(:course_number => 122)[0]
      @ee122.course_type_id = @ee_type_signals.id
      @ee122_node = CourseChart.new
      @ee122_node.course_id = @ee122.id
      @ee122_node.bias_x = 0
      @ee122_node.bias_y = 0
      @ee122_node.depth = 4
      @ee122_node.show = true
      @courses.push(@ee122)
      @course_nodes.push(@ee122_node)

      @ee127a = Course.where(:course_number => 127, :suffix => "A")[0]
      @ee127a.course_type_id = @ee_type_signals.id
      @ee127a_node = CourseChart.new
      @ee127a_node.course_id = @ee127a.id
      @ee127a_node.bias_x = 0
      @ee127a_node.bias_y = 0
      @ee127a_node.depth = 4
      @ee127a_node.show = true
      @courses.push(@ee127a)
      @course_nodes.push(@ee127a_node)

      @ee147 = Course.where(:course_number => 147)[0]
      @ee147.course_type_id = @ee_type_robotics.id
      @ee147_node = CourseChart.new
      @ee147_node.course_id = @ee147.id
      @ee147_node.bias_x = 0
      @ee147_node.bias_y = 0
      @ee147_node.depth = 4
      @ee147_node.show = true
      @courses.push(@ee147)
      @course_nodes.push(@ee147_node)

      @ee121 = Course.where(:course_number => 121)[0]
      @ee121.course_type_id = @ee_type_signals.id
      @ee121_node = CourseChart.new
      @ee121_node.course_id = @ee121.id
      @ee121_node.bias_x = 0
      @ee121_node.bias_y = 0
      @ee121_node.depth = 3
      @ee121_node.show = true
      @courses.push(@ee121)
      @course_nodes.push(@ee121_node)

      @ee123 = Course.where(:course_number => 123)[0]
      @ee123.course_type_id = @ee_type_signals.id
      @ee123_node = CourseChart.new
      @ee123_node.course_id = @ee123.id
      @ee123_node.bias_x = 0
      @ee123_node.bias_y = 0
      @ee123_node.depth = 3
      @ee123_node.show = true
      @courses.push(@ee123)
      @course_nodes.push(@ee123_node)

      @eec125 = Course.where(:course_number => 125, :prefix => "C")[0]
      @eec125.course_type_id = @ee_type_signals.id
      @eec125_node = CourseChart.new
      @eec125_node.course_id = @eec125.id
      @eec125_node.bias_x = 0
      @eec125_node.bias_y = 0
      @eec125_node.depth = 3
      @eec125_node.show = true
      @courses.push(@eec125)
      @course_nodes.push(@eec125_node)

      @ee129 = Course.where(:course_number => 129)[0]
      @ee129.course_type_id = @ee_type_signals.id
      @ee129_node = CourseChart.new
      @ee129_node.course_id = @ee129.id
      @ee129_node.bias_x = 0
      @ee129_node.bias_y = 0
      @ee129_node.depth = 3
      @ee129_node.show = true
      @courses.push(@ee129)
      @course_nodes.push(@ee129_node)

      @eec128 = Course.where(:course_number => 128, :prefix => "C")[0]
      @eec128.course_type_id = @ee_type_signals.id
      @eec128_node = CourseChart.new
      @eec128_node.course_id = @eec128.id
      @eec128_node.bias_x = 0
      @eec128_node.bias_y = 0
      @eec128_node.depth = 3
      @eec128_node.show = true
      @courses.push(@eec128)
      @course_nodes.push(@eec128_node)
    end

    def save_classes
      @courses.each do |c|
        c.save
      end
      @course_nodes.each do |d|
        d.save
      end
    end

    @cs_prereqs = []
    @ee_prereqs = []

    #cs prereqs
    def gen_prereqs
      @cs61b_to_61a = CoursePrereq.new
      @cs61b_to_61a.course_id = @cs61b.id
      @cs61b_to_61a.prereq_id = @cs61a.id
      @cs61b_to_61a.is_recommended = false
      @cs_prereqs.push(@cs61b_to_61a)

      @cs61c_to_61a = CoursePrereq.new
      @cs61c_to_61a.course_id = @cs61c.id
      @cs61c_to_61a.prereq_id = @cs61a.id
      @cs61c_to_61a.is_recommended = false
      @cs_prereqs.push(@cs61c_to_61a)

      @cs150_to_61c = CoursePrereq.new
      @cs150_to_61c.course_id = @cs150.id
      @cs150_to_61c.prereq_id = @cs61c.id
      @cs150_to_61c.is_recommended = false
      @cs_prereqs.push(@cs150_to_61c)

      @cs152_to_61c = CoursePrereq.new
      @cs152_to_61c.course_id = @cs152.id
      @cs152_to_61c.prereq_id = @cs61c.id
      @cs152_to_61c.is_recommended = false
      @cs_prereqs.push(@cs152_to_61c)

      @cs160_to_61b = CoursePrereq.new
      @cs160_to_61b.course_id = @cs160.id
      @cs160_to_61b.prereq_id = @cs61b.id
      @cs160_to_61b.is_recommended = false
      @cs_prereqs.push(@cs160_to_61b)

      @cs161_to_61c = CoursePrereq.new
      @cs161_to_61c.course_id = @cs161.id
      @cs161_to_61c.prereq_id = @cs61c.id
      @cs161_to_61c.is_recommended = false
      @cs_prereqs.push(@cs161_to_61c)

      @cs161_to_70 = CoursePrereq.new
      @cs161_to_70.course_id = @cs161.id
      @cs161_to_70.prereq_id = @cs70.id
      @cs161_to_70.is_recommended = false
      @cs_prereqs.push(@cs161_to_70)

      @cs162_to_61b = CoursePrereq.new
      @cs162_to_61b.course_id = @cs162.id
      @cs162_to_61b.prereq_id = @cs61b.id
      @cs162_to_61b.is_recommended = false
      @cs_prereqs.push(@cs162_to_61b)

      @cs162_to_61c = CoursePrereq.new
      @cs162_to_61c.course_id = @cs162.id
      @cs162_to_61c.prereq_id = @cs61c.id
      @cs162_to_61c.is_recommended = false
      @cs_prereqs.push(@cs162_to_61c)

      @cs162_to_70 = CoursePrereq.new
      @cs162_to_70.course_id = @cs162.id
      @cs162_to_70.prereq_id = @cs70.id
      @cs162_to_70.is_recommended = false
      @cs_prereqs.push(@cs162_to_70)

      @cs164_to_61b = CoursePrereq.new
      @cs164_to_61b.course_id = @cs164.id
      @cs164_to_61b.prereq_id = @cs61b.id
      @cs164_to_61b.is_recommended = false
      @cs_prereqs.push(@cs164_to_61b)

      @cs164_to_61c = CoursePrereq.new
      @cs164_to_61c.course_id = @cs164.id
      @cs164_to_61c.prereq_id = @cs61c.id
      @cs164_to_61c.is_recommended = false
      @cs_prereqs.push(@cs164_to_61c)

      # @cs168_to_61b = CoursePrereq.new
      # @cs168_to_61b.course_id = @cs168.id
      # @cs168_to_61b.prereq_id = @cs61b.id
      # @cs168_to_61b.is_recommended = false
      # @cs_prereqs.push(@cs168_to_61b)

      @cs169_to_61b = CoursePrereq.new
      @cs169_to_61b.course_id = @cs169.id
      @cs169_to_61b.prereq_id = @cs61b.id
      @cs169_to_61b.is_recommended = false
      @cs_prereqs.push(@cs169_to_61b)

      @cs169_to_61c = CoursePrereq.new
      @cs169_to_61c.course_id = @cs169.id
      @cs169_to_61c.prereq_id = @cs61c.id
      @cs169_to_61c.is_recommended = false
      @cs_prereqs.push(@cs169_to_61c)

      @cs169_to_70 = CoursePrereq.new
      @cs169_to_70.course_id = @cs169.id
      @cs169_to_70.prereq_id = @cs70.id
      @cs169_to_70.is_recommended = false
      @cs_prereqs.push(@cs169_to_70)

      @cs170_to_61b = CoursePrereq.new
      @cs170_to_61b.course_id = @cs170.id
      @cs170_to_61b.prereq_id = @cs61b.id
      @cs170_to_61b.is_recommended = false
      @cs_prereqs.push(@cs170_to_61b)

      @cs170_to_70 = CoursePrereq.new
      @cs170_to_70.course_id = @cs170.id
      @cs170_to_70.prereq_id = @cs70.id
      @cs170_to_70.is_recommended = false
      @cs_prereqs.push(@cs170_to_70)

      @cs172_to_170 = CoursePrereq.new
      @cs172_to_170.course_id = @cs172.id
      @cs172_to_170.prereq_id = @cs170.id
      @cs172_to_170.is_recommended = false
      @cs_prereqs.push(@cs172_to_170)

      @cs174_to_170 = CoursePrereq.new
      @cs174_to_170.course_id = @cs174.id
      @cs174_to_170.prereq_id = @cs170.id
      @cs174_to_170.is_recommended = false
      @cs_prereqs.push(@cs174_to_170)

      @cs176_to_170 = CoursePrereq.new
      @cs176_to_170.course_id = @cs176.id
      @cs176_to_170.prereq_id = @cs170.id
      @cs176_to_170.is_recommended = false
      @cs_prereqs.push(@cs176_to_170)

      @cs184_to_61b = CoursePrereq.new
      @cs184_to_61b.course_id = @cs184.id
      @cs184_to_61b.prereq_id = @cs61b.id
      @cs184_to_61b.is_recommended = false
      @cs_prereqs.push(@cs184_to_61b)

      @cs186_to_61b = CoursePrereq.new
      @cs186_to_61b.course_id = @cs186.id
      @cs186_to_61b.prereq_id = @cs61b.id
      @cs186_to_61b.is_recommended = false
      @cs_prereqs.push(@cs186_to_61b)

      @cs186_to_61c = CoursePrereq.new
      @cs186_to_61c.course_id = @cs186.id
      @cs186_to_61c.prereq_id = @cs61c.id
      @cs186_to_61c.is_recommended = false
      @cs_prereqs.push(@cs186_to_61c)

      @cs188_to_61b = CoursePrereq.new
      @cs188_to_61b.course_id = @cs188.id
      @cs188_to_61b.prereq_id = @cs61b.id
      @cs188_to_61b.is_recommended = false
      @cs_prereqs.push(@cs188_to_61b)

      @cs188_to_70 = CoursePrereq.new
      @cs188_to_70.course_id = @cs188.id
      @cs188_to_70.prereq_id = @cs70.id
      @cs188_to_70.is_recommended = false
      @cs_prereqs.push(@cs188_to_70)

      @cs188_to_170 = CoursePrereq.new
      @cs188_to_170.course_id = @cs188.id
      @cs188_to_170.prereq_id = @cs170.id
      @cs188_to_170.is_recommended = true
      @cs_prereqs.push(@cs188_to_170)

      @cs189_to_188 = CoursePrereq.new
      @cs189_to_188.course_id = @cs189.id
      @cs189_to_188.prereq_id = @cs188.id
      @cs189_to_188.is_recommended = false
      @cs_prereqs.push(@cs189_to_188)

      # ee prereqs
      @ee126_to_20 = CoursePrereq.new
      @ee126_to_20.course_id = @ee126.id
      @ee126_to_20.prereq_id = @ee20.id
      @ee126_to_20.is_recommended = false
      @ee_prereqs.push(@ee126_to_20)

      @ee120_to_20 = CoursePrereq.new
      @ee120_to_20.course_id = @ee120.id
      @ee120_to_20.prereq_id = @ee20.id
      @ee120_to_20.is_recommended = false
      @ee_prereqs.push(@ee120_to_20)

      @eec145b_to_20 = CoursePrereq.new
      @eec145b_to_20.course_id = @eec145b.id
      @eec145b_to_20.prereq_id = @ee20.id
      @eec145b_to_20.is_recommended = false
      @ee_prereqs.push(@eec145b_to_20)

      @eec145b_to_120 = CoursePrereq.new
      @eec145b_to_120.course_id = @eec145b.id
      @eec145b_to_120.prereq_id = @ee120.id
      @eec145b_to_120.is_recommended = false
      @ee_prereqs.push(@eec145b_to_120)

      @ee144_to_20 = CoursePrereq.new
      @ee144_to_20.course_id = @ee144.id
      @ee144_to_20.prereq_id = @ee20.id
      @ee144_to_20.is_recommended = false
      @ee_prereqs.push(@ee144_to_20)

      @ee149_to_20 = CoursePrereq.new
      @ee149_to_20.course_id = @ee149.id
      @ee149_to_20.prereq_id = @ee20.id
      @ee149_to_20.is_recommended = false
      @ee_prereqs.push(@ee149_to_20)

      @ee105_to_40 = CoursePrereq.new
      @ee105_to_40.course_id = @ee105.id
      @ee105_to_40.prereq_id = @ee40.id
      @ee105_to_40.is_recommended = false
      @ee_prereqs.push(@ee105_to_40)

      @ee117_to_40 = CoursePrereq.new
      @ee117_to_40.course_id = @ee117.id
      @ee117_to_40.prereq_id = @ee40.id
      @ee117_to_40.is_recommended = false
      @ee_prereqs.push(@ee117_to_40)

      @ee130_to_40 = CoursePrereq.new
      @ee130_to_40.course_id = @ee130.id
      @ee130_to_40.prereq_id = @ee40.id
      @ee130_to_40.is_recommended = false
      @ee_prereqs.push(@ee130_to_40)

      @ee134_to_40 = CoursePrereq.new
      @ee134_to_40.course_id = @ee134.id
      @ee134_to_40.prereq_id = @ee40.id
      @ee134_to_40.is_recommended = false
      @ee_prereqs.push(@ee134_to_40)

      @ee143_to_40 = CoursePrereq.new
      @ee143_to_40.course_id = @ee143.id
      @ee143_to_40.prereq_id = @ee40.id
      @ee143_to_40.is_recommended = false
      @ee_prereqs.push(@ee143_to_40)

      @eec145l_to_40 = CoursePrereq.new
      @eec145l_to_40.course_id = @eec145l.id
      @eec145l_to_40.prereq_id = @ee40.id
      @eec145l_to_40.is_recommended = false
      @ee_prereqs.push(@eec145l_to_40)

      # @eec145m_to_40 = CoursePrereq.new
      # @eec145m_to_40.course_id = @eec145m.id
      # @eec145m_to_40.prereq_id = @ee40.id
      # @eec145m_to_40.is_recommended = false
      # @ee_prereqs.push(@eec145m_to_40)

      @ee137b_to_137a = CoursePrereq.new
      @ee137b_to_137a.course_id = @ee137b.id
      @ee137b_to_137a.prereq_id = @ee137a.id
      @ee137b_to_137a.is_recommended = false
      @ee_prereqs.push(@ee137b_to_137a)

      @ee140_to_105 = CoursePrereq.new
      @ee140_to_105.course_id = @ee140.id
      @ee140_to_105.prereq_id = @ee105.id
      @ee140_to_105.is_recommended = false
      @ee_prereqs.push(@ee140_to_105)

      @ee141_to_40 = CoursePrereq.new
      @ee141_to_40.course_id = @ee141.id
      @ee141_to_40.prereq_id = @ee40.id
      @ee141_to_40.is_recommended = false
      @ee_prereqs.push(@ee141_to_40)

      @ee113_to_105 = CoursePrereq.new
      @ee113_to_105.course_id = @ee113.id
      @ee113_to_105.prereq_id = @ee105.id
      @ee113_to_105.is_recommended = false
      @ee_prereqs.push(@ee113_to_105)

      @ee142_to_20 = CoursePrereq.new
      @ee142_to_20.course_id = @ee142.id
      @ee142_to_20.prereq_id = @ee20.id
      @ee142_to_20.is_recommended = false
      @ee_prereqs.push(@ee142_to_20)

      @ee142_to_140 = CoursePrereq.new
      @ee142_to_140.course_id = @ee142.id
      @ee142_to_140.prereq_id = @ee140.id
      @ee142_to_140.is_recommended = false
      @ee_prereqs.push(@ee142_to_140)

      @ee121_to_120 = CoursePrereq.new
      @ee121_to_120.course_id = @ee121.id
      @ee121_to_120.prereq_id = @ee120.id
      @ee121_to_120.is_recommended = false
      @ee_prereqs.push(@ee121_to_120)

      @ee123_to_120 = CoursePrereq.new
      @ee123_to_120.course_id = @ee123.id
      @ee123_to_120.prereq_id = @ee120.id
      @ee123_to_120.is_recommended = false
      @ee_prereqs.push(@ee123_to_120)

      @eec125_to_120 = CoursePrereq.new
      @eec125_to_120.course_id = @eec125.id
      @eec125_to_120.prereq_id = @ee120.id
      @eec125_to_120.is_recommended = false
      @ee_prereqs.push(@eec125_to_120)

      @eec128_to_120 = CoursePrereq.new
      @eec128_to_120.course_id = @eec128.id
      @eec128_to_120.prereq_id = @ee120.id
      @eec128_to_120.is_recommended = false
      @ee_prereqs.push(@eec128_to_120)

      @ee129_to_120 = CoursePrereq.new
      @ee129_to_120.course_id = @ee129.id
      @ee129_to_120.prereq_id = @ee120.id
      @ee129_to_120.is_recommended = false
      @ee_prereqs.push(@ee129_to_120)

      @ee121_to_126 = CoursePrereq.new
      @ee121_to_126.course_id = @ee121.id
      @ee121_to_126.prereq_id = @ee126.id
      @ee121_to_126.is_recommended = false
      @ee_prereqs.push(@ee121_to_126)
    end

    def save_prereqs
      @cs_prereqs.each do |c|
        c.save
      end
      @ee_prereqs.each do |e|
        e.save
      end
    end

    def run_all
      gen_cs_types
      gen_ee_types
      save_cs_types
      save_ee_types
      gen_courses
      save_classes
      gen_prereqs
      save_prereqs
    end
  end
end
