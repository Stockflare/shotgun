require 'json'

module Shotgun
  class Services
    class Handler
      attr_reader :response, :status, :headers, :options

      def initialize(response, options = {})
        @response = response
        @status = response.status
        @headers = response.headers.dup

        unless (200...300).include? status
          raise Errors::HttpError.new(response),
            "expected 2xx code, got #{response.status}"
        end
      end

      def parse!
        case content_type
        when /json/ then parse_json_body response.body
        else response.body
        end
      rescue
        response.body
      end

      def body
        @body ||= parse!
      end

      private

      def content_type
        headers['Content-Type']
      end

      def parse_json_body(body)
        response = as_json body
        case response
        when Hash
          ::Hashie::Mash.new response
        when Array
          response.collect { |el| ::Hashie::Mash.new el }
        else
          raise Errors::ResponseError.new,
            "unexpected body of #{response.class.name}."
        end
      end

      def as_json(body)
        JSON.parse(body)
      rescue JSON::ParserError => error
        raise Errors::ResponseError.new,
          "error parsing JSON response: #{error.message}"
      end

    end
  end
end
