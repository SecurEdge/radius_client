module RadiusClient
  class VendorCollection < Array
    def initialize
      @collection = {}
      @revcollection = []
    end

    def add(id, name)
      @collection[name] ||= Vendor.new(name, id)
      @revcollection[id.to_i] ||= @collection[name]
      self << @collection[name]
    end

    def find_by_name(name)
      @collection[name]
    end

    def find_by_id(id)
      @revcollection[id.to_i]
    end
  end
end
