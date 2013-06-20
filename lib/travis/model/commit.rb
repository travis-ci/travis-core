require 'active_record'
require 'activerecord-postgres-array'

# Encapsulates a commit that a Build belongs to (and that a Github Request
# referred to).
class Commit < Travis::Model
  has_one :request
  belongs_to :repository

  validates :commit, :committed_at, :presence => true

  validates :branch, :presence => true, :unless => :branches_column_present?
  validates :branches, :presence => true, :if => :branches_column_present?

  def branches_column_present?
    self.class.column_names.include?('branches')
  end

  def pull_request?
    ref =~ %r(^refs/pull/\d+/merge$)
  end

  def pull_request_number
    if pull_request? && (num = ref.scan(%r(^refs/pull/(\d+)/merge$)).flatten.first)
      num.to_i
    end
  end

  def range
    if compare_url && compare_url =~ /\/([0-9a-f]+\^*\.\.\.[0-9a-f]+\^*$)/
      $1
    end
  end

  def branch=(branch)
    if self.class.column_names.include?('branches')
      ActiveSupport::Deprecation.warn("branch= is deprecated, please use branches=")
      branches = self.branches || []
      unless branches.include? branch
        self.branches = (branches << branch)
      end
    else
      super
    end
  end

  def branch
    if self.class.column_names.include?('branches')
      ActiveSupport::Deprecation.warn("branch is deprecated, please use branches")
      Array(branches).first
    else
      super
    end
  end
end
