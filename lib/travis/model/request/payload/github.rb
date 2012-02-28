class Request
  module Payload
    module Github
      autoload :GenericEvent, 'travis/model/request/payload/github/generic_event'
      autoload :Push,         'travis/model/request/payload/github/push'
      autoload :PullRequest,  'travis/model/request/payload/github/pull_request'
    end
  end
end
