module Travis
  module Services
    module User
      class Update < Base
        # TODO how to figure these out
        LOCALES = %w(en es fr ja eb nl pl pt-Br ru)

        def run
          current_user.update_attributes!(attributes) if valid_locale?
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
