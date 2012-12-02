module Travis
  module Services
    class FindArtifact < Base
      register :find_artifact

      def run(options = {})
        result if result
      end

      def final?
        # TODO jobs can be requeued, so finished jobs are no more final
        # # TODO keep the state on the artifact
        # result && result.job && result.job.finished?
        false
      end

      # def updated_at
      #   result.updated_at
      # end

      private

        def result
          @result ||= scope(:artifact).find_by_id(params[:id])
        end
    end
  end
end
