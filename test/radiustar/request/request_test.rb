require "test_helper"

describe Radiustar::Request do
  DICT = Radiustar::Dictionary.new('templates')

  REQUEST_OPTIONS = {
    nas_ip: "192.168.1.1",
    nas_identifier: "aa:9e:ee:2f:8d:7d",
    dict: DICT,
    secret: "testing123"
  }.freeze

  def new_request(socket = nil)
    Radiustar::Request.new("127.0.0.1:1812", REQUEST_OPTIONS.merge(socket: socket))
  end

  it "correctly initializes attributes" do
    request = new_request

    request.reply_timeout.must_equal 60
    request.retries_number.must_equal 1
    request.port.must_equal 1812
    request.nas_ip.must_equal REQUEST_OPTIONS[:nas_ip]
    request.nas_identifier.must_equal REQUEST_OPTIONS[:nas_identifier]
  end

  it "detects ip address by host" do
    request = Radiustar::Request.new("127.0.0.1:1812", { secret: "asdf", dict: DICT})
    request.nas_ip.must_equal "127.0.0.1"
  end
end
