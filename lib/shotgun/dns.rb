require 'resolv'

module Shotgun
  class DNS
    attr_reader :path

    def initialize(path)
      @path = path
    end

    def to_url
      @@url ||= Resolv::DNS.open do |dns|
        records = dns.getresources(record, "TXT")
        records.empty? ? nil : records.map(&:data)
      end
    end

    alias_method :to_s, :to_url

    def record
      "_#{path}.#{Shotgun.zone}"
    end
  end
end
