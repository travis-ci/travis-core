module Travis
  module Services
    module Jobs
      class All < Base
        def run
          params[:ids] ? by_ids : by_params
        end

        private

          def by_ids
            scope(:job).where(:id => params[:ids])
          end

          def by_params
            scope(:job).queued(params[:queue]).includes(:commit)
          end
      end
    end
  end
end
