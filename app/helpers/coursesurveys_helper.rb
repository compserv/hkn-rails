module CoursesurveysHelper
  # rating should be a float that represents the rating out of 1.00
  def rating_bar(rating, url=nil)
    width = (rating*100).to_int
    color = (rating > 0.75) ?  "green" : (rating > 0.5) ? "orange" : "red"
    
    # I appologize for forcing a span to be displayed as a block, I can't 
    # think of a better way of making it clickable with a link
    outer_html_options = { :class => "ratingbar" }
    inner_html_options = { :class => "subbar", :style => "width: #{width}%; background-color: #{color}; display: block" }
    if url.nil?
      content_tag(:div, outer_html_options) do
        content_tag("span", "", inner_html_options)
      end
    else
      content_tag(:div, outer_html_options) do
        link_to "URL" do
          content_tag("span", "", inner_html_options)
        end
      end
    end
  end
end
