module Travis
  module Services
    module Users
      class Update < Base
        # TODO how to figure these out
        LOCALES = %w(en es fr ja eb nl pl pt-Br ru)

        attr_reader :result

        def run
          @result = current_user.update_attributes!(attributes) if valid_locale?
          true
        end

        def messages
          messages = []
          if result
            messages << { :notice => "Your profile was successfully updated." }
          else
            messages << { :error => 'Your profile could not be updated.' }
          end
          messages
        end

        private

          def attributes
            params.slice(:locale)
          end

          def valid_locale?
            LOCALES.include?(params[:locale])
          end
      end
    end
  end
end
