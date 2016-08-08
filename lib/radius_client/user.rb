module RadiusClient
  class User
    class << self
      def sign_up(name, password, options = {})
        # psql -U radius -h 23.96.105.62
        # INSERT INTO radcheck (username, attribute, op, value) VALUES (name, 'Cleartext-Password', ':=', password);
      end

      def sign_in(name, password, options = {})
        reply = request.authenticate(name, password, options)
        Session.start(name, password, options) if reply.success?
      end

      def request
        @request ||= Request.new
      end
    end
  end
end
