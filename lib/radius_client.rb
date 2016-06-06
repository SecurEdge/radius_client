require "digest/md5"
require "ipaddr_extensions"
require "socket"
# require "pry"

module RadiusClient
  autoload :VERSION,              "radius_client/version"
  autoload :Attribute,            "radius_client/attribute"
  autoload :AttributesCollection, "radius_client/attributes_collection"
  autoload :Dictionary,           "radius_client/dictionary"
  autoload :Packet,               "radius_client/packet"
  autoload :Request,              "radius_client/request"
  autoload :Value,                "radius_client/value"
  autoload :ValuesCollection,     "radius_client/values_collection"
  autoload :VendorCollection,     "radius_client/vendor_collection"
  autoload :Vendor,               "radius_client/vendor"
end
