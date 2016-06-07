RadiusClient.configure do |config|
  config.host = "127.0.0.1"

  config.secret = ""

  # NOTICE: here the dictionary_dir only accept a parameter of "folder name"
  # but not the dictionary file
  config.dictionary_dir = "/usr/local/share/freeradius"

  config.db_name = "radius"

  config.db_user = "radius"
end
