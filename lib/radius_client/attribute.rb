module RadiusClient
  class Attribute
    attr_reader :name, :id, :type, :vendor

    def initialize(name, id, type, vendor = nil)
      @values = ValuesCollection.new
      @name = name
      @id = id.to_i
      @type = type
      @vendor = vendor if vendor
    end

    def add_value(name, id)
      @values.add(name, id.to_i)
    end

    def find_values_by_name(name)
      @values.find_by_name(name)
    end

    def find_values_by_id(id)
      @values.find_by_id(id.to_i)
    end

    def has_values?
      !@values.empty?
    end

    attr_reader :values

    def vendor?
      !!@vendor
    end
  end
end
