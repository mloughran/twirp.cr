# Generated from example.proto by twirp.cr
# require "twirp"

module Test
  abstract class Test::ExampleService
    include Twirp::Service

    @@service_name = "test.ExampleService"

    rpc HelloWorld, receives: ::Test::HelloWorldRequest, returns: ::Test::HelloWorldResponse
  end
end
