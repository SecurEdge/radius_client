module RadiusClient
  class User
    class << self
      def all
        conn.exec("SELECT * FROM radcheck").map { |row| row }
      end

      def update_by_username(username, attrs = {})
        fields = attrs.map { |key, value| "#{key} = '#{filter(value)}'" }.join(", ")
        conn.exec("UPDATE radcheck SET #{fields} WHERE username = '#{filter(username)}' AND attribute = 'Cleartext-Password'")
      end

      def sign_up(name, password, options = {})
        conn.exec(
          "INSERT INTO radcheck (username, attribute, op, value) values ('#{filter(name)}', 'Cleartext-Password', ':=', '#{filter(password)}')"
        )

        options.each do |key, value|
          conn.exec(
            "INSERT INTO radcheck (username, attribute, op, value) values ('#{filter(name)}', '#{key}', ':=', '#{filter(value)}')"
          )
        end
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

      def filter(string)
        string.tr("^A-Za-z0-9.", "")
      end
    end
  end
end
