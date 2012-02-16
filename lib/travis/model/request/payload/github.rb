class Request
  module Payload
    module Github
      autoload :Base, 'travis/model/request/payload/github/base'
      autoload :Push, 'travis/model/request/payload/github/push'
      autoload :PullRequest, 'travis/model/request/payload/github/pull_request'
    end
  end
end
  