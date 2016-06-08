module RadiusClient
  class Reply
    attr_reader :attributes

    def initialize(options)
      @attributes = options
    end

    def success?
      @attributes[:code] == "Access-Accept"
    end
  end
end
