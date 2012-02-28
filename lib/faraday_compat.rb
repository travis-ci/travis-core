# Copyright (c) 2009 rick olson, zack hobson
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
# of the Software, and to permit persons to whom the Software is furnished to do
# so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'faraday'

if Faraday::VERSION < '0.8.0'
  $stderr.puts "please update faraday"

  # https://github.com/technoweenie/faraday/blob/master/lib/faraday/request/basic_authentication.rb
  require 'base64'

  module Faraday
    class Request::BasicAuthentication < Faraday::Middleware
      def initialize(app, login, pass)
        super(app)
        @header_value = "Basic #{Base64.encode64([login, pass].join(':')).gsub("\n", '')}"
      end

      def call(env)
        unless env[:request_headers]['Authorization']
          env[:request_headers]['Authorization'] = @header_value
        end
        @app.call(env)
      end
    end
  end

  # https://github.com/technoweenie/faraday/blob/master/lib/faraday/request/retry.rb
  module Faraday
    class Request::Retry < Faraday::Middleware
      def initialize(app, retries = 2)
        @retries = retries
        super(app)
      end

      def call(env)
        retries = @retries
        begin
          @app.call(env)
        rescue StandardError, Timeout::Error
          if retries > 0
            retries -= 1
            retry
          end
          raise
        end
      end
    end
  end

  # https://github.com/technoweenie/faraday/blob/master/lib/faraday/request/token_authentication.rb
  module Faraday
    class Request::TokenAuthentication < Faraday::Middleware
      def initialize(app, token, options={})
        super(app)

        values = ["token=#{token.to_s.inspect}"]
        options.each do |key, value|
          values << "#{key}=#{value.to_s.inspect}"
        end
        comma = ",\n#{' ' * ('Authorization: Token '.size)}"
        @header_value = "Token #{values * comma}"
      end

      def call(env)
        unless env[:request_headers]['Authorization']
          env[:request_headers]['Authorization'] = @header_value
        end
        @app.call(env)
      end
    end
  end

  # https://github.com/technoweenie/faraday/blob/master/lib/faraday/request.rb
  Faraday::Request.register_lookup_modules \
      :url_encoded => :UrlEncoded,
      :multipart   => :Multipart,
      :retry       => :Retry,
      :basic_auth  => :BasicAuthentication,
      :token_auth  => :TokenAuthentication
end
