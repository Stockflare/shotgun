require 'resolv'

module Shotgun
  class DNS
    attr_reader :parts

    def initialize(*parts)
      @parts = parts.clone
    end

    def to_url
      @@url ||= Resolv::DNS.open do |dns|
        records = dns.getresources(record, "TXT")
        records.empty? ? nil : records.map(&:data).to_s.downcase
      end
    end

    alias_method :to_s, :to_url

    def record
      "_#{parts.join('_').downcase}.#{Shotgun.zone}"
    end
  end
end
