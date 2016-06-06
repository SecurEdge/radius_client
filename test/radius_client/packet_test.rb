require "test_helper"

describe RadiusClient::Packet do
  it "gen_authenticator generates a random string without /dev/urandom" do
    File.stub :exist?, false do
      packet = RadiusClient::Packet.new(nil, nil)
      packet.gen_auth_authenticator

      packet.authenticator.must_be_kind_of String
    end
  end

  # don't fail if specs are running on a platform without /dev/urandom
  if File.exist?("/dev/urandom")
    it "gen_authenticator generates a random string with /dev/urandom" do
      packet = RadiusClient::Packet.new(nil, nil)
      packet.gen_auth_authenticator

      packet.authenticator.must_be_kind_of String
    end
  end
end
