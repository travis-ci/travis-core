module Travis
  module Logs
    module Services
      class Append < Travis::Services::Base
        # TODO remove this once we know aggregation works fine and the worker passes a :final flag
        FINAL = 'Done. Build script exited with:'

        register :logs_append

        def run
          create_part
          notify
        end

        private

          def create_part
            meter('logs.update') do
              puts "[warn] artifact.id is nil in :logs_append! #{self.inspect}" if artifact.id.nil?
              Artifact::Part.create!(artifact_id: artifact.id, content: chars, number: number, final: final?)
            end
          end

          def notify
            job.notify(:log, _log: chars, number: number, final: final?)
          end

          def artifact
            @artifact ||= Artifact::Log.where(job_id: job.id).select(:id).first || create_artifact
          end

          def create_artifact
            puts "[warn] had to create an artifact for job_id: #{job.id}!"
            job.create_log!
          end

          def job
            @job ||= Job::Test.find(data[:id])
          end

          def chars
            @chars ||= filter(data[:log])
          end

          def number
            data[:number]
          end

          def final?
            !!data[:final] || chars.include?(FINAL)
          end

          def data
            @data ||= params[:data].symbolize_keys
          end

          def filter(chars)
            chars.to_s.gsub("\0", '') # postgres seems to have issues with null chars
          end

          def meter(name, &block)
            Metriks.timer(name).time(&block)
          end
      end
    end
  end
end
