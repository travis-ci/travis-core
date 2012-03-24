require 'active_record'

class Url < ActiveRecord::Base

  validates :url,
    :presence => true,
    :uniqueness => true
  validates :code,
    :presence => true,
    :uniqueness => true

  before_validation :set_code, :on => :create


  private
  def set_code
    self.code = Base64.urlsafe_encode64([Digest::MD5.hexdigest(url).to_i(16)].pack("N")).sub(/==\n?$/, '')
  end
end
