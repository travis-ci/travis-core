require 'gh'

class Organization < ActiveRecord::Base
  has_many :memberships
  has_many :users, :through => :memberships
  has_many :repositories, :as => :owner

  def github_oauth_token
    users.first.try(:github_oauth_token)
  end
end

