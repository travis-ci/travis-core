require 'active_record'
require 'simple_states'

# Models an incoming request. The only supported source for requests currently is Github.
#
# The Request will be configured by fetching `.travis.yml` from the Github API
# and needs to be approved based on the configuration. Once approved the
# Request creates a Build.
class Request < Travis::Model
  autoload :Approval, 'travis/model/request/approval'
  autoload :Branches, 'travis/model/request/branches'
  autoload :States,   'travis/model/request/states'

  include States, SimpleStates

  serialize :token, Travis::Model::EncryptedColumn.new(disable: true)

  class << self
    def last_by_head_commit(head_commit)
      where(head_commit: head_commit).order(:id).last
    end
  end

  belongs_to :commit
  belongs_to :repository
  belongs_to :owner, polymorphic: true
  has_many   :builds
  has_many   :events, as: :source

  validates :repository_id, presence: true

  serialize :config
  serialize :payload

  def event_type
    read_attribute(:event_type) || 'push'
  end

  def pull_request?
    event_type == 'pull_request'
  end

  def pull_request_title
    if pull_request? && payload
      payload['pull_request'] && payload['pull_request']['title']
    end
  end

  def pull_request_number
    if pull_request? && payload
      payload['pull_request'] && payload['pull_request']['number']
    end
  end

  def config_url
    "https://api.github.com/repos/#{repository.slug}/contents/.travis.yml?ref=#{commit.commit}"
  end

  def same_repo_pull_request?
    begin
      payload = Hashr.new(self.payload)
      head_repo = payload.try(:pull_request).try(:head).try(:repo).try(:full_name)
      base_repo = payload.try(:pull_request).try(:base).try(:repo).try(:full_name)
      head_repo && base_repo && head_repo == base_repo
    rescue => e
      puts "[request:#{id}] Couldn't determine whether pull request is from the same repository: #{e.message}"
      false
    end
  end
end
