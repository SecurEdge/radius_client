require "simplecov"

SimpleCov.start do
  add_filter "test/"
end

$LOAD_PATH.unshift File.expand_path("../../lib", __FILE__)
require "radiustar"
require "minitest/autorun"
require "minitest/reporters"
require "pry"
# require "webmock/minitest"
# require "vcr"
# require "minitest-vcr"

Minitest::Reporters.use! Minitest::Reporters::SpecReporter.new

# WebMock.disable_net_connect!(allow_localhost: true)

# VCR.configure do |config|
#   config.cassette_library_dir = "test/fixtures/vcr_cassettes"
#   config.hook_into :webmock
# end

# MinitestVcr::Spec.configure!
