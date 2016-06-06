require "test_helper"

describe RadiusClient::Value do
  it "should get numeric value of NAS-Port-Type == Ethernet from dictionary.rfc2865" do
    dict = RadiusClient::Dictionary.new('templates')
    attribute = dict.find_attribute_by_name 'NAS-Port-Type'
    ethernet_value = attribute.find_values_by_name 'Ethernet'

    ethernet_value.id.must_equal 15
  end
end
