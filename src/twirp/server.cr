require "http/server"
require "protobuf"

require "./service"
require "./error"

module Twirp
  class Server
    include HTTP::Handler

    @services = Hash(String, Service).new

    def initialize(service = nil, @prefix = "/twirp")
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
        return Error::BadRoute.new("Unsupported method #{request.method} (only POST is allowed)")
      end

      content_type = request.headers["Content-Type"]?

      unless content_type == "application/json" || content_type == "application/protobuf"
        return Error::BadRoute.new("Unexpected Content-Type: #{content_type.inspect}")
      end

      if content_type == "application/json"
        # protobuf.cr shard does not support JSON encoding/decoding
        return Error::Unimplemented.new("Content-Type application/json not yet supported")
      end

      unless body = request.body
        return Error::Malformed.new("Failed to read request body")
      end

      prefix, service_name, method_name = parse_twirp_path(request.path)

      unless prefix == @prefix
        return Error::BadRoute.new("Invalid path prefix '#{prefix}', expected '#{@prefix}'")
      end

      unless service = @services[service_name]?
        return Error::BadRoute.new("Unknown service #{service_name}")
      end

      begin
        response_msg = service.handle(method_name, body)
        Log.info { "#{service_name}/#{method_name} completed" }
        return response_msg
      rescue err : Twirp::Error
        Log.info { "#{service_name}/#{method_name} raised error: #{err.class}" }
        return err
      rescue err
        Log.info { "#{service_name}/#{method_name} raised error: #{err.class}" }
        return Twirp::Error::Internal.new(err)
      end
    end

    # Converts /twirp/prefix/svc/method to {"/twirp/prefix", "svc", "method"}
    private def parse_twirp_path(path : String) : {String, String, String}
      *prefixes, service, method = path.split("/")

      {prefixes.join("/"), service, method}
    end
  end
end
