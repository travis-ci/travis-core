require 'coder/cleaner/simple/encodings'

module Travis
  class Chunkifier < Struct.new(:content, :chunk_size)
    include Enumerable
    include Coder::Cleaner::Simple::Encodings::UTF_8

    def each(&block)
      parts.each(&block)
    end

    def parts
      @parts ||= split
    end

    def split
      chunks = []
      carry  = []
      content.bytes.each_slice(chunk_size) do |bytes|
        if carry.length > 0
          bytes.unshift *carry
          carry = []
        end

        if bytes.length > chunk_size
          carry = bytes.pop bytes.length - chunk_size
        end

        unless proper_end?(bytes)
          carry.unshift *last_char(bytes)
        end

        chunks << to_utf8_string(bytes)
      end

      chunks << to_utf8_string(carry) if carry.length > 0

      chunks
    end

    def to_utf8_string bytes
      bytes.pack('C*').force_encoding('utf-8')
    end

    def proper_end?(bytes)
      single_byte?(bytes.last, nil) || begin
        i = bytes.length - 1
        i-=1 while !multibyte_start?(bytes[i], nil)
        first = bytes[i]
        multibyte_size(first, nil) == bytes.length - i
      end
    end

    def last_char(bytes)
      last = []
      last.unshift bytes.pop while bytes.length > 0 && !single_byte?(bytes.last, nil)
      last
    end
  end
end
