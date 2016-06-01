module Radiustar
  require 'socket'

  class Request
    def initialize(server, options = {})
      @host, @port = server.split(":")
      set_port

      @dict = options[:dict].nil? ? Dictionary.default : options[:dict]
      @nas_ip = options[:nas_ip] || get_my_ip(@host)
      @nas_identifier = options[:nas_identifier] || @nas_ip
      @reply_timeout = options[:reply_timeout].nil? ? 60 : options[:reply_timeout].to_i
      @retries_number = options[:retries_number].nil? ? 1 : options[:retries_number].to_i

      @socket = UDPSocket.open
      @socket.connect(@host, @port)
    end

    def authenticate(name, password, secret, user_attributes = {})
      packet_attributes = {
        'User-Name' => name,
        'NAS-Identifier' => @nas_identifier,
        'NAS-IP-Address' => @nas_ip
      }.merge(user_attributes)

      @packet = Packet.new(@dict, Process.pid & 0xff)
      @packet.gen_auth_authenticator
      @packet.code = 'Access-Request'
      @packet.set_attributes packet_attributes
      @packet.set_encoded_attribute('User-Password', password, secret)

      send_packet

      reply = { code: @received_packet.code }
      reply.merge @received_packet.attributes
    end

    def authenticate_chap(name, password, secret, user_attributes = {})
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

    def accounting_request(status_type, name, secret, sessionid, user_attributes = {})
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

      @packet.gen_acct_authenticator(secret)

      send_packet
    end

    def generic_request(code, secret, user_attributes = {})
      packet_attributes = {
        'NAS-Identifier' => @nas_identifier,
        'NAS-IP-Address' => @nas_ip
      }.merge(user_attributes)

      @packet = Packet.new(@dict, Process.pid & 0xff)
      @packet.code = code
      @packet.set_attributes packet_attributes

      @packet.gen_acct_authenticator(secret)

      send_packet
    end

    def coa_request(secret, user_attributes = {})
      generic_request('CoA-Request', secret, user_attributes)
    end

    def disconnect_request(secret, user_attributes = {})
      generic_request('Disconnect-Request', secret, user_attributes)
    end

    def accounting_start(name, secret, sessionid, options = {})
      accounting_request('Start', name, secret, sessionid, options)
    end

    def accounting_update(name, secret, sessionid, options = {})
      accounting_request('Interim-Update', name, secret, sessionid, options)
    end

    def accounting_stop(name, secret, sessionid, options = {})
      accounting_request('Stop', name, secret, sessionid, options)
    end

    def inspect
      to_s
    end

    private

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
        @received_packet = recv_packet(@reply_timeout)
      rescue Exception => e
        retry if (retries -= 1) > 0
        raise
      end

      return true
    end

    def recv_packet(timeout)
      if select([@socket], nil, nil, timeout.to_i) == nil
        raise "Timed out waiting for response packet from server"
      end
      data = @socket.recvfrom(4096) # rfc2865 max packet length
      Packet.new(@dict, Process.pid & 0xff, data[0])
    end

    #looks up the source IP address with a route to the specified destination
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
