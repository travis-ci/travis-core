# encoding: utf-8
require 'spec_helper'

module Travis
  describe Chunkifier do
    let(:chunk_size) { 15 }
    let(:chunk_split_size) { 5 }
    let(:subject) { Chunkifier.new(content, chunk_size, :json => true) }

    context 'with newlines' do
      let(:content) { "01\n234501\n234501\n2345" }

      its(:parts) { should == ["01\n234501\n2", "34501\n2345"] }
    end

    context 'with UTF-8 chars' do
      let(:chunk_split_size) { 1 }
      let(:content) { "𤭢abcą" }

      its(:parts) { should == ["𤭢abc", "ą"] }

      it 'should keep parts under chunk_size taking into account conversion to json and bytes' do
        subject.parts.map { |p| p.to_json.bytesize }.should == [11, 8]
      end
    end

    context 'with bigger chunk_size' do
      let(:chunk_size) { 100 }
      let(:content) { "01\nąąąą" * 1000 }

      it 'should keep parts under chunk_size taking into account conversion to json and bytes' do
        subject.parts.all? { |p| p.to_json.bytesize <= 100 }.should be_true
      end
    end
  end
end
