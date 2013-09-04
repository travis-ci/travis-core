require 'gh'

module Travis
  module Github
    module Services
      class SyncUser < Travis::Services::Base
        class UserInfo
          attr_reader :user, :gh

          def initialize(user, gh = Github.authenticated(user))
            @user, @gh = user, gh
          end

          def run
            if user.github_id != user_info['id'].to_i
              raise "Updating User##{user.id}(login=\"#{user.login}\") failed, github_id differs. github_id on user: #{user.github_id}, github_id from data: #{user_info['id']}"
            end
            if user.login != login
              Travis.logger.info("Changing User##{user.id}'s login: current=\"#{user.login}\", new=\"#{login}\" (UserInfo)")
            end
            if user.email != email
              Travis.logger.info("Changing User##{user.id}'s email: current=\"#{user.email}\", new=\"#{email}\" (UserInfo)")
            end

            user.update_attributes!(name: name, login: login, gravatar_id: gravatar_id, email: email)
            emails = verified_emails
            emails << email unless emails.include? email
            emails.each { |e| user.emails.find_or_create_by_email!(e) }
          end

          def name
            user_info['name'].presence || user.name
          end

          def login
            user_info.fetch('login')
          end

          def gravatar_id
            user_info['gravatar_id']
          end

          def email
            user_info['email'].presence || primary_email || verified_email || user.email.presence || first_email
          end

          def verified_emails
            emails.select { |e| e["verified"] }.map { |e| e['email'] }
          end

          private

            def emails
              return [] unless user.github_scopes.include? 'user' or user.github_scopes.include? 'user:email'
              @emails ||= gh['user/emails'].to_a
            end

            def first_email
              emails.first.try(:[], 'email')
            end

            def primary_email
              emails.detect { |e| e["primary"] }.try(:[], 'email')
            end

            def verified_email
              verified_emails.first
            end

            def user_info
              @user_info ||= gh['user'].to_hash
            end
        end
      end
    end
  end
end
