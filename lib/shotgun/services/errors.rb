module Shotgun
  class Services
    module Errors

      # Autoload errors that are related to failing HTTP requests. Most errors
      # can be subsumed by the singular {HttpError} that makes it easy to react
      # to different HTTP Status Code responses.

      autoload :HttpError, 'shotgun/services/errors/http_error'
      autoload :ConnectionError, 'shotgun/services/errors/connection_error'
      autoload :ResponseError, 'shotgun/services/errors/response_error'

    end
  end
end
