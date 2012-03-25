require 'spec_helper'

describe Request::Branches do
  include Request::Branches

  describe '#branch_included?' do
    it 'returns true if the included branches include the given branch' do
      stubs(:included_branches).returns(['master'])
      branch_included?('master').should be_true
    end

    it 'returns true if the given branch matches a pattern from the included branches' do
      stubs(:included_branches).returns(['/^issue-\d+$/'])
      branch_included?('issue-42').should be_true
    end

    it 'returns true if no branches are included' do
      stubs(:included_branches).returns(nil)
      branch_included?('master').should be_true
    end

    it 'returns false if the included branches do not include the given branch' do
      stubs(:included_branches).returns(['master'])
      branch_included?('staging').should be_false
    end

    it "returns false if the given branch doesn't match any pattern from the included branches" do
      stubs(:included_branches).returns(['/^issue-\d+$/'])
      branch_included?('deploy-2012.12.12').should be_false
    end
  end

  describe '#branch_excluded?' do
    it 'returns true if the excluded branches include the given branch' do
      stubs(:excluded_branches).returns(['master'])
      branch_excluded?('master').should be_true
    end

    it 'returns true if the given branch matches a pattern from the excluded branches' do
      stubs(:excluded_branches).returns(['/^issue-\d+$/'])
      branch_excluded?('issue-42').should be_true
    end

    it 'returns false if no branches are excluded' do
      stubs(:excluded_branches).returns(nil)
      branch_excluded?('master').should be_false
    end

    it 'returns false if the included branches do not include the given branch' do
      stubs(:excluded_branches).returns(['master'])
      branch_excluded?('staging').should be_false
    end

    it "returns false if the given branch doesn't match any pattern from the excluded branches" do
      stubs(:excluded_branches).returns(['/^issue-\d+$/'])
      branch_excluded?('deploy-2012.12.12').should be_false
    end
  end

  describe '#included_branches' do
    it 'returns the :only value from the branches config' do
      stubs(:branches_config).returns(:only => ['master'])
      included_branches.should == ['master']
    end
  end

  describe '#excluded_branches' do
    it 'returns the :except value from the branches config' do
      stubs(:branches_config).returns(:except => ['master'])
      excluded_branches.should == ['master']
    end
  end

  describe '#branches_config' do
    it 'returns an empty array if the config is not a Hash' do
      stubs(:config).returns(nil)
      branches_config.should == {}
    end

    it 'returns an empty array if the config does not have a :branches value' do
      stubs(:config).returns(nil)
      branches_config.should == {}
    end

    it 'returns the :branches value if it is a hash' do
      stubs(:config).returns({ :branches => { :only => ['foo', 'bar'] } })
      branches_config.should == { :only => ['foo', 'bar']}
    end

    it 'returns an array of strings if the :branches value is a string, splitted at commas and stripped' do
      stubs(:config).returns(:branches => 'foo, bar')
      branches_config.should == { :only => ['foo', 'bar']}
    end

    it 'returns an array of string if the :branches value is a hash with :only key and string value' do
      stubs(:config).returns(:branches => { :only => 'foo, bar' })
      branches_config.should == { :only => ['foo', 'bar'] }
    end

    it 'returns an array of string if the :branches value is a hash with :except key and string value' do
      stubs(:config).returns(:branches => { :except => 'foo, bar' })
      branches_config.should == { :except => ['foo', 'bar'] }
    end
  end

  describe '#split_branches' do
    it "returns object unchanged if it's not a String" do
      obj = Object.new
      split_branches(obj).should == obj
    end

    it 'returns splitted at commas array of branches if the argument is a String' do
      split_branches('foo, bar, /^baz$/').should == ['foo', 'bar', '/^baz$/']
    end

    it 'strips branches names if a String is passed' do
      split_branches(' foo ,  bar  , /^baz$/ ').should == ['foo', 'bar', '/^baz$/']
    end
  end

  describe '#regexp_or_string' do
    it 'returns regexp object if passed a regexp string' do
      regexp_or_string('/^foo$/').should == /^foo$/
    end

    it "returns unchanged string if it's not a regexp string" do
      regexp_or_string('foo').should == 'foo'
    end
  end

  describe '#includes_match?' do
    it 'returns false for empty list' do
      includes_match?([], 'foo').should be_false
    end

    it 'returns true is the given string matches a string from the list' do
      includes_match?(%w(foo bar baz), 'bar').should be_true
    end

    it 'returns false if none of the strings from the list matches the given string' do
      includes_match?(%w(foo bar), 'baz').should be_false
    end

    it 'returns true if the given string matches regexp from the list' do
      includes_match?(%w(/^foo$/ bar baz), 'foo').should be_true
    end
  end
end
