module Travis
  module Services
    class User < Base
      # TODO how to figure these out
      LOCALES = %w(en es fr ja eb nl pl pt-Br ru)

      def sync
        unless current_user.syncing?
          publisher.publish({ user_id: current_user.id }, type: 'sync')
          current_user.update_column(:is_syncing, true)
        end
      end

      def update_locale(locale)
        current_user.update_column(:locale, locale) if valid_locale?(locale)
      end

      private

        def publisher
          Travis::Amqp::Publisher.new('sync.user')
        end

        def valid_locale?(locale)
          LOCALES.include?(locale)
        end
    end
  end
end

