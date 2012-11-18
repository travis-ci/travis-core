module Travis
  module Services
    class FindRepo < Base
      def run(options = {})
        result
      end

      def updated_at
        result.try(:updated_at)
      end

      private

        def result
          @result ||= scope(:repository).find_by(params)
        end
    end
  end
end
