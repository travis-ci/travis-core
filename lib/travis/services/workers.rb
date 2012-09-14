module Travis
  module Services
    class Workers < Base
      def find_all(params = {})
        scope(:worker).order(:host, :name)
      end

      def find_one(params = {})
        scope(:worker).find(params[:id])
      end
    end
  end
end

