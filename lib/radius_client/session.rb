module RadiusClient
  class Session
    class << self
      def start(name, password, options)
        request.accounting(:start, name, password, options)
      end

      def request
        @request ||= Request.new(port: 1813)
      end
    end
  end
end
