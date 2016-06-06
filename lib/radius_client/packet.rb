module RadiusClient
  class Packet
    CODES = {
      "Access-Request" => 1,
      "Access-Accept" => 2,
      "Access-Reject" => 3,
      "Accounting-Request" => 4,
      "Accounting-Response" => 5,
      "Access-Challenge" => 11,
      "Status-Server" => 12,
      "Status-Client" => 13,
      "Disconnect-Request" => 40,
      "Disconnect-ACK" => 41,
      "Disconnect-NAK" => 42,
      "CoA-Request" => 43,
      "CoA-ACK" => 44,
      "CoA-NAK" => 45
    }.freeze

    HDRLEN = (1 + 1 + 2 + 16).freeze # size of packet header
    PACK_HEADER = ("CCna16a*").freeze # pack template for header
    PACK_ATTR = ("CCa*").freeze # pack template for attribute

    attr_accessor :code
    attr_reader :id, :attributes, :authenticator

    def initialize(dictionary, id, data = nil)
      @dict = dictionary
      @id = id
      unset_all_attributes
      if data
        @packed = data
        self.unpack
      end
      self
    end

    # Generate an authenticator. It will try to use /dev/urandom if
    # possible, or the system rand call if that"s not available.
    def gen_auth_authenticator
      if (File.exist?("/dev/urandom"))
        File.open("/dev/urandom") do |urandom|
          @authenticator = urandom.read(16)
        end
      else
        @authenticator = []
        8.times { @authenticator << rand(65536) }
        @authenticator = @authenticator.pack("n8")
      end
    end

    def gen_acct_authenticator(secret)
      # From RFC2866
      # Request Authenticator
      #
      #       In Accounting-Request Packets, the Authenticator value is a 16
      #       octet MD5 [5] checksum, called the Request Authenticator.
      #
      #       The NAS and RADIUS accounting server share a secret.  The Request
      #       Authenticator field in Accounting-Request packets contains a one-
      #       way MD5 hash calculated over a stream of octets consisting of the
      #       Code + Identifier + Length + 16 zero octets + request attributes +
      #       shared secret (where + indicates concatenation).  The 16 octet MD5
      #       hash value is stored in the Authenticator field of the
      #       Accounting-Request packet.
      #
      #       Note that the Request Authenticator of an Accounting-Request can
      #       not be done the same way as the Request Authenticator of a RADIUS
      #       Access-Request, because there is no User-Password attribute in an
      #       Accounting-Request.
      #
      @authenticator = "\000"*16
      @authenticator = Digest::MD5.digest(pack + secret)
      @packed = nil
      @authenticator
    end

    def gen_response_authenticator(secret, request_authenticator)
      @authenticator = request_authenticator
      @authenticator = Digest::MD5.digest(pack + secret)
      @packed = nil
      @authenticator
    end

    def validate_acct_authenticator(secret)
      if @authenticator
        original_authenticator = @authenticator
        if gen_acct_authenticator(secret) == original_authenticator
          true
        else
          @authenticator = original_authenticator
          false
        end
      else
        false
      end
    end

    def set_attribute(name, value)
      set_attribute_with(name, Attribute.new(@dict, name, value))
    end

    def set_attributes(options)
      options.each do |name, value|
        set_attribute_with(name, Attribute.new(@dict, name, value))
      end
    end

    def unset_attribute(name)
      @attributes.delete(name)
    end

    def attribute(name)
      if @attributes[name]
        @attributes[name].is_a?(Array) ? @attributes[name].map(&:value) : @attributes[name].value
      end
    end

    def unset_all_attributes
      @attributes = {}
    end

    def set_encoded_attribute(name, value, secret)
      set_attribute_with(name, Attribute.new(@dict, name, encode(value, secret)))
    end

    def set_chap_password(name, password)
      chap_id = rand(256).chr
      chap_resp = Digest::MD5.digest(chap_id + password + @authenticator)
      @attributes[name] = Attribute.new(@dict, name, chap_id + chap_resp)
    end

    def decode_attribute(name, secret)
      return unless @attributes[name]

      if @attributes[name].is_a?(Array)
        @attributes[name].map{ |a| decode(a.value.to_s, secret) }
      else
        decode(@attributes[name].value.to_s, secret)
      end
    end

    def pack
      attstr = ""
      @attributes.values.each do |attribute|
        attstr += attribute.is_a?(Array) ? attribute.map(&:pack).join : attribute.pack
      end
      @packed = [CODES[@code], @id, attstr.length + HDRLEN, @authenticator, attstr].pack(PACK_HEADER)
    end

    protected

    def set_attribute_with(name, value)
      if @attributes[name].nil?
        @attributes[name] = value
      elsif @attributes[name].is_a?(Array)
        @attributes[name].push value
      else
        @attributes[name] = [@attributes[name], value]
      end
    end

    def unpack
      @code, @id, len, @authenticator, attribute_data = @packed.unpack(PACK_HEADER)
      raise "Incomplete Packet(read #{@packed.length} != #{len})" if @packed.length != len

      @code = CODES.key(@code)
      vendor = nil

      unset_all_attributes

      while attribute_data.length > 0 do
        length = attribute_data.unpack("xC").first.to_i
        attribute_type, attribute_value = attribute_data.unpack("Cxa#{length-2}")
        attribute_type = attribute_type.to_i

        if attribute_type == 26 # Vendor Specific Attribute
          vid, attribute_type, attribute_value = attribute_data.unpack("xxNCxa#{length-8}")
          vendor =  @dict.vendors.find_by_id(vid)
          attribute = vendor.find_attribute_by_id(attribute_type) if vendor
        else
          vendor = nil
          attribute = @dict.find_attribute_by_id(attribute_type)
        end

        if attribute
          attribute_value = case attribute.type
                            when "string", "octets"
                              attribute_value
                            when "integer"
                              attribute.has_values? ? attribute.find_values_by_id(attribute_value.unpack("N")[0]).name : attribute_value.unpack("N")[0]
                            when "ipaddr"
                              attribute_value.unpack("N")[0].to_ip.to_s
                            when "ipv6addr"
                              a=attribute_value.unpack("NNNN")
                              ((a[0]<<96)+(a[1]<<64)+(a[2]<<32)+a[3]).to_ip.to_s
                            when "ipv6prefix"
                              a=attribute_value.unpack("CCNNNN")
                              ((a[2]<<96)+(a[3]<<64)+(a[4]<<32)+a[5]).to_ip.to_s+"/#{a[1]}"
                            when "time"
                              attribute_value.unpack("N")[0]
                            when "date"
                              attribute_value.unpack("N")[0]
                            end

          if vendor
            set_attribute(vendor.name+"/"+attribute.name, attribute_value) if attribute
          else
            set_attribute(attribute.name, attribute_value) if attribute
          end
        end

        attribute_data[0, length] = ""
      end
    end

    def xor_str(str1, str2)
      bstr1 = str1.unpack("C*")
      bstr2 = str2.unpack("C*")

      bstr1.zip(bstr2).map {|b1, b2| b1 ^ b2}.pack("C*")
    end

    def encode(value, secret)
      lastround = @authenticator
      encoded_value = ""

      # pad to 16n bytes
      value += "\000" * (15-(15 + value.length) % 16)
      0.step(value.length-1, 16) do |i|
        lastround = xor_str(value[i, 16], Digest::MD5.digest(secret + lastround) )
        encoded_value += lastround
      end

      encoded_value
    end

    def decode(value, secret)
      decoded_value = ""
      lastround = @authenticator
      0.step(value.length-1, 16) do |i|
              decoded_value += xor_str(value[i, 16], Digest::MD5.digest(secret + lastround))
              lastround = value[i, 16]
      end

      decoded_value.gsub!(/\000+/, "") if decoded_value
      decoded_value[value.length, -1] = "" unless (decoded_value.length <= value.length)
      return decoded_value
    end

    class Attribute
      attr_reader :dict, :name, :vendor
      attr_accessor :value

      def initialize(dict, name, value, vendor = nil)
        add_vsa(name)

        @dict = dict
        @vendor ||= vendor
        @value = value.is_a?(Attribute) ? value.to_s : value
      end

      def vendor?
        !!@vendor
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
        if (name && (chunks = name.split("/")) && (chunks.size == 2))
          @vendor = chunks[0]
          @name = chunks[1]
        else
          @name = name
        end
      end

      def define_pack_attribute
        if vendor? && (@dict.vendors.find_by_name(@vendor))
          @dict.vendors.find_by_name(@vendor).attributes.find_by_name(@name)
        else
          @dict.find_attribute_by_name(@name)
        end
      end

      def pack_vendor_specific_attribute(attribute)
        inside_attribute = pack_attribute attribute
        vid = attribute.vendor.id.to_i
        header = [ 26, inside_attribute.size + 6 ].pack("CC") # 26: Type = Vendor-Specific, 4: length of Vendor-Id field
        header += [ 0, vid >> 16, vid >> 8, vid ].pack("CCCC") # first byte of Vendor-Id is 0
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
          [ ipi >> 96, ipi >> 64, ipi >> 32, ipi ].pack("NNNN")
        when "ipv6prefix"
          ipi = @value.to_ip.to_i
          mask = @value.to_ip.length
          [ 0, mask, ipi >> 96, ipi >> 64, ipi >> 32, ipi ].pack("CCNNNN")
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
end
