require 'spec_helper'

module Travis::Model
  describe EncryptedColumn do
    def encode str
      Base64.strict_encode64 str
    end

    let(:column) { EncryptedColumn.new }
    let(:iv)     { 'a' * 16 }
    let(:aes)    { stub('aes', :final => '') }
    before { column.stubs :key => 'secret-key', :encrypt? => true }

    context 'when encryption is disabled' do
      before { column.stubs :encrypt? => false }

      describe '#dump' do
        it 'does not encrypt data' do
          column.dump('123qwe').should == '123qwe'
        end
      end
    end

    context 'when prefix usage is disabled' do
      before { column.stubs :use_prefix? => false }

      describe '#load' do
        it 'decrypts data even with no prefix' do
          data = encode "to-decrypt#{iv}"

          column.expects(:create_aes).with(:decrypt, 'secret-key', iv).returns(aes)
          aes.expects(:update).with('to-decrypt').returns('decrypted')

          column.load(data).should == 'decrypted'
        end

        it 'removes prefix if prefix is still used' do
          data = encode "to-decrypt#{iv}"
          data = "#{column.prefix}#{data}"

          column.expects(:create_aes).with(:decrypt, 'secret-key', iv).returns(aes)
          aes.expects(:update).with('to-decrypt').returns('decrypted')

          column.load(data).should == 'decrypted'
        end
      end

      describe '#dump' do
        it 'attaches iv to encrypted string' do
          column.stubs(:iv => iv)
          column.expects(:create_aes).with(:encrypt, 'secret-key', iv).returns(aes)
          aes.expects(:update).with('to-encrypt').returns('encrypted')

          column.dump('to-encrypt').should == encode("encrypted#{iv}")
        end
      end
    end

    context 'when prefix usage is enabled' do
      before { column.stubs :use_prefix? => true }

      describe '#load' do
        it 'does not decrypt data if prefix is not used' do
          data = 'abc'

          column.load(data).should == data
        end

        it 'decrypts data if prefix is used' do
          data = encode "to-decrypt#{iv}"
          data = "#{column.prefix}#{data}"

          column.expects(:create_aes).with(:decrypt, 'secret-key', iv).returns(aes)
          aes.expects(:update).with('to-decrypt').returns('decrypted')

          column.load(data).should == 'decrypted'
        end
      end

      describe '#dump' do
        it 'attaches iv and prefix to encrypted string' do
          column.stubs(:iv => iv)
          column.expects(:create_aes).with(:encrypt, 'secret-key', iv).returns(aes)
          aes.expects(:update).with('to-encrypt').returns('encrypted')

          result = encode "encrypted#{iv}"
          column.dump('to-encrypt').should == "#{column.prefix}#{result}"
        end
      end
    end
  end
end
