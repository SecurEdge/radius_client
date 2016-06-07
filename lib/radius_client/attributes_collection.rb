module RadiusClient
  class AttributesCollection < Array
    attr_accessor :vendor

    def initialize(vendor = nil)
      @collection = {}
      @revcollection = {}
      @vendor = vendor
    end

    def add(name, id, type)
      @collection[name] ||= Attribute.new(name, id.to_i, type, @vendor)
      @revcollection[id.to_i] ||= @collection[name]
      self << @collection[name]
    end

    def find_by_name(name)
      @collection[name]
    end

    def find_by_id(id)
      @revcollection[id]
    end

    def vendor?
      !!@vendor
    end
  end
end
