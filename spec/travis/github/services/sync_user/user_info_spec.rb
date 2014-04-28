require 'spec_helper'
require 'ostruct'

describe Travis::Github::Services::SyncUser::UserInfo do
  let(:old_user_info) {{
    'login'         => 'rkh',
    'name'          => 'Konstantin Haase',
    'gravatar_id'   => '5c2b452f6eea4a6d84c105ebd971d2a4',
    'email'         => 'konstantin.haase@gmail.com',
    'github_scopes' => ['user:email'],
    'id'            => '100',
    'github_id'     => '500'
  }}

  let(:emails) {[
    { "verified" => false, "primary" => false, "email" => "konstantin@Konstantins-MacBook-Air.local"    },
    { "verified" => false, "primary" => false, "email" => "Konstantin.Haase@student.hpi.uni-potsdam.de" },
    { "verified" => false, "primary" => false, "email" => "rkh@7926756e-e54e-46e6-9721-ed318f58905e"    },
    { "verified" => true,  "primary" => false, "email" => "konstantin.mailinglists@gmail.com"           },
    { "verified" => true,  "primary" => true,  "email" => "konstantin.mailinglists@googlemail.com"      }
  ]}

  let(:user_info) { old_user_info.dup }
  let(:gh) {{ 'user' => user_info, 'user/emails' => emails }}
  let(:user) { stub('user', old_user_info) }
  subject { described_class.new(user, gh) }

  its(:name)            { should == 'Konstantin Haase' }
  its(:gravatar_id)     { should == '5c2b452f6eea4a6d84c105ebd971d2a4' }
  its(:login)           { should == 'rkh' }
  its(:email)           { should == 'konstantin.haase@gmail.com' }
  its(:verified_emails) { should == [
    "konstantin.mailinglists@gmail.com",
    "konstantin.mailinglists@googlemail.com"
  ]}

  describe 'no public email' do
    before { user_info.delete 'email' }
    its(:email) { should == 'konstantin.mailinglists@googlemail.com' }

    describe 'missing github scope' do
      before { old_user_info['github_scopes'] = [] }
      its(:email) { should == 'konstantin.haase@gmail.com' }
    end

    describe 'no primary email' do
      before { emails.delete_if { |e| e["primary"] }}
      its(:email) { should == 'konstantin.mailinglists@gmail.com' }

      describe 'no verified email' do
        before { emails.delete_if { |e| e["verified"] }}
        its(:email) { should == 'konstantin.haase@gmail.com' }

        describe 'no email on file' do
          before { old_user_info['email'] = nil }
          its(:email) { should == 'konstantin@Konstantins-MacBook-Air.local' }
        end
      end
    end
  end

  describe 'login changed' do
    before { user_info['login'] = 'RKH' }
    its(:login) { should == 'RKH' }
  end

  describe 'name changed' do
    before { user_info['name'] = 'RKH' }
    its(:name) { should == 'RKH' }
  end

  it 'calls update_attributes! and emails.find_or_create_by_email!' do
    args   = user_info.slice('login', 'name', 'email', 'gravatar_id').symbolize_keys
    emails = stub("email")
    user.stubs(:emails).returns(emails)
    user.stubs(:github_id).returns(100)
    user.stubs(:id).returns(1)
    user.expects(:update_attributes!).with(args).once
    emails.expects(:find_or_create_by_email!).with("konstantin.mailinglists@gmail.com").once
    emails.expects(:find_or_create_by_email!).with("konstantin.mailinglists@googlemail.com").once
    emails.expects(:find_or_create_by_email!).with("konstantin.haase@gmail.com").once
    subject.run
  end

  it 'raises an error if github_id does not match' do
    args   = user_info.slice('login', 'name', 'email', 'gravatar_id').symbolize_keys
    user.stubs(:github_id).returns(101)
    user.stubs(:id).returns(1)
    expect {
      subject.run
    }.to raise_error(/Updating.*?failed/)
  end
end
