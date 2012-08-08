require 'gh'

class Organization < ActiveRecord::Base
  has_many :memberships
  has_many :users, :through => :memberships
  has_many :repositories, :as => :owner
end

