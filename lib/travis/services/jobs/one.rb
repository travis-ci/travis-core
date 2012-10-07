module Travis
  module Services
    module Jobs
      class One < Base
        def run
          job = scope(:job).includes(:commit).find_by_id(params[:id])
          # ActiveRecord::Associations::Preloader.new(job, :log, :select => [:id, :job_id]).run
          # TODO somehow move sponsor extraction to the client
          ActiveRecord::Associations::Preloader.new(job, :log).run
          job
        end
      end
    end
  end
end
