# encoding: utf-8
require 'spec_helper'

module Travis
  describe Chunkifier do
    let(:chunk_size) { 3 }
    let(:subject) { Chunkifier.new(content, chunk_size) }

    context 'with newlines' do
      let(:content) { "01\n2345" }

      its(:parts) { should == ["01\n", "234", "5"] }
    end

    context 'with multibyte characters in the middle of the chunk' do
      let(:content) { "ab𤭢" }
      let(:chunk_size) { 4 }

      its(:parts) { should == ["ab", "𤭢"] }
    end

    context 'with a start byte as a first character of a chunk' do
      let(:content) { "abcd𤭢" }
      let(:chunk_size) { 4 }

      its(:parts) { should == ["abcd", "𤭢"] }
    end

    context 'with a lot of carrying' do
      let(:content) { "ab𤭢𤭢𤭢𤭢" }
      let(:chunk_size) { 4 }

      its(:parts) { should == ["ab", "𤭢", "𤭢", "𤭢", "𤭢" ] }
    end

    context 'with mixed size chars' do
      let(:content) { "ab𤭢ąćó" }
      let(:chunk_size) { 4 }

      its(:parts) { should == ["ab", "𤭢", "ąć", "ó" ] }
    end
  end
end
