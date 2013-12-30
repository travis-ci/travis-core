class BuildsTag < ActiveRecord::Base
  belongs_to :build
  belongs_to :tag

  validates :build_id, uniqueness: { scope: :tag_id }
end
