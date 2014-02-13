module Travis
  module Addons
    module Hipchat
      class HttpHelper
        require 'json'
        require 'open-uri'

        API_V1_TOKEN_LENGTH = 30
        API_V2_TOKEN_LENGTH = 40
        UNSAFE_URL_CHARS = Regexp.union([URI::Parser.new.regexp[:UNSAFE], /[\$&\+,\/:;=\?@~\[\]]/])

        attr_reader :api_version, :headers, :url, :token, :room_id

        def initialize(specification)
          # specification will be in the form "API_TOKEN@HIPCHAT_ROOM_NAME_OR_ID"
          match = /^(?<token>[\w]+)@(?<room_id>[\S ]+)$/.match specification
          @token = match['token']
          @room_id = match['room_id']

          case token.length
          when API_V1_TOKEN_LENGTH
            @api_version = 'v1'
            @url = 'https://api.hipchat.com/v1/rooms/message?format=json&auth_token=%s' % [token]
          when API_V2_TOKEN_LENGTH
            @api_version = 'v2'
            @url = 'https://api.hipchat.com/v2/room/%s/notification?auth_token=%s' % [ encode(room_id), token]
            @headers = { 'Content-type' => 'application/json' }
          end
        end

        def add_content_type!(base_headers)
          case api_version
          when 'v1'
            base_headers
          when 'v2'
            base_headers.merge!(headers)
          end
        end

        def body(info)
          case api_version
          when 'v1'
            { room_id: room_id, message: info[:line], color: info[:color], from: 'Travis CI', message_format: info[:message_format] }
          when 'v2'
            { room_id: room_id, message: info[:line], color: info[:color], message_format: info[:message_format] }.to_json
          end
        end

        def encode(str)
          URI::encode(str, UNSAFE_URL_CHARS)
        end

      end
    end
  end
end