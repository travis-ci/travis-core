module Travis
  module UrlShortener
    autoload :Bitly, 'travis/url_shortener/bitly'

    class << self
      def create
        Bitly.create
      end
    end
  end
end