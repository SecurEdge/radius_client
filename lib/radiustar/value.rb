module Radiustar
  class Value
    attr_accessor :name, :id

    def initialize(name, id)
      @name = name
      @id = id.to_i
    end
  end
end
