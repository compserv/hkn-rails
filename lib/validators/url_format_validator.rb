class UrlFormatValidator < ActiveModel::EachValidator
  def validate_each(object, attribute, value)
    return if value =~ /\A[a-z\d\-\/_\s]+\z/i
    object.errors[attribute] << (options[:message] || 'is not in a valid URL format')
  end
end
