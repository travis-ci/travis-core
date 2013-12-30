class BuildsBranch < Travis::Model
  belongs_to :build
  belongs_to :branch

  validates :build_id, uniqueness: { scope: :branch_id }
end
