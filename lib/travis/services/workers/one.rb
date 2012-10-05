module Travis
  module Services
    module Workers
      class One < Base
        def run
          scope(:worker).find_by_id(params[:id])
        end
      end
    end
  end
end
