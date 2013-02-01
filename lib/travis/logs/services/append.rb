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
              if artifact
                Artifact::Part.create!(artifact_id: artifact.id, content: chars, number: number, final: final?)
              else
                puts "[warn] could not find an artifact for job_id: #{job_id}, number: #{number}, ignoring the log part!"
              end
            end
          end

          def notify
            job.notify(:log, _log: chars, number: number, final: final?)
          end

          def artifact
            @artifact ||= Artifact::Log.where(job_id: job.id).select(:id).first
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
