module Travis
  module Notification
    class Instrument
      module Github
        class Config < Instrument
          def fetch
            publish(
              :msg => "#{target.class.name}#fetch #{target.url}",
              :url => target.url
            )
          end
        end

        class Repositories < Instrument
          def fetch
            publish(
              :msg => %(#{target.class.name}#fetch for #<User id=#{target.user.id} login="#{target.user.login}">)
            )
          end
        end

        module Sync
          class Organizations < Instrument
            def run
              publish(
                :msg => %(#{target.class.name}#run for #<User id=#{target.user.id} login="#{target.user.login}">)
              )
            end
          end

          class Repositories < Instrument
            def run
              publish(
                :msg => %(#{target.class.name}#run for #<User id=#{target.user.id} login="#{target.user.login}">)
              )
            end
          end
        end
      end
    end
  end
end
