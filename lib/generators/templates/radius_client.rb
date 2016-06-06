RadiusClient.configure do |config|
  config.host = "127.0.0.1"

  config.secret = ""

  config.dictionary_dir = "/usr/local/share/freeradius"

  config.db_name = "radius"

  config.db_user = "radius"
end
