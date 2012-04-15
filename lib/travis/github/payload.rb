module Travis
  module Github
    module Payload
      autoload :Push,         'travis/github/payload/push'
      autoload :PullRequest,  'travis/github/payload/pull_request'

      class << self
        def for(type, data)
          const = const_get(type.gsub('-', '_').camelize)
          const.new(data)
        end
      end
    end
  end
end
