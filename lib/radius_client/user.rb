module RadiusClient
  class User
    class << self
      def all
        conn.exec("SELECT * FROM radcheck").map { |row| row }
      end

      def sign_up(name, password, options = {})
        conn.prepare("new_user", "INSERT INTO radcheck (username, attribute, op, value) values ($1, $2, $3, $4)")
        conn.exec_prepared("new_user", [name, "Cleartext-Password", ":=", password])
      end

      def sign_in(name, password, options = {})
        reply = request.authenticate(name, password, options)
        Session.start(name, password, options) if reply.success?
      end

      def request
        @request ||= Request.new
      end

      def conn
        @conn ||= PG.connect(
          ENV["RADIUS_HOST"],
          dbname: ENV["RADIUS_DB_NAME"],
          user: ENV["RADIUS_DB_USER"]
        )
      end
    end
  end
end
