class StaticPage < ActiveRecord::Base
  belongs_to :parent, class_name: 'StaticPage'

  # TODO: remove the uniqueness check for urls, they shouldn't need to be
  # globally unique, but currently they overwrite each other if they aren't
  validates :url,     presence: true,
                      url_format: true,
                      uniqueness: true
  validates :title,   presence: true,
                      length: { maximum: 120 }
  validates :content, presence: true
  validate  :unique_scoped_url

  def self.root_pages
    # Find all pages that do not have a parent (root pages)
    where(parent_id: nil)
  end

  def children
    # Find all pages that are children of a particular page
    self.class.where(parent_id: id)
  end

  def unique_scoped_url
    other_page = self.class.find_by_url(url)
    return unless other_page.present? and other_page.id != id and other_page.parent_id == parent_id
    errors[:base] << 'Another page already exists with this URL under the same parent'
  end
end
