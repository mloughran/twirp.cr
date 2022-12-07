require "http/client"
require "db/pool"

require "./error"

module Twirp
  class Client(T)
    @callback : HTTP::Request -> = Proc(HTTP::Request, Nil).new { }

    def initialize(@uri : URI)
      @prefix = uri.path.presence || "/twirp"
      @pool = DB::Pool(HTTP::Client).new do
        http = HTTP::Client.new(@uri)
        http.before_request { |req| @callback.call req }
        http
      end
    end

    # Adds a callback to execute before each request (see `HTTP::Client#before_request`)
    def before_request(&@callback : HTTP::Request ->) : Nil
    end

    def call(rpc_name, request, response_type)
      path = "#{@prefix}/#{T.service_name}/#{rpc_name}"
      headers = HTTP::Headers{"Content-Type" => "application/protobuf"}
      @pool.checkout do |http|
        http.post(path, headers: headers, body: request.to_protobuf) do |response|
          case response.content_type
          when "application/json"
            begin
              raise Twirp::Error.from_json(response.body_io)
            rescue err : JSON::SerializableError
              raise Twirp::Error.new("Failed to parse JSON response: #{err}")
            end
          when "application/protobuf"
            response_type.from_protobuf(response.body_io)
          else
            raise Twirp::Error.new("Unexpected response Content-Type: #{response.content_type}")
          end
        end
      end
    end
  end
end
