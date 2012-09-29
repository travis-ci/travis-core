module Travis
  module Services
    module Artifacts
      class One < Base
        def run
          scope(:artifact).find(params[:id])
        end
      end
    end
  end
end
