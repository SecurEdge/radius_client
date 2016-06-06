require "rails/generators/base"

module RadiusClient
  module Generators
    class InstallGenerator < Rails::Generators::NamedBase
      source_root File.expand_path("../../templates", __FILE__)

      desc "Creates an initializer"

      def copy_initializer
        template "radius_client.rb", "config/initializers/radius_client.rb"
      end
    end
  end
end
