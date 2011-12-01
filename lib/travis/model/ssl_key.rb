class SslKey < ActiveRecord::Base
  belongs_to :repository

  validates :repository_id,
    :presence => true,
    :uniqueness => true
  validates :public_key,
    :presence => true
  validates :private_key,
    :presence => true

  before_validation :generate_keys, :on => :create

  private
  def generate_keys
    keys = OpenSSL::PKey::RSA.generate(1024)
    self.public_key = keys.public_key
    self.private_key = keys.to_pem
  end
end
