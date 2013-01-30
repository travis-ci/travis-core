module Travis
  module Services
    class UpdateArtifact < Base
      extend Travis::Instrumentation

      register :update_artifact

      def run
        artifact = run_service(:find_artifact, id: params[:id])
        artifact.update_attributes(archived_at: params[:archived_at], archive_verified: params[:archive_verified]) if artifact
      end
      instrument :run

      class Instrument < Notification::Instrument
        def run_completed
          publish(
            msg: "for #<Artifact id=#{target.params[:id]}> params=#{target.params.inspect}",
            object_type: 'Artifact',
            object_id: target.params[:id],
            params: target.params,
            result: result
          )
        end
      end
      Instrument.attach_to(self)
    end
  end
end
