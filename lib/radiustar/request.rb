module Radiustar
  class Request
    ACCOUNT_ACTIONS = { start: "Start", update: "Interim-Update", stop: "Stop" }.freeze

    alias_method :inspect, :to_s

    attr_reader :port, :nas_ip, :nas_identifier, :reply_timeout, :retries_number, :socket

    def initialize(server, options = {})
      options = default_options.merge(options)
      @host, @port = server.split(":")
      set_port

      @dict = options.fetch(:dict)
      @secret = options.fetch(:secret)
      @nas_ip = options[:nas_ip] || get_my_ip(@host)
      @nas_identifier = options[:nas_identifier] || @nas_ip
      @reply_timeout = options[:reply_timeout]
      @retries_number = options[:retries_number]

      @socket = options[:socket] || UDPSocket.open
      @socket.connect(@host, @port)
    end

    def authenticate(name, password, user_attributes = {})
      packet_attributes = {
        'User-Name' => name,
        'NAS-Identifier' => @nas_identifier,
        'NAS-IP-Address' => @nas_ip
      }.merge(user_attributes)

      @packet = Packet.new(@dict, Process.pid & 0xff)
      @packet.gen_auth_authenticator
      @packet.code = 'Access-Request'
      @packet.set_attributes packet_attributes
      @packet.set_encoded_attribute('User-Password', password, @secret)

      send_packet

      reply = { code: @received_packet.code }
      reply.merge @received_packet.attributes
    end

    def authenticate_chap(name, password, user_attributes = {})
      packet_attributes = {
        'User-Name' => name,
        'NAS-Identifier' => @nas_identifier,
        'NAS-IP-Address' => @nas_ip,
        'CHAP-Password' => password
      }.merge(user_attributes)

      @packet = Packet.new(@dict, Process.pid & 0xff)
      @packet.gen_auth_authenticator
      @packet.code = 'Access-Request'
      @packet.set_attributes packet_attributes

      send_packet

      reply = { code: @received_packet.code }
      reply.merge @received_packet.attributes
    end

    def accounting_request(status_type, name, sessionid, user_attributes = {})
      packet_attributes = {
        'User-Name' => name,
        'NAS-Identifier' => @nas_identifier,
        'NAS-IP-Address' => @nas_ip,
        'Acct-Status-Type' => status_type,
        'Acct-Session-Id' => sessionid,
        'Acct-Authentic' => 'RADIUS'
      }.merge(user_attributes)

      @packet = Packet.new(@dict, Process.pid & 0xff)
      @packet.code = 'Accounting-Request'
      @packet.set_attributes packet_attributes

      @packet.gen_acct_authenticator(@secret)

      send_packet
    end

    def generic_request(code, user_attributes = {})
      packet_attributes = {
        'NAS-Identifier' => @nas_identifier,
        'NAS-IP-Address' => @nas_ip
      }.merge(user_attributes)

      @packet = Packet.new(@dict, Process.pid & 0xff)
      @packet.code = code
      @packet.set_attributes packet_attributes

      @packet.gen_acct_authenticator(@secret)

      send_packet
    end

    def coa_request(user_attributes = {})
      generic_request('CoA-Request', user_attributes)
    end

    def disconnect(user_attributes = {})
      generic_request('Disconnect-Request', user_attributes)
    end

    def accounting(action, name, sessionid, options = {})
      accounting_request(ACCOUNT_ACTIONS[action], name, sessionid, options)
    end

    private

    def default_options
      { reply_timeout: 60, retries_number: 1 }
    end

    def set_port
      @port ||= Socket.getservbyname("radius", "udp")
      @port ||= 1812
      @port = @port.to_i
    end

    def send_packet
      retries = @retries_number

      begin
        data = @packet.pack
        @socket.send(data, 0)
        @received_packet = recv_packet
      rescue Exception => e
        retry if (retries -= 1) > 0
        raise
      end

      return true
    end

    def recv_packet
      if select([@socket], nil, nil, @reply_timeout) == nil
        raise "Timed out waiting for response packet from server"
      end
      data = @socket.recvfrom(4096) # rfc2865 max packet length
      Packet.new(@dict, Process.pid & 0xff, data[0])
    end

    # looks up the source IP address with a route to the specified destination
    def get_my_ip(dest_address)
      orig_reverse_lookup_setting = Socket.do_not_reverse_lookup
      Socket.do_not_reverse_lookup = true

      UDPSocket.open do |sock|
        sock.connect dest_address, 1
        sock.addr.last
      end
    ensure
       Socket.do_not_reverse_lookup = orig_reverse_lookup_setting
    end
  end
end
