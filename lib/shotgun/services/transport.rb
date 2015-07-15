require 'faraday'
require 'json'

module Shotgun
  class Services
    # This class handles building and sending requests and processing
    # responses from micro-services.
    #
    # Upon initialization, the {Transport} class sets up all necessary instance
    # variables. It is only if a block is passed in to the constructor, or if
    # the #response method is called, that the request is triggered. Once a
    # request is executed, subsequent calls to #response will return the same
    # response oject.
    #
    # A number of errors are raised through this class, depending upon the
    # result of the processed request. See the
    # {Shotgun::Services::Errors} module for more information pertaining
    # to which errors are fired and when.
    class Transport

      # @!attribute [r] sub
      #
      #   @return [string] the sub service path inside etcd, that running hosts
      #     can be found at.

      # @!attribute [r] path
      #
      #   @return [string] the HTTP URL path to request from a valid host running
      #     the desired micro-service.

      # @!attribute [r] body
      #
      #   @note Whether or not the body is sent as a query string is determined
      #     by the HTTP Method requested.
      #
      #   @return [hash] the request body, or query string that will be sent
      #     at request time.

      # @!attribute [r] opts
      #
      #   @option opts [symbol] :method (:get) The HTTP method to be executed.
      #   @option opts [symbol] :protocol (:http) The HTTP method to be used.
      #
      #   @return [hash] additional options that modify the request. Such as the
      #     HTTP method.

      attr_reader :sub, :path, :body, :opts

      # Initializes a new instance of the Transport class, preparing all options
      # that build the intended request to be made to the micro-service.
      #
      # This class also determines at random, which host (if there are more than
      # one) the request will be sent to.
      #
      # @yield [response] passes the response from the service to the block.
      # @yieldparam [{Response}] response that has been received from the micro-service.
      def initialize(sub, path, body = {}, opts = {}, &block)
        @sub = sub
        @path = path.to_s
        @body = body
        @opts = opts
        block.call response if block
      end

      # Executes the request that has been built inside the instantiated object.
      #
      # @note This method will actually execute the request, subsequent calls to
      #   the #response method, will not execute another HTTP request, but will
      #   only return the same object.
      #
      # @raise [{Errors::HttpError}] if the HTTP response status code is not 2xx.
      #
      # @return [{Response}] a well-formed Hashie response object, returned from
      #   the micro-service.
      def response
        unless @response
          @response = handler request
        else
          @response
        end
      end

      # Returns true if the desired HTTP Method is a GET request.
      #
      # @return [boolean] true if GET, false otherwise
      def get?
        method == :get
      end

      # Returns true if the desired HTTP Method is a POST request.
      #
      # @return [boolean] true if POST, false otherwise
      def post?
        method == :post
      end

      # Returns true if the desired HTTP Method is a DELETE request.
      #
      # @return [boolean] true if DELETE, false otherwise
      def delete?
        method == :delete
      end

      # Returns true if the desired HTTP Method is a PATCH or PUT request.
      #
      # @return [boolean] true if PATCH or PUT, false otherwise
      def patch?
        method == :put || method == :patch
      end

      alias_method :put?, :patch?

      # Returns a downcased symbol, representing the HTTP Method of the
      # request that will be executed.
      #
      # @return [symbol] the HTTP method of the request, for example :post
      def method
        (opts[:method] || :get).to_s.downcase.to_sym
      end

      # Returns the protocol to be used as the request. For example, if using
      # shotgun to send requests to mysql, the protocol would become :mysql.
      #
      # @return [symbol] the downcased protocol to be used in the request
      def protocol
        (opts[:protocol] || :http).to_s.downcase.to_sym
      end

      def url
        if !env_url
          "#{protocol}://#{sub}.#{domain}"
        else
          "#{protocol}://#{env_url}"
        end
      end

      private

      def request
        Faraday.new(url: url).send(method, path) do |req|
          req.params = body if get?
          req.body = body unless get?
        end
      end

      def handler(response)
        if (200...300).include? response.status
          Response.new JSON.parse(response.body)
        else
          raise Errors::HttpError.new(response), "expected 2xx code, got #{response.status}"
        end
      end

      def domain
        Shotgun.zone
      end

      def env_url
        ENV["SERVICE_#{sub.gsub(/\./,'_').upcase}_URL"]
      end

    end
  end
end
