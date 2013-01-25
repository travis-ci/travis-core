begin
  require 'aws/s3'
rescue LoadError => e
end
require 'active_support/core_ext/hash/slice'

module Travis
  class S3
    def initialize(config)
      AWS::S3::Base.establish_connection!(config)
    end

    def store(bucket, path, data)
      AWS::S3::S3Object.store(path, data, bucket, content_type: 'text/plain', access: :public_read)
    end
  end

  module Logs
    module Services
      class Archive < Travis::Services::Base
        extend Travis::Instrumentation

        register :archive_log

        def run
          store
          report
        end
        instrument :run

        def source_url
          "https://#{hostname('api')}/artifacts/#{params[:id]}.txt"
        end

        def report_url
          "https://#{hostname('api')}/artifacts/#{params[:id]}"
        end

        def target_host
          hostname('archive')
        end

        def target_path
          "v2/jobs/#{params[:job_id]}/log.txt" # CRAP. needs to be the job_id
        end

        private

          def store
            s3.store(target_host, target_path, log)
          end

          def report
            request(:put, report_url, archived_at: Time.now.utc) # TODO authenticate
          end

          def log
            request(:get, source_url).body.to_s
          end

          def request(method, url, data = nil)
            http.send(*[method, url, data].compact)
          rescue Faraday::Error => e
            puts "Exception while trying to #{method.inspect}: #{source_url}:"
            puts e.message, e.backtrace
            raise e
          end

          def http
            Faraday.new(ssl: Travis.config.ssl.compact) do |f|
              f.request :url_encoded
              f.adapter :net_http
            end
          end

          def s3
            S3.new(Travis.config.s3.to_hash.slice(:access_key_id, :secret_access_key))
          end

          def hostname(name)
            "#{name}#{'-staging' if Travis.env == 'staging'}.#{Travis.config.host.split('.')[-2, 2].join('.')}"
          end

          class Instrument < Notification::Instrument
            def run_completed
              publish(
                msg: "for <Log id=#{target.params[:id]}> (#{target.target_path})",
                source_url: target.source_url,
                target_path: target.target_path,
                target_host: target.target_host,
                object_type: 'Log',
                object_id: target.params[:id]
              )
            end
          end
          Instrument.attach_to(self)
      end
    end
  end
end
