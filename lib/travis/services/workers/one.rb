module Travis
  module Services
    module Workers
      class One < Base
        def run
          scope(:worker).find(params[:id])
        end
      end
    end
  end
end
