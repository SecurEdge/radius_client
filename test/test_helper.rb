require "pathname"
require "simplecov"

SimpleCov.start do
  add_filter "test/"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "radiustar"
require "minitest/autorun"
require "minitest/reporters"
require "pry"

Dir[Pathname.new(Dir.pwd).join("test/support/**/*.rb")].each { |f| require f }

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new
