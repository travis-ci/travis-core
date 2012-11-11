require 'spec_helper'

describe Travis::Notification::Instrument do
  let(:klass) do
    Class.new(Travis::Notification::Instrument) do
      def foo_completed
        42
      end
    end
  end

  it 'calls a run_received method if defined'
  it 'calls publish if run_received is not defined'
  it 'calls a run_completed method if defined'
  it 'calls publish if run_completed is not defined'
  it 'calls a run_failed method if defined'
  it 'calls publish if run_failed is not defined'
end
