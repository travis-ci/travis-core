module Travis
  module Services
    class UpdateAnnotation < Base
      register :update_annotation

      def run
        if annotation_provider
          annotation.update_attributes!(attributes)

          annotation
        end
      end

      private

      def annotation
        annotation_provider.annotation_for_job(params[:job_id])
      end

      def annotation_provider
        AnnotationProvider.authenticate_provider(params[:username], params[:key])
      end

      def attributes
        params.slice(:description, :url)
      end
    end
  end
end
