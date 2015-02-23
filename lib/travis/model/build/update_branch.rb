class Build
  module UpdateBranch
    def update_branch(event)
      Branch.update_build(repository, branch)
    end
  end
end
