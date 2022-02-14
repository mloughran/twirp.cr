require "json"

module Twirp
  # Struct used to serialize and deserialize Twirp's JSON serialization of errors
  struct Twerr
    include JSON::Serializable

    getter code : String
    getter msg : String?
    getter meta : Hash(String, JSON::Any) | Nil

    def initialize(@code, @msg)
    end

    def to_err : Twirp::Error
      CODE_TO_ERROR.fetch(@code, Twirp::Error).new(@msg)
    end

    CODE_TO_ERROR = {
      "invalid_argument"    => Error::InvalidArgument,
      "malformed"           => Error::Malformed,
      "out_of_range"        => Error::OutOfRange,
      "unauthenticated"     => Error::Unauthenticated,
      "permission_denied"   => Error::PermissionDenied,
      "not_found"           => Error::NotFound,
      "bad_route"           => Error::BadRoute,
      "canceled"            => Error::Canceled,
      "deadline_exceeded"   => Error::DeadlineExceeded,
      "already_exists"      => Error::AlreadyExists,
      "aborted"             => Error::Aborted,
      "failed_precondition" => Error::FailedPrecondition,
      "resource_exhausted"  => Error::ResourceExhausted,
      "unknown"             => Error::Unknown,
      "internal"            => Error::InvalidArgument,
      "dataloss"            => Error::Dataloss,
      "unimplemented"       => Error::Unimplemented,
      "unavailable"         => Error::Unavailable,
    }
  end

  # Implements all twirp errors as defined in
  # https://twitchtv.github.io/twirp/docs/spec_v7.html.
  #
  # Application code may raise such errors to trigger the appropriate error response.
  #
  class Error < Exception
    # Wrap an arbitrary exception as a twirp error (unless it's already one!)
    def self.from_exception(ex : Exception) : Twirp::Error
      case ex
      when Twirp::Error
        ex
      else
        Internal.new("#{ex.message} (#{ex.class})")
      end
    end

    def self.from_json(io)
      Twerr.from_json(io).to_err
    end

    def to_json(io)
      Twerr.new(code, message).to_json(io)
    end

    @@code = "unknown"
    @@status = 500

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
