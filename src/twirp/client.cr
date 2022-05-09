require "http/client"

require "./error"

module Twirp
  class Client(T)
    def initialize(host : String, port : Int32, @prefix = "/twirp")
      @client = HTTP::Client.new(host, port)
    end

    # Adds a callback to execute before each request (see `HTTP::Client#before_request`)
    def before_request(&callback : HTTP::Request ->) : Nil
      @client.before_request(&callback)
    end

    def call(rpc_name, request, response_type)
      response = @client.post("#{@prefix}/#{T.service_name}/#{rpc_name}",
        headers: HTTP::Headers{"Content-Type" => "application/protobuf"},
        body: request.to_protobuf,
      )

      unless body = response.body?
        raise Twirp::Error::Malformed.new("Failed to read response body")
      end

      case response.content_type
      when "application/json"
        begin
          raise Twirp::Error.from_json(body)
        rescue err : JSON::SerializableError
          raise Twirp::Error.new("Failed to parse JSON response: #{err}")
        end
      when "application/protobuf"
        response_type.from_protobuf(IO::Memory.new(body))
      else
        raise Twirp::Error.new("Unexpected response Content-Type: #{response.content_type}")
      end
    end
  end
end
