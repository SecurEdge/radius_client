module RadiusClient
  class PacketAttribute
    PACK_ATTR = "CCa*".freeze # pack template for attribute

    attr_reader :dict, :name, :vendor
    attr_accessor :value

    def initialize(dict, name, value)
      add_vsa(name)

      @dict = dict
      @value = value.is_a?(PacketAttribute) ? value.to_s : value
    end

    def vendor?
      !@vendor.nil?
    end

    def pack
      attribute = define_pack_attribute
      raise "Undefined attribute \"#{@name}\"." if attribute.nil?

      if vendor?
        pack_vendor_specific_attribute(attribute)
      else
        pack_attribute(attribute)
      end
    end

    private

    # This is the cheapest and easiest way to add VSA"s!
    def add_vsa(name)
      if name && (chunks = name.split("/")) && (chunks.size == 2)
        @vendor = chunks[0]
        @name = chunks[1]
      else
        @name = name
      end
    end

    def define_pack_attribute
      if vendor? && @dict.vendors.find_by_name(@vendor)
        @dict.vendors.find_by_name(@vendor).attributes.find_by_name(@name)
      else
        @dict.find_attribute_by_name(@name)
      end
    end

    def pack_vendor_specific_attribute(attribute)
      inside_attribute = pack_attribute attribute
      vid = attribute.vendor.id.to_i
      header = [26, inside_attribute.size + 6].pack("CC") # 26: Type = Vendor-Specific, 4: length of Vendor-Id field
      header += [0, vid >> 16, vid >> 8, vid].pack("CCCC") # first byte of Vendor-Id is 0
      header + inside_attribute
    end

    def pack_attribute(attribute)
      anum = attribute.id
      val = pack_attribute_val(attribute)

      begin
        [anum, val.length + 2, val].pack(PACK_ATTR)
      rescue
        puts "#{@name} => #{@value}"
        puts [anum, val.length + 2, val].inspect
      end
    end

    def pack_attribute_val(attribute)
      case attribute.type
      when "string", "octets"
        @value
      when "integer"
        raise "Invalid value name \"#{@value}\"." if attribute.has_values? && attribute.find_values_by_name(@value).nil?
        [attribute.has_values? ? attribute.find_values_by_name(@value).id : @value].pack("N")
      when "ipaddr"
        [@value.to_ip.to_i].pack("N")
      when "ipv6addr"
        ipi = @value.to_ip.to_i
        [ipi >> 96, ipi >> 64, ipi >> 32, ipi].pack("NNNN")
      when "ipv6prefix"
        ipi = @value.to_ip.to_i
        mask = @value.to_ip.length
        [0, mask, ipi >> 96, ipi >> 64, ipi >> 32, ipi].pack("CCNNNN")
      when "date"
        [@value].pack("N")
      when "time"
        [@value].pack("N")
      else
        ""
      end
    end
  end
end
