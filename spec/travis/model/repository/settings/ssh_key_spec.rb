# encoding: utf-8
require 'spec_helper'

describe Repository::Settings::SshKey do
  let(:private_key) {
"-----BEGIN RSA PRIVATE KEY-----
MIIEowIBAAKCAQEAuHVhiw/2qaGmIiRbKjO5bZmQI0UEQ1vQVVxujL5SFAUsEB3w
YvcsdK+EDrmFfhrvVde1PnWzuwdq4seftZvTni+5KIjpNJ6/YKfYVUEOQ5ORvuqb
zrYPWzJShXnqvrFpbF82unHs4ceb+XzV/2Tciy/p5Yv535yweLRJKtcwK+ANLz8O
wF+IZf20StugF7tZaXMCXD1ieGg6fv5eV7lohfxYCeRTVJsMUxnwcrLxeqi8IgAa
q44IsIayTn5jcBZMwir8W+PrlXq44WHyLWnErXCH0Pds1UrbL6HFz5+uU0xoMO0N
vG1T0er1KIOooQ2dnbcH8UoDnrYSsn5mWFq1fwIDAQABAoIBABB5Qz3lLhVWP30b
HB03w167cTkFJ+1QHNoSyDi/oprxH09NLTPZeVnudu/Nt9NcWnWjLyel4WhZsD0S
sPvKL+sXvgSVvaYaa2MZemOazMhSPJj9YO7kKZjudJpBGirvs0efdUbPd+VuK0rr
0Dzf6CZyIASFLMrAtq4BA+vUjhPM5tmQqwhuZVkrr+GstCvJa2W2K4hbpZ+1XyhX
++XX4QnvQ1HXjVxo4LSXV05oJ9OBbiCh+OEkME3X3vPuy62E0WngFyH67NlryR1O
AyqrDPALf0Fl/1IXwGOZNsjHUQr8j+lbAE3uxwS7KNwlvEmJ8Hc2LdRwmlvTim9f
xWRGaWkCgYEA6GJ/FBgSykBs0FvYqvAs8O2Y1Rh1YJrInwSI/nG4yXEUDvmM+rFB
7Cb2AhTamw4VlHbu2dvUuVh4I2u1GVESrIy2+SV2xfzieoEG6+HWvRAm5owqKq2u
HSM3GFN2VGZzYl1J1260J9wlWHoPZV8vpgzD/VulN7x/TAXXwv/u0FMCgYEAyzQU
rIlbqsomx3G4Nzi4Nr9nLaKkRiAmSITzEVojItRWJRAKZtrMPV57JlGfNIqzAzAS
MWkcZr4XLvn6gxks37rrl7NtgRTTyq9MLTx5opMqQalYUIpp8PHMJ0vevdqVGgmS
FOP17SEyO2Tnc0UYAezyS8VuQ30u2ReJx/PJ0KUCgYBI3vIok+/4ekFlCRglalE9
b9Q4JoZQN9lnfB2VZIXkrU/z7i9WQZWBfyovtuhiLQV5W95EdNn9ERADU3gjqzem
4i1SbXwUU9uVPLa160jSWqlILHXgkjwCKRPSzgFSMBpIoyZPpwhZY4BWgVgomrOv
Z1tiLIXft31XkpF5NZZmvwKBgGsBJu3geywJvbgDE13I+YCi9CNc5SKkZWSE1jbJ
/3yk0iQ8OS4Gg8zBRxpbmvmhHDlOhBYO4szbxvuO2bNVe4LpPIyrCLwTip/OBdBA
a1EILBVdpsrqyHT/72C2HDpfs2p9pbZogKV5eKk8LoFN3iGNc94gvjq93gCl24E2
yIydAoGBALrYhMbK+ljTaqn4IsC0CwG5S6dLA/uXLn4QosDGtCqi1iXWKb8ixRho
x9giBf4WDeH3Gb2TBF1QnB8sbhHJAzTW/CO3vOjRiFSSF7EjxjCFier/LfuDU1Kr
tFns8eTxHpZOYOftxpX91vS3tzKCKgkdPhnYBDrvFFWnGgRLXFpb
-----END RSA PRIVATE KEY-----
"
  }

  it 'validates correctness of private key' do
    ssh_key = described_class.new(value: private_key)
    ssh_key.should be_valid

    ssh_key.value = 'foo'
    ssh_key.should_not be_valid

    ssh_key.errors[:value].should == [:not_a_private_key]
  end

  it 'allows only private key' do
    public_key =  OpenSSL::PKey::RSA.new(private_key).public_key.to_s
    ssh_key = described_class.new(value: public_key)

    ssh_key.should_not be_valid
    ssh_key.errors[:value].should == [:not_a_private_key]
  end

  it 'does not check key if a value is nil' do
    ssh_key = described_class.new({})

    ssh_key.should_not be_valid
    ssh_key.errors[:value].should == [:blank]
  end
end
