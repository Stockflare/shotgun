module Shotgun
  class Path
    attr_reader :parts

    def initialize(*parts)
      @parts = parts.clone
    end

    def to_url
      (parts + [Shotgun.zone]).join('.').downcase
    end

    alias_method :to_s, :to_url
  end
end
