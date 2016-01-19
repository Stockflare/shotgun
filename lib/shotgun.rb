require "shotgun/version"

module Shotgun
  autoload :Path, 'shotgun/path'
  autoload :DNS, 'shotgun/dns'

  def self.url_for(*_)
    Path.new(*_).to_url
  end

  def self.alias(*_)
    DNS.new(*_).to_url
  end

  def self.zone=(val)
    @@zone = val
  end

  def self.zone
    @@zone
  rescue
    ENV['HOSTED_ZONE']
  end
end
