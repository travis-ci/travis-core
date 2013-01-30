begin
  require 'aws/s3'
rescue LoadError => e
end
require 'active_support/core_ext/hash/slice'
require 'uri'

module Travis
  class S3
    class << self
      def setup
        AWS.config(Travis.config.s3.to_hash.slice(:access_key_id, :secret_access_key))
      end
    end

    attr_reader :s3, :url

    def initialize(url)
      @s3 = AWS::S3.new
      @url = url
    end

    def store(data)
      object.write(data, content_type: 'text/plain', acl: :public_read)
    end

    def object
      @object ||= bucket.objects[URI.parse(url).path[1..-1]]
    end

    def bucket
      @bucket ||= s3.buckets[URI.parse(url).host]
    end
  end

  module Logs
    module Services
      class Archive < Travis::Services::Base
        class VerificationFailed < StandardError
          def initialize(source_url, target_url, expected, actual)
            super("Expected #{target_url} (from: #{source_url}) to have the content length #{expected.inspect}, but had #{actual.inspect}")
          end
        end

        extend Travis::Instrumentation

        register :archive_log

        def run
          archiving do
            store
            verify
          end
        end
        instrument :run

        def source_url
          "https://#{hostname('api')}/artifacts/#{params[:id]}.txt"
        end

        def report_url
          "https://#{hostname('api')}/artifacts/#{params[:id]}"
        end

        def target_url
          "http://#{hostname('archive')}/jobs/#{params[:job_id]}/log.txt"
        end

        private

          def archiving
            result = yield
            report(archived_at: Time.now, archive_verified: true)
            result
          end

          def store
            S3.setup
            s3.store(log)
          end

          def verify
            retrying(:verify) do
              expected = log.bytesize
              actual = request(:head, target_url).headers['content-length'].try(:to_i)
              raise VerificationFailed.new(target_url, source_url, expected, actual) unless expected == actual
            end
          end

          def report(data)
            retrying(:report) do
              request(:put, report_url, data, token: Travis.config.tokens.internal)
            end
          end

          def log
            @log ||= request(:get, source_url).body.to_s
          end

          def request(method, url, params = nil, headers = nil, &block)
            http.send(*[method, url, params, headers].compact, &block)
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
            S3.new(target_url)
          end

          def hostname(name)
            "#{name}#{'-staging' if Travis.env == 'staging'}.#{Travis.config.host.split('.')[-2, 2].join('.')}"
          end

          def retrying(header, times = 5)
            yield
          rescue => e
            count ||= 0
            if !params[:no_retries] && times > (count += 1)
              puts "[#{header}] retry #{count} because: #{e.message}"
              sleep count * 3
              retry
            else
              raise
            end
          end

          class Instrument < Notification::Instrument
            def run_completed
              publish(
                msg: "for <Log id=#{target.params[:id]}> (to: #{target.target_url})",
                source_url: target.source_url,
                target_url: target.target_url,
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
