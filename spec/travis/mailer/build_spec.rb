# encoding: utf-8
require 'spec_helper'

describe Travis::Mailer::Build do
  include Travis::Testing::Stubs

  let(:data)       { Travis::Api.data(build, :for => 'event', :version => 'v0') }
  let(:recipients) { ['owner@example.com', 'committer@example.com', 'author@example.com'] }
  let(:email)      { Travis::Mailer::Build.finished_email(data, recipients) }

  before :each do
    Travis::Mailer.setup
    I18n.reload!
    ActionMailer::Base.delivery_method = :test
    build.commit.stubs(:author_name).returns('まつもとゆきひろ a.k.a. Matz')
    Broadcast.stubs(:by_repo).with(build.repository).returns([])
  end

  describe 'finished build email notification' do
    describe 'with no custom from address configured' do
      before :each do
        Travis.config.email.delete(:from)
      end

      it 'has "notifications@[hostname]" as a from address' do
        email.from.join.should == 'notifications@travis-ci.org'
      end
    end

    describe 'with a custom from address configured' do
      before :each do
        Travis.config.email.from = 'builds@travis-ci.org'
      end

      it 'has that address as a from address' do
        email.from.join.should == 'builds@travis-ci.org'
      end
    end

    it 'delivers to the repository owner, committer and commit author' do
      email.should deliver_to(recipients)
    end

    it 'is a multipart email' do
      email.should be_multipart
    end

    it 'contains the expected text part' do
      email.text_part.body.should include_lines(%(
        Build: #2
        Status: Passed
        Duration: 1 minute and 0 seconds
        Commit: 62aae5f (master)
        Author: まつもとゆきひろ a.k.a. Matz
        Message: the commit message
        View the changeset: https://github.com/svenfuchs/minimal/compare/master...develop
        View the full build log and details: http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}
      ))
    end

    it 'contains the expected html part' do
      email.html_part.body.should include_lines(%(
        https://github.com/svenfuchs/minimal/compare/master...develop
        http://travis-ci.org/svenfuchs/minimal/builds/#{build.id}
        62aae5f (master)
        まつもとゆきひろ a.k.a. Matz
        the commit message
        1 minute and 0 seconds
      ))
    end

    context 'in HTML' do
      it 'escapes newlines in the commit message' do
        build.commit.stubs(:message).returns("bar\nbaz")
        email.deliver # inline css interceptor is called before delivery.
        email.html_part.decoded.should =~ %r(bar<br( /)?>baz) # nokogiri seems to convert <br> to <br /> on mri, but not jruby?
      end

      it 'inlines css' do
        email.deliver
        email.html_part.decoded.should =~ %r(<div[^>]+style=")
      end

      it 'correctly encodes UTF-8 characters' do
        # Encode the email, then parse the encoded string as a new Mail
        h = Mail.new(email.encoded).html_part
        html = h.body.to_s
        html.force_encoding(h.charset) if html.respond_to?(:force_encoding)
        html.should include("まつもとゆきひろ a.k.a. Matz")
      end

      describe 'sponsors' do
        before :each do
          Travis.config.sponsors = {
            :platinum => [{ :name => 'xing', :url => 'http://xing.de', :text => '<a href="http://xing.de">XING</a>' }],
            :gold     => [{ :name => 'xing', :url => 'http://xing.de', :text => '<a href="http://xing.de">XING</a>' }]
          }
        end

        let(:sponsor) do
          email.deliver
          email.html_part.decoded =~ /<div[^>]*id="sponsors"[^>]*>(.*)<\/div>/m
          $1
        end

        it 'adds a sponsor image' do
          sponsor.should =~ %r(<img src="https://love.travis-ci.org/images/sponsors/xing-100x60.png")
        end

        it 'does not escape tags contained in the sponsor text' do
          sponsor.should =~ %r(<a href="http://xing.de">XING</a>)
        end
      end
    end

    describe 'broadcasts' do
      let(:broadcasts) { [stub(:message => 'message 1'), stub(:message => 'message 2')] }

      it 'includes a the first broadcast' do
        Broadcast.stubs(:by_repo).with(build.repository).returns(broadcasts)
        email.deliver
        email.html_part.decoded.should =~ /message 1/
      end
    end

    describe 'for a successful build' do
      before :each do
        build.stubs(:result).returns(0)
      end

      it 'subject' do
        email.subject.should == '[Passed] svenfuchs/minimal#2 (master - 62aae5f)'
      end
    end

    describe 'for a broken build' do
      before :each do
        build.stubs(:result).returns(1)
      end

      it 'subject' do
        email.subject.should == '[Broken] svenfuchs/minimal#2 (master - 62aae5f)'
      end
    end

    describe 'for a broken build with tags' do
      before :each do
        build.stubs(:result).returns(1)
        build.matrix[0].stubs(:tags).returns('database_missing,rake_not_bundled')
        build.matrix[1].stubs(:tags).returns('database_missing,log_limit_exceeded')

        Job::Tagging.stubs(:rules).returns [
          { 'tag' => 'database_missing',   'message' => 'Your should create a test database.'                 },
          { 'tag' => 'rake_not_bundled',   'message' => 'Your Gemfile is missing Rake.'                       },
          { 'tag' => 'log_limit_exceeded', 'message' => 'Your test suite has output more than 4194304 Bytes.' }
        ]
      end

      it 'contains the expected text part' do
        email.text_part.body.should include_lines(%(
          Notes:
            * Your should create a test database. (2.1 and 2.2)
            * Your Gemfile is missing Rake. (2.1)
            * Your test suite has output more than 4194304 Bytes. (2.2)
        ))
      end

      it 'contains the expected html part' do
        email.html_part.body.should include_lines(%(
          <td>
          <ul>
            <li>Your should create a test database. (2.1 and 2.2)</li>
            <li>Your Gemfile is missing Rake. (2.1)</li>
            <li>Your test suite has output more than 4194304 Bytes. (2.2)</li>
          </ul>
          </td>
        ))
      end
    end
  end
end
