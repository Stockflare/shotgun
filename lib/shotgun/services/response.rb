require 'hashie'

module Shotgun
  class Services
    class Response < Hash

      include Hashie::Extensions::Coercion

      include Hashie::Extensions::MethodAccess

      coerce_value Hash, Hashie::Mash

      coerce_value Array, Array[Hashie::Mash]

      def initialize(hash = {})
        if hash.is_a? Hash
          super
          hash.each_pair { |k,v| self[k] = v }
        else
          Hashie::Mash.new hash
        end
      end

    end
  end
end
