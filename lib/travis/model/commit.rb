require 'active_record'
require 'travis/retry_on'

# Encapsulates a commit that a Build belongs to (and that a Github Request
# referred to).
class Commit < Travis::Model
  has_one :request
  belongs_to :repository

  has_many :commits_tags
  has_many :tags, through: :commits_tags
  has_many :commits_branches
  has_many :branches, through: :commits_branches

  validates :commit, :committed_at, :presence => true

  include Travis::RetryOn

  def branch
    ActiveSupport::Deprecation.warn("Commit#branch should not be used as commit can contain multiple branches", caller)
    super
  end

  def tag_name
    ActiveSupport::Deprecation.warn("Commit#tag_name should not be used as commit can contain multiple tags", caller)
    if ref
      ref.scan(%r{refs/tags/(.*?)$}).flatten.first
    end
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

  def add_branch(branch_name, request)
    retry_on(ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid) do
      branch = repository.branches.where(name: branch_name).first
      unless branch
        branch = repository.branches.create!(name: branch_name, repository_id: repository_id)
      end

      unless branches.include?(branch)
        commits_branches.create!(branch_id: branch.id, commit_id: self.id, request_id: request.id)
      end

      branch
    end
  end

  def add_tag(tag_name, request)
    retry_on(ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid) do
      tag = repository.tags.where(name: tag_name).first
      unless tag
        tag = repository.tags.create!(name: tag_name, repository_id: repository_id)
      end

      unless tags.include?(tag)
        commits_tags.create!(tag_id: tag.id, commit_id: self.id, request_id: request.id)
      end

      tag
    end
  end
end
