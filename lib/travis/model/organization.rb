require 'gh'

class Organization < Travis::Model
  has_many :memberships
  has_many :users, :through => :memberships
  has_many :repositories, :as => :owner
end

