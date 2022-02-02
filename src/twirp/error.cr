require "json"

module Twirp
  # Implements all twirp errors as defined in
  # https://twitchtv.github.io/twirp/docs/spec_v7.html.
  #
  # Application code may raise such errors to trigger the appropriate error response.
  #
  class Error < Exception
    @@code = "unknown"
    @@status = 500

    def to_json(io)
      {
        code: @@code,
        msg:  message,
      }.to_json(io)
    end

    def status
      @@status
    end

    def code
      @@code
    end

    class InvalidArgument < Error
      @@code = "invalid_argument"
      @@status = 400
    end

    class Malformed < Error
      @@code = "malformed"
      @@status = 400
    end

    class OutOfRange < Error
      @@code = "out_of_range"
      @@status = 400
    end

    class Unauthenticated < Error
      @@code = "unauthenticated"
      @@status = 401
    end

    class PermissionDenied < Error
      @@code = "permission_denied"
      @@status = 403
    end

    class NotFound < Error
      @@code = "not_found"
      @@status = 404
    end

    class BadRoute < Error
      @@code = "bad_route"
      @@status = 404
    end

    class Canceled < Error
      @@code = "canceled"
      @@status = 408
    end

    class DeadlineExceeded < Error
      @@code = "deadline_exceeded"
      @@status = 408
    end

    class AlreadyExists < Error
      @@code = "already_exists"
      @@status = 409
    end

    class Aborted < Error
      @@code = "aborted"
      @@status = 409
    end

    class FailedPrecondition < Error
      @@code = "failed_precondition"
      @@status = 412
    end

    class ResourceExhausted < Error
      @@code = "resource_exhausted"
      @@status = 429
    end

    class Unknown < Error
      @@code = "unknown"
      @@status = 500
    end

    class Internal < Error
      def initialize(err : Exception)
        @message = "#{err.message} (#{err.class})"
      end

      @@code = "internal"
      @@status = 500
    end

    class Dataloss < Error
      @@code = "dataloss"
      @@status = 500
    end

    class Unimplemented < Error
      @@code = "unimplemented"
      @@status = 501
    end

    class Unavailable < Error
      @@code = "unavailable"
      @@status = 503
    end
  end
end
