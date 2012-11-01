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
              req.headers['Authorization'] = authorization
            end
            response.success? ? log_success(response) : log_error(response)
          end

          def authorization
            Digest::SHA2.hexdigest(repository.values_at(:owner_name, :name).join('/') + params[:token])
          end

          def log_success(response)
            info "Successfully notified #{response.env[:url].to_s}."
          end

          def log_error(response)
            error "Could not notify #{response.env[:url].to_s}. Status: #{response.status} (#{response.body.inspect})"
          end

          Instruments::Task.attach_to(self)
      end
    end
  end
end
