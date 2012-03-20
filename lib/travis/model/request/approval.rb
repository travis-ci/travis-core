class Request
  module Approval
    def accept?
      commit.present? &&
        !repository.private? &&
        !repository.rails_fork? &&
        !commit.skipped? &&
        !commit.github_pages?
    end
  end
end
