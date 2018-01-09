module RadiusClient
  class User
    class << self
      def all
        conn["SELECT * FROM radcheck"].map { |row| row }
      end

      def update_by_username(username, attrs = {})
        fields = attrs.map { |key, value| "#{key} = '#{value}'" }.join(", ")
        conn.run("UPDATE radcheck SET #{fields} WHERE username = '#{username}' AND attribute = 'Cleartext-Password'")
      end

      def sign_up(name, password, options = {})
        user = conn["SELECT * FROM radcheck WHERE username='#{name}'"]
        return if user.count != 0

        conn.run(
          "INSERT INTO radcheck (username, attribute, op, value) values ('#{name}', 'Cleartext-Password', ':=', '#{password}')"
        )

        conn.run(
          "INSERT INTO radcheck (username, attribute, op, value) values ('#{name}', 'Expiration', ':=', '#{options["Expiration"]}')"
        ) if options["Expiration"].present?

        conn.run(
          "INSERT INTO radreply (username, attribute, value) values ('#{name}', 'WISPr-Bandwidth-Max-Down', '#{options["WISPr-Bandwidth-Max-Down"]}')"
        ) if options["WISPr-Bandwidth-Max-Down"].present?

        conn.run(
          "INSERT INTO radreply (username, attribute, value) values ('#{name}', 'WISPr-Bandwidth-Max-Down', '#{options["WISPr-Bandwidth-Max-Up"]}')"
        ) if options["WISPr-Bandwidth-Max-Up"].present?
      end

      def delete(name)
        conn.run("DELETE from radcheck WHERE username='#{name}'")
        conn.run("DELETE from radacct WHERE username='#{name}'")
        conn.run("DELETE from radreply WHERE username='#{name}'")
      end

      def sign_in(name, password, options = {})
        reply = request.authenticate(name, password, options)
        Session.start(name, password, options) if reply.success?
      end

      def request
        @request ||= Request.new
      end

      def conn
        @conn ||= Sequel.connect(
          adapter:         :postgres,
          host:            ENV["RADIUS_HOST"],
          port:            ENV["RADIUS_DB_PORT"] || 5432,
          database:        ENV["RADIUS_DB_NAME"],
          user:            ENV["RADIUS_DB_USER"],
          password:        ENV["RADIUS_DB_PASSWORD"],
          max_connections: ENV["RADIUS_DB_MAX_CONNECTIONS"] || 4
        )
      end
    end
  end
end
