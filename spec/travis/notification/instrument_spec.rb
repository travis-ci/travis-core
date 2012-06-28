require 'spec_helper'
require 'mail'

describe Travis::Notification::Instrument do
  let(:mail) { Mail::Message.new }
  it 'encodes emails as string' do
    instrument = Travis::Notification::Instrument.new("", :result => mail)
    instrument.config[:result].should == mail.to_s
  end

  it 'encodes nested structures properly' do
    instrument = Travis::Notification::Instrument.new("", :result => [{:x => mail}])
    instrument.config[:result].should == [{:x => mail.to_s}]
  end
end
