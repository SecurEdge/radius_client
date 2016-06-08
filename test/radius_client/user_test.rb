require "test_helper"
require "ostruct"

describe RadiusClient::User do
  describe "#sign_in" do
    it "sends authenticate request" do
      reply = MiniTest::Mock.new
      reply.expect :success?, false

      RadiusClient::User.request.stub(:authenticate, reply) do
        RadiusClient::User.sign_in("test", "password")
      end

      assert reply.verify
    end

    it "starts session in case of success authentication" do
      acct_request = MiniTest::Mock.new
      acct_request.expect :accounting, nil, [:start, "test", "password", {}]

      RadiusClient::User.request.stub(:authenticate, OpenStruct.new("success?" => true)) do
        RadiusClient::Session.stub(:request, acct_request) do
          RadiusClient::User.sign_in("test", "password")
        end
      end

      assert acct_request.verify
    end
  end
end
