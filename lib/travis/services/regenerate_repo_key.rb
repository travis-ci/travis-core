module Travis
  module Services
    class RegenerateRepoKey < Base
      register :regenerate_repo_key

      def run(options = {})
        if repo && accept?
          regenerate
          repo
        end
      end

      def accept?
        push_permission?
      end

      private

        def regenerate
          repo.regenerate_key!
        end

        def repo
          @repo ||= service(:find_repo, params).run
        end

        def push_permission?
          current_user.permission?(:push, :repository_id => repo.id)
        end

    end
  end
end
