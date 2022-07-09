require "http"

require "./client"
require "./error"

module Twirp
  module Service
    macro included
      def self.service_name
        @@service_name
      end

      def handle(method_name : String, request_body : IO)
        raise Twirp::Error::BadRoute.new("Unknown method #{@@service_name}/#{method_name}")
      end

      macro rpc(name, receives request_type, returns response_type)
        \{% method_name = name.stringify.underscore.id %}
        
        abstract def \{{method_name}}(req : \{{request_type}}) : \{{response_type}}

        def handle(method_name : String, request_body : IO)
          if method_name == \{{name.stringify}}
            \{{method_name}}(\{{request_type}}.from_protobuf(request_body))
          else
            previous_def(method_name, request_body)
          end
        end

        class Client < ::Twirp::Client({{@type.id}})
          def \{{method_name}}(req : \{{request_type}}) : \{{response_type}}
            call("\{{name}}", req, \{{response_type}})
          end
        end
      end
    end
  end
end
