require "test_helper"

describe RadiusClient do
  describe "#configure" do
    before do
      RadiusClient.configure do |config|
        config.dictionary_dir = "test/fixtures/freeradius"
      end
    end

    it "saves configuration" do
      dict = RadiusClient::Dictionary.new
      refute_nil dict.find_attribute_by_name("User-Name")
    end

    after do
      RadiusClient.reset!
    end
  end
end
