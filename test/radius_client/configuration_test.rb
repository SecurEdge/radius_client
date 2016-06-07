require "test_helper"

describe RadiusClient::Configuration do
  describe "#dictionary_dir" do
    it "default value is nil" do
      RadiusClient::Configuration.new.dictionary_dir.must_equal nil
    end
  end

  describe "#dictionary_dir=" do
    it "can set value" do
      config = RadiusClient::Configuration.new
      config.dictionary_dir = "/usr/local/share/freeradius"
      config.dictionary_dir.must_equal "/usr/local/share/freeradius"
    end
  end
end
