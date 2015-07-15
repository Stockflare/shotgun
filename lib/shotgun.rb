require "shotgun/version"

module Shotgun
  autoload :Properties, 'shotgun/properties'
  autoload :Services, 'shotgun/services'

  def self.zone=(val)
    @@zone = val
  end

  def self.zone
    @@zone
  rescue
    ENV['HOSTED_ZONE']
  end
end
