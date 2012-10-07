module Travis
  module Services
    module Jobs
      class All < Base
        def run
          jobs = params[:ids] ? by_ids : by_params
          jobs = jobs.includes(:commit)
          ActiveRecord::Associations::Preloader.new(jobs, :log, :select => [:id, :job_id]).run
          jobs
        end

        private

          def by_ids
            scope(:job).where(:id => params[:ids])
          end

          def by_params
            scope(:job).queued(params[:queue])
          end
      end
    end
  end
end
