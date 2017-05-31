module RadiusClient
  class User
    class << self
      def all
        conn.exec("SELECT * FROM radcheck").map { |row| row }
      end

      def update_by_username(username, attrs = {})
        fields = attrs.map { |key, value| "#{key} = '#{value}'" }.join(", ")
        conn.exec("UPDATE radcheck SET #{fields} WHERE username = '#{username}' AND attribute = 'Cleartext-Password'")
      end

      def sign_up(name, password, options = {})
        user = conn.exec("SELECT * FROM radcheck WHERE username='#{name}'")
        return if user.count != 0

        conn.exec(
          "INSERT INTO radcheck (username, attribute, op, value) values ('#{name}', 'Cleartext-Password', ':=', '#{password}')"
        )

        conn.exec(
          "INSERT INTO radcheck (username, attribute, op, value) values ('#{name}', 'Expire-After', ':=', '#{options["Expire-After"]}')"
        ) if options["Expire-After"].present?
        conn.exec(
          "INSERT INTO radreply (username, attribute, value) values ('#{name}', 'WISPr-Bandwidth-Max-Down', '#{options["WISPr-Bandwidth-Max-Down"]}')"
        ) if options["WISPr-Bandwidth-Max-Down"].present?
        conn.exec(
          "INSERT INTO radreply (username, attribute, value) values ('#{name}', 'WISPr-Bandwidth-Max-Down', '#{options["WISPr-Bandwidth-Max-Up"]}')"
        ) if options["WISPr-Bandwidth-Max-Up"].present?
      end

      def delete(name)
        conn.exec("DELETE from radcheck WHERE username='#{name}'")
        conn.exec("DELETE from radacct WHERE username='#{name}'")
        conn.exec("DELETE from radreply WHERE username='#{name}'")
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
