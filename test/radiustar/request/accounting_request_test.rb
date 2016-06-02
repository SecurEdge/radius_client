require "test_helper"

describe Radiustar::Request do
  DICT = Radiustar::Dictionary.new('templates')

  def new_request
    Radiustar::Request.new("127.0.0.1:1812", { dict: DICT, secret: "testing123" })
  end

  describe "Prepared requests" do
    %i(start update stop).each do |action|
      it "proxifies ##{action} to #accounting_request" do
        mock = MiniTest::Mock.new

        call_arguments = lambda do |call_action, name, sessionid, options|
          assert_equal Radiustar::Request::ACCOUNT_ACTIONS[action], call_action
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
