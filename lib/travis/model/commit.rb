require 'active_record'

# Encapsulates a commit that a Build belongs to (and that a Github Request
# referred to).

class Commit < ActiveRecord::Base
  belongs_to :repository
  validates :commit, :branch, :message, :committed_at, :presence => true
end
