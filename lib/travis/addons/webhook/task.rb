module Travis
  module Addons
    module Webhook

      # Sends build notifications to webhooks as defined in the configuration
      # (`.travis.yml`).
      class Task < Travis::Task
        def targets
          params[:targets]
        end

        private

          def process
            Array(targets).each { |target| send_webhook(target) }
          end

          def send_webhook(target)
            response = http.post(target) do |req|
              req.body = { payload: payload.except(:params).to_json }
              uri = URI(target)
              if uri.user && uri.password
                req.headers['Authorization'] =
                  Faraday::Request::BasicAuthentication.header(
                    URI.unescape(uri.user), URI.unescape(uri.password)
                  )
              else
                req.headers['Authorization'] = authorization
              end
              req.headers['Travis-Repo-Slug'] = repo_slug
            end
            response.success? ? log_success(response) : log_error(response)
          end

          def authorization
            Digest::SHA2.hexdigest(repo_slug + params[:token].to_s)
          end

          def log_success(response)
            info "Successfully notified #{response.env[:url].to_s}."
          end

          def log_error(response)
            error "Could not notify #{response.env[:url].to_s}. Status: #{response.status} (#{response.body.inspect})"
          end

          def repo_slug
            repository.values_at(:owner_name, :name).join('/')
          end

          Instruments::Task.attach_to(self)
      end
    end
  end
end
