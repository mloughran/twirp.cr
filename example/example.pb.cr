# # Generated from example.proto for test
require "protobuf"

module Test
  struct HelloWorldRequest
    include ::Protobuf::Message

    contract_of "proto3" do
      optional :name, :string, 1
    end
  end

  struct HelloWorldResponse
    include ::Protobuf::Message

    contract_of "proto3" do
      optional :greeting, :string, 1
    end
  end
end
