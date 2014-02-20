module Travis
  class RepositoryNotFoundError < StandardError
    def initialize
      super("Repository could not be found")
    end
  end
end
