module Travis
  module Services
    class Artifacts < Base
      def find_one(params)
        scope(:artifact).find(params[:id])
      end
    end
  end
end
