require "test_helper"

describe RadiusClient::Request do
  def new_request(socket)
    RadiusClient::Request.new("127.0.0.1:1812", dict: DICT, secret: "testing123", socket: socket)
  end

  def access_accept_response
    [
      "\x02\xB1\x00\x14S\x85Z\xB2\b\x04\e\x98\x06?\xF2\x8C\nf\xF3@",
      ["AF_INET", 1812, "127.0.0.1", "127.0.0.1"]
    ]
  end

  it "can authenticate user" do
    req_socket = UDPSocket.open
    request = new_request(req_socket)

    req_socket.stub :recvfrom, access_accept_response do
      request.authenticate("testing", "password").must_equal(code: "Access-Accept")
    end
  end

  it "can authenticate user using CHAP" do
    req_socket = UDPSocket.open
    request = new_request(req_socket)

    req_socket.stub :recvfrom, access_accept_response do
      request.authenticate_chap("testing", "password").must_equal(code: "Access-Accept")
    end
  end
end
