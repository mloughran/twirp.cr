require "http/server"
require "protobuf"

require "./service"
require "./error"

module Twirp
  class Server
    include HTTP::Handler

    @services = Hash(String, Service).new

    # Exception handler is called on non-twirp handler exceptions
    @exception_handler : Proc(Exception, Nil)

    def initialize(service = nil, @prefix = "/twirp", @exception_handler = ->(ex : Exception) {})
      self << service if service
    end

    def <<(service : Service)
      @services[service.class.service_name] = service
      self
    end

    def call(context : HTTP::Server::Context)
      handler_return = handle(context.request, context.response)

      case handler_return
      in Protobuf::Message
        context.response.content_type = "application/protobuf"
        handler_return.to_protobuf(context.response.output)
      in Twirp::Error
        context.response.content_type = "application/json"
        context.response.status_code = handler_return.status
        handler_return.to_json(context.response.output)
      end
    end

    private def handle(request, response) : Protobuf::Message | Twirp::Error
      unless request.method == "POST"
        msg = "Unsupported method #{request.method} (only POST is allowed)"
        Log.warn { msg }
        return Error::BadRoute.new(msg)
      end

      content_type = request.headers["Content-Type"]?

      unless content_type == "application/json" || content_type == "application/protobuf"
        msg = "Unexpected Content-Type: #{content_type.inspect}"
        Log.warn { msg }
        return Error::BadRoute.new(msg)
      end

      if content_type == "application/json"
        # protobuf.cr shard does not support JSON encoding/decoding
        Log.warn { "Received application/json request which is not yet supported" }
        return Error::Unimplemented.new("Content-Type application/json not yet supported")
      end

      unless body = request.body
        msg = "Failed to read request body"
        Log.warn { msg }
        return Error::Malformed.new(msg)
      end

      prefix, service_name, method_name = parse_twirp_path(request.path)

      unless prefix == @prefix
        msg = "Invalid path prefix '#{prefix}' (expected '#{@prefix}') in call to #{request.path}"
        Log.warn { msg }
        return Error::BadRoute.new(msg)
      end

      unless service = @services[service_name]?
        msg = "Unknown service #{service_name}"
        Log.warn { msg }
        return Error::BadRoute.new(msg)
      end

      begin
        response_msg = service.handle(method_name, body)
        Log.info { "#{service_name}/#{method_name} completed" }
        return response_msg
      rescue err : Twirp::Error
        Log.warn { "#{service_name}/#{method_name} raised twirp error: #{err.code}" }
        return err
      rescue err
        Log.warn(exception: err) { "#{service_name}/#{method_name} raised a non-twirp error" }
        @exception_handler.call(err)
        return Twirp::Error.from_exception(err)
      end
    end

    # Converts /twirp/prefix/svc/method to {"/twirp/prefix", "svc", "method"}
    private def parse_twirp_path(path : String) : {String, String, String}
      *prefixes, service, method = path.split("/")

      {prefixes.join("/"), service, method}
    end
  end
end
