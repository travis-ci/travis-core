require 'active_record'

# Encapsulates a commit that a Build belongs to (and that a Github Request
# referred to).
class Commit < ActiveRecord::Base
  has_one :request
  belongs_to :repository

  validates :commit, :branch, :message, :committed_at, :presence => true

  def pull_request?
    ref =~ %r(^refs/pull/\d+/merge$)
  end

  def pull_request_number
    if pull_request? && (num = ref.scan(%r(^refs/pull/(\d+)/merge$)).flatten.first)
      num.to_i
    end
  end
end
