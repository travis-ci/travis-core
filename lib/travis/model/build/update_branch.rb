class Build
  module UpdateBranch
    def update_branch
      Branch.update_build(repository, branch)
    end
  end
end
