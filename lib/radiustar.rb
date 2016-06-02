require "pathname"

module Radiustar
  PATH = Pathname.new(Dir.pwd).join('lib').freeze

  def self.require_lib!
    Dir.glob(File.join(PATH, '**', '*.rb'), &method(:require))
  end
end

Radiustar.require_lib!
