module AlumnisHelper
  def pretty_salary(sal)
    "$" + sal.to_s.reverse.gsub(/(\d{3})/,'\1,').reverse.sub(/^,/,'')
  end
end
