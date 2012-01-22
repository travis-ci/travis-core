require 'spec_helper'
require 'support/active_record'

describe Artifact::Log do
  include Support::ActiveRecord

  describe 'class methods' do
    let(:job)   { Factory.create(:test, :log => Factory.create(:log, :content => '')) }
    let(:lines) { ["line 1\n", "line 2\n", "line 3"] }

    describe ".append" do
      it "appends streamed build log chunks" do
        0.upto(2) { |ix| Artifact::Log.append(job.id, lines[ix]) }
        job.reload.log.content.should == lines.join
      end
    end
  end
end

