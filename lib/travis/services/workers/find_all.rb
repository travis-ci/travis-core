module Travis
  module Services
    module Workers
      class FindAll < Base
        def run
          scope(:worker).order(:host, :name)
        end
      end
    end
  end
end
