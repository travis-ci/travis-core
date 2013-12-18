require 'gh'
require 'travis/model'

class Organization < Travis::Model
  has_many :memberships
  has_many :users, :through => :memberships
  has_many :repositories, :as => :owner

  def education?
    false
  end
  alias education education?
end

