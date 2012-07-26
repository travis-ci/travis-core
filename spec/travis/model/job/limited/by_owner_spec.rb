require 'spec_helper'

describe Job::Limited::ByOwner do
  def limit(queue)
    Job::Limited::ByOwner.new(queue)
  end

  describe 'limited?' do
    it 'returns true if the number of running jobs is greater then max_job' do
    end

    it 'returns true if the number of running jobs is equal to max_job' do
    end

    it 'returns true if the number of running jobs is lesser than max_job' do
    end
  end

  describe 'custom_queue?' do
    it 'returns true for rails/rails' do
      limit('rails/rails').custom_queue?.should be_true
    end

    it 'returns true for spree/spree' do
      limit('spree/spree').custom_queue?.should be_true
    end

    it 'returns false for travis-ci/travis-ci' do
      limit('travis-ci/travis-ci').custom_queue?.should be_false
    end
  end
end

