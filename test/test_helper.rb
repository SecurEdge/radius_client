require "pathname"
require "simplecov"

SimpleCov.start do
  add_filter "test/"
end

require File.expand_path("../../lib/radius_client", __FILE__)
require "radius_client"
require "minitest/autorun"
require "minitest/reporters"
require "pry"

Dir[Pathname.new(Dir.pwd).join("test/support/**/*.rb")].each { |f| require f }

Minitest::Reporters.use!
