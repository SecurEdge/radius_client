require "test_helper"

describe RadiusClient::Request do
  DICT = RadiusClient::Dictionary.new('templates')

  def new_request(socket = nil)
    RadiusClient::Request.new("127.0.0.1:1812", { dict: DICT, secret: "testing123", socket: socket })
  end

  def accounting_response
    [
      "\x05\xB7\x00\x14\xB6\xFE\x06>\x02\xAF\x17|\x8D03,+\xF2\x1C\xBB",
      ["AF_INET", 1813, "127.0.0.1", "127.0.0.1"]
    ]
  end

  it "can send accounting_request" do
    req_socket = UDPSocket.open
    request = new_request(req_socket)

    req_socket.stub :recvfrom, accounting_response do
      assert request.accounting(:start, "testing", rand(65565).to_s)
    end
  end

  describe "Prepared requests" do
    %i(start update stop).each do |action|
      it "proxifies ##{action} to #accounting_request" do
        mock = MiniTest::Mock.new

        call_arguments = lambda do |call_action, name, sessionid, options|
          assert_equal RadiusClient::Request::ACCOUNT_ACTIONS[action], call_action
          assert_equal "test", name
          assert_equal 1, sessionid
          assert_equal ({}), options
          mock
        end

        request = new_request

        request.stub(:accounting_request, call_arguments) do
          request.accounting(action, "test", 1)
        end

        assert mock.verify
      end
    end
  end
end
