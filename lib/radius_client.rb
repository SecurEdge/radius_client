require "digest/md5"
require "ipaddr_extensions"
require "socket"

module RadiusClient
  autoload :VERSION,              "radius_client/version"
  autoload :Configuration,        "radius_client/configuration"
  autoload :Attribute,            "radius_client/attribute"
  autoload :AttributesCollection, "radius_client/attributes_collection"
  autoload :Dictionary,           "radius_client/dictionary"
  autoload :Reply,                "radius_client/reply"
  autoload :User,                 "radius_client/user"
  autoload :Session,              "radius_client/session"
  autoload :PacketAttribute,      "radius_client/packet_attribute"
  autoload :Packet,               "radius_client/packet"
  autoload :Request,              "radius_client/request"
  autoload :Value,                "radius_client/value"
  autoload :ValuesCollection,     "radius_client/values_collection"
  autoload :VendorCollection,     "radius_client/vendor_collection"
  autoload :Vendor,               "radius_client/vendor"

  class << self
    attr_accessor :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def reset!
      @configuration = Configuration.new
    end

    def dictionary
      @dictionary ||= Dictionary.new
    end

    def configure
      yield(configuration)
    end
  end
end
