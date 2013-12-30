class Branch < Travis::Model
  has_many :builds_branches
  has_many :builds, through: :builds_branches

  belongs_to :repository
  belongs_to :last_build

  validates :name, uniqueness: { scope: :repository_id }
end
