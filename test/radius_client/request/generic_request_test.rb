require "test_helper"

describe RadiusClient::Request do
  def new_request(socket = nil)
    RadiusClient::Request.new("127.0.0.1:1812", dict: DICT, secret: "testing123", socket: socket)
  end

  def generic_response
    [
      "\x05\xB7\x00\x14\xB6\xFE\x06>\x02\xAF\x17|\x8D03,+\xF2\x1C\xBB",
      ["AF_INET", 1813, "127.0.0.1", "127.0.0.1"]
    ]
  end

  it "can send generic_request" do
    req_socket = UDPSocket.open
    request = new_request(req_socket)

    req_socket.stub :recvfrom, generic_response do
      assert request.generic_request("Disconnect-Request")
    end
  end

  describe "Prepare requests" do
    it "proxifies #coa_request to #generic_request" do
      mock = MiniTest::Mock.new

      call_arguments = lambda do |code, options|
        assert_equal "CoA-Request", code
        assert_equal ({}), options
        mock
      end

      request = new_request

      request.stub(:generic_request, call_arguments) do
        request.coa_request
      end

      assert mock.verify
    end

    it "proxifies #disconnect to #generic_request" do
      mock = MiniTest::Mock.new

      call_arguments = lambda do |code, options|
        assert_equal "Disconnect-Request", code
        assert_equal ({}), options
        mock
      end

      request = new_request

      request.stub(:generic_request, call_arguments) do
        request.disconnect
      end

      assert mock.verify
    end
  end
end
