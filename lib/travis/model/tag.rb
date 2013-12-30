class Tag < ActiveRecord::Base
  has_many :builds_tags
  has_many :builds, through: :builds_tags

  belongs_to :repository
  belongs_to :last_build

  validates :name, uniqueness: { scope: :repository_id }
end
