require "test_helper"

describe RadiusClient::Vendor do
  it "finds attributes by id" do
    vendor = RadiusClient::Vendor.new("Aruba", "14823")
    vendor.add_attribute "Aruba-Device-Type", "12", "string"

    vendor.find_attribute_by_id("12").name.must_equal "Aruba-Device-Type"
  end
end
