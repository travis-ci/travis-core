module Travis
  module Services
    module Jobs
      class ByIds < Base
        def run
          scope(:job).where(:id => params[:ids])
        end
      end
    end
  end
end
