require "test_helper"

describe Radiustar::Request do
  DICT = Radiustar::Dictionary.new('templates')

  def new_request
    Radiustar::Request.new("127.0.0.1:1812", { dict: DICT, secret: "testing123" })
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
