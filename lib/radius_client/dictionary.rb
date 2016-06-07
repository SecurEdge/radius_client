module RadiusClient
  class Dictionary
    alias_method :inspect, :to_s

    def initialize(initial_path = RadiusClient.configuration.dictionary_dir)
      @attributes = AttributesCollection.new
      @vendors = VendorCollection.new

      read_files(initial_path) if initial_path
    end

    def read_files(path)
      dict_files = File.join(path, "*")
      Dir.glob(dict_files) { |file| read_data(file) }
    end

    def find_attribute_by_name(name)
      @attributes.find_by_name(name)
    end

    def find_attribute_by_id(id)
      @attributes.find_by_id(id)
    end

    attr_reader :vendors

    attr_reader :attributes

    protected

    def read_data(path)
      file = File.open(path) do |f|
        current_vendor = nil
        f.each_line do |line|
          next if line =~ /^\#/	# discard comments
          split_line = line.split(/\s+/)
          next if split_line == []
          case split_line.first.upcase
          when "ATTRIBUTE"
            current_vendor.nil? ? set_attr(split_line) : set_vendor_attr(current_vendor, split_line)
          when "VALUE"
            if current_vendor.nil?
              set_value(split_line)
            else
              begin
                set_vendor_value(current_vendor, split_line)
              rescue
                set_value(split_line)
              end
            end
          when "VENDOR"
            add_vendor(split_line)
          when "BEGIN-VENDOR"
            current_vendor = set_vendor(split_line)
          when "END-VENDOR"
            current_vendor = nil
          end
        end
      end
    end

    private

    def set_attr(line)
      @attributes.add(line[1], line[2], line[3])
    end

    def set_value(line)
      attr = @attributes.find_by_name(line[1])

      return unless attr

      attr.add_value(line[2], line[3])
    end

    def add_vendor(line)
      @vendors.add(line[2], line[1])
    end

    def set_vendor(line)
      @vendors.find_by_name(line[1])
    end

    def set_vendor_attr(vendor, line)
      vendor.add_attribute(line[1], line[2], line[3])
    end

    def set_vendor_value(vendor, line)
      attr = vendor.find_attribute_by_name(line[1])

      return unless attr

      attr.add_value(line[2], line[3])
    end
  end
end
