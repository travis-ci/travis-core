module Travis
  module Notification
    class Instrument
      class Github < Instrument
        class Config < Github
          def fetch_completed
            publish(
              :msg => "#{target.class.name}#fetch #{target.url}",
              :url => target.url
            )
          end
        end

        class Repositories < Github
          def fetch_completed
            publish(
              :msg => %(#{target.class.name}#fetch for #<User id=#{target.user.id} login="#{target.user.login}">)
            )
          end
        end

        module Sync
          class Organizations < Github
            def run_completed
              publish(
                :msg => %(#{target.class.name}#run for #<User id=#{target.user.id} login="#{target.user.login}">)
              )
            end
          end

          class Repositories < Github
            def run_completed
              publish(
                :msg => %(#{target.class.name}#run for #<User id=#{target.user.id} login="#{target.user.login}">)
              )
            end
          end
        end

        private

          def publish(event)
            super event.merge(:result => result)
          end
      end
    end
  end
end
