module Shotgun
  class Services
    # The Mapper module facilitates programmatic access to micro-services, as if
    # they were present within the application itself. Specifically, it uses a
    # combination of recursive dynamic namespace injection, as well as
    # contextualised service and method calling to construct a path to an internal
    # micro-service, as well as the type of call to execute.
    #
    # Host determination and port selection is taken care of automatically,
    # based upon an assumed shared configuration within the environment.
    module Mapper

      def self.included(klass)
        klass.extend(ClassMethods)
      end

      module ClassMethods

        # Returns the full path for this service, including any appended suffixes.
        #
        # @example constructing paths for a service
        #   Shotgun::Services::User._path(:admin) #=> "admin.user"
        #   Shotgun::Services::User._path #=> "user"
        #
        # @overload _path
        #   Retrieves the path for this service, prefixed by the services path.
        #   @return [string] a dot delimited service path.
        #
        # @overload _path(*suffixes)
        #   Retrieves the path for this service, with dot delimited suffixes.
        #   @return [string] a dot delimited service path, including suffixes.
        def _path(*suffixes)
          ((suffixes || []).reverse + [_rel]).join('.')
        end

        # Retrieve the relative service path, excluding the base, containing
        # namespace.
        #
        # @example the relative service path
        #   class Services < Shotgun::Services
        #   end
        #   Services::User::Admin._rel #=> "admin.user"
        #
        # @return [string] a dot delimited relative service path.
        def _rel
          _parts.slice(1..._parts.length).reverse.join('.')
        end

        # When a constant is requested that is missing, this function builds
        # the desired constant, extending itself in a recursive manner,
        # facilitating dynamic micro-service definition.
        #
        # @note Once a class has been defined as a micro-service here, it is
        #   set within the namespace, meaning all subsequent calls do not re-
        #   define the class.
        def const_missing(name)
          klass = Class.new
          klass.extend ClassMethods
          klass.send :prepend, ContextMethods
          set_context_accessor name
          const_set name, klass
        end

        # @!method create(attrs = {})
        #   Executes a POST request on the service, using the attributes provided.
        #   @param [hash] attrs used to create a new entity on the service
        #   @yield [response] passes through the parsed response to the block.
        #   @yieldparam response [hash] A Hashie parsed response from the service.
        #   @return [Transport] an initialised transport instance

        # @!method get(attrs = {})
        #   Executes a GET request on the service, using provided attributes
        #   as a query string.
        #   @param [hash] attrs used to use as a query string.
        #   @yield [response] passes through the parsed response to the block.
        #   @yieldparam response [hash] A Hashie parsed response from the service.
        #   @return [Transport] an initialised transport instance

        { create: :post, get: :get }.each do |name, type|
          define_method(name) do |attrs = {}, &block|
            transport '/', attrs, method: type, &block
          end
        end

        # Find a specific record within the service, using the standard REST
        # method (/:id). This method sends a GET request to the service.
        #
        # @param [mixed] id of the entity to retrieve from the service
        # @param [hash] attrs to send as a query string
        # @yield [response] passes through the parsed response to the block.
        # @yieldparam response [hash] A Hashie parsed response from the service.
        #
        # @return [{Transport}] an initialised transport instance.
        def find(id, attrs = {}, &block)
          transport id, attrs, method: :get, &block
        end

        # When a missing method name is called on a micro-service class, it is
        # caught here and passed through to a newly initialied {Transport} object.
        #
        # @note This call essentially enables you to pass through options used
        #   to efficiently build API calls to other internal micro-services.
        #
        # @yield [response] passes through the parsed response to the block.
        # @yieldparam response [hash] A Hashie parsed response from the service.
        #
        # @return [{Transport}] an initialised transport instance.
        def method_missing(name, *args, &block)
          transport name, *args, &block
        end

        private

        def set_context_accessor(name)
          define_singleton_method(name.capitalize) { |*a| const_get(name).new(*a) }
        end

        def _parts
          self.name.split(/::/).collect(&:downcase)
        end

        def transport(*args, &block)
          Transport.new _path, *args, &block
        end

      end

      module ContextMethods

        attr_reader :context

        def initialize(*context)
          @context = context.collect(&:to_s).join('/')
        end

        # Returns the full path for this contextualised service,
        # including any appended suffixes.
        #
        # @example constructing paths for a service
        #   Shotgun::Services::Internal::User.new(:admin, 12345)._path #=> "user.internal"
        #
        # @return [string] a dot delimited service path.
        def _path
          self.class._path
        end

        # When a missing method name is called on a micro-service class, it is
        # caught here and passed through to a newly initialied {Transport} object.
        #
        # @note This call essentially enables you to pass through options used
        #   to efficiently build API calls to other internal micro-services.
        #
        # @yield [response] passes through the parsed response to the block.
        # @yieldparam response [hash] A Hashie parsed response from the service.
        #
        # @return [{Transport}] an initialised transport instance.
        def method_missing(name, *args, &block)
          transport "#{context}/#{name}", *args, &block
        end

        # @!method update(attrs = {})
        #   Executes a PUT request on the service, using provided attributes
        #   as the body used to update the entity being used as the context.
        #   @param [hash] attrs used to use as the update body
        #   @yield [response] passes through the parsed response to the block.
        #   @yieldparam response [hash] A Hashie parsed response from the service.

        # @!method delete(attrs = {})
        #   Executes a DELETE request on the service, intending to delete the
        #   entity that is represented within this context. Additional attributes
        #   are sent along with the body of the request.
        #   @param [hash] attrs sent along with the DELETE request.
        #   @yield [response] passes through the parsed response to the block.
        #   @yieldparam response [hash] A Hashie parsed response from the service.

        { update: :put, delete: :delete, get: :get }.each do |name, type|
          define_method(name) do |attrs = {}, &block|
            transport context, attrs, method: type, &block
          end
        end

        private

        def transport(*args, &block)
          Transport.new _path, *args, &block
        end

      end

    end
  end
end
