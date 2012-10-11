module Travis
  module Services
    module Jobs
      class One < Base
        def run(options = {})
          preload(result) if result
        end

        def final?
          result.finished?
        end

        def updated_at
          result.updated_at
        end

        private

          def result
            @result ||= scope(:job).find_by_id(params[:id])
          end

          def preload(job)
            # TODO move sponsor extraction to the client
            # ActiveRecord::Associations::Preloader.new(job, :log, :select => [:id, :job_id]).run
            ActiveRecord::Associations::Preloader.new(job, :log).run
            ActiveRecord::Associations::Preloader.new(job, :commit).run
            job
          end
      end
    end
  end
end
