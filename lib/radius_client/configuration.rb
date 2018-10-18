module RadiusClient
  class Configuration
    attr_accessor :secret, :host, :dictionary_dir,
                   :db_host, :db_name, :db_user,
                   :db_max_connections, :db_password, :db_port
  end
end
