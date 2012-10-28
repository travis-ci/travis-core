module Travis
  module Notification
    class Instrument
      module Services
        module Github
          class FindAdmin < Instrument
            def run_completed
              publish(
                :msg => "#{target.class.name}#find for #{target.repository.slug}: #{result.login}",
                :result => result
              )
            end
          end

          class FetchConfig < Instrument
            def run_completed
              config_url = target.url.gsub(/\?access_token=\w*/, '?access_token=[secure]')
              publish(
                :msg => "#{target.class.name}#fetch #{config_url}",
                :url => target.url,
                :result => result
              )
            end
          end

          module SyncUser
            class Organizations < Instrument
              def run_completed
                format = lambda do |orgs|
                  orgs.map { |org| { :id => org.id, :login => org.login } }
                end

                publish(
                  :msg => %(#{target.class.name}#run for #<User id=#{target.user.id} login="#{target.user.login}">),
                  :result => { :synced => format.call(result[:synced]), :removed => format.call(result[:removed]) }
                )
              end

              def fetch_completed
                publish(
                  :msg => %(#{target.class.name}#fetch for #<User id=#{target.user.id} login="#{target.user.login}">),
                  :result => result
                )
              end
            end

            class Repositories < Instrument
              def run_completed
                format = lambda do |repos|
                  repos.map { |repo| { :id => repo.id, :owner => repo.owner_name, :name => repo.name } }
                end

                publish(
                  :msg => %(#{target.class.name}#run for #<User id=#{target.user.id} login="#{target.user.login}">),
                  :resources => target.resources,
                  :result => { :synced => format.call(result[:synced]), :removed => format.call(result[:removed]) }
                )
              end

              def fetch_completed
                publish(
                  :msg => %(#{target.class.name}#fetch for #<User id=#{target.user.id} login="#{target.user.login}">),
                  :resources => target.resources,
                  :result => result
                )
              end
            end
          end
        end
      end
    end
  end
end
