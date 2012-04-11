require 'active_record'

# Encapsulates a commit that a Build belongs to (and that a Github Request
# referred to).
class Commit < ActiveRecord::Base
  belongs_to :repository
  validates :commit, :branch, :message, :committed_at, :presence => true

  def skipped?
    message.to_s =~ /\[ci(?: |:)([\w ]*)\]/i && $1.downcase == 'skip'
  end

  def github_pages?
    ref =~ /gh[-_]pages/i
  end

  def config_url
    "https://raw.github.com/#{repository.slug}/#{commit}/.travis.yml"
  end

  def pull_request?
    ref =~ %r(^refs/pull/\d+/merge$)
  end
end
