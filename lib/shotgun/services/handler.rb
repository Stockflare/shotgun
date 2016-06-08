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
        when /json/ then parse_json_body(as_json(response.body))
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
        case body
        when Hash
          ::Hashie::Mash.new body
        when Array
          body.collect { |el| parse_json_body(el) }
        else
          body
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
