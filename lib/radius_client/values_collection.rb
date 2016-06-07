module RadiusClient
  class ValuesCollection < Array
    def initialize
      @collection = {}
      @revcollection = {}
    end

    def add(name, id)
      @collection[name] ||= Value.new(name, id)
      @revcollection[id.to_i] ||= @collection[name]
      self << @collection[name]
    end

    def find_by_name(name)
      @collection[name]
    end

    def find_by_id(id)
      @revcollection[id]
    end
  end
end
