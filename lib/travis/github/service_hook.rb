require 'octokit'

# Hides a few ugly bits of logic on top of Octokit required for adding and
# removing service hooks on Github as well as fetching repositories for a
# given user.
module Travis
  module Github
    module ServiceHook
      class << self
        def add(owner_name, name, oauth_token, data)
          client = Octokit::Client.new(:oauth_token => oauth_token)
          client.subscribe_service_hook("#{owner_name}/#{name}", 'Travis', data)
        rescue Octokit::UnprocessableEntity => e
          # TODO log these events
          raise ServiceHookError, 'error subscribing to the GitHub push event'
        rescue Octokit::Unauthorized => e
          raise ServiceHookError, 'error authorizing with given GitHub OAuth token'
        end

        def remove(owner_name, name, oauth_token)
          client = Octokit::Client.new(:oauth_token => oauth_token)
          client.unsubscribe_service_hook("#{owner_name}/#{name}", 'Travis')
        rescue Octokit::UnprocessableEntity => e
          # TODO log this event
          raise ServiceHookError, 'error unsubscribing from the GitHub push event'
        end
      end
    end
  end
end
