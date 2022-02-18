# twirp.cr

An implementation of [Twirp](https://github.com/twitchtv/twirp) in Crystal.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     twirp:
       github: mloughran/twirp.cr
   ```

2. Run `shards install`

## Usage

To see an example `proto` definition, generator, server, and client, see the included [example](https://github.com/mloughran/twirp.cr/example).

### Protobuf generator

Includes a `protoc` plugin for generating Twirp server and client implementations from a protobuf service definition.

	protoc --twirp_crystal_out=src --plugin=bin/protoc-gen-twirp_crystal example.proto

Typically you will also want to generate protobuf message definitions:

	protoc --crystal_out=src --plugin=bin/protoc-gen-crystal example.proto

### Twirp client

For example:

	```crystal
	require "./example.twirp.cr"
	require "./example.pb.cr"

	client = ExampleService::Client.new("localhost", 8080)

	req = HelloWorldRequest.new(name: "twirp")
	resp = client.hello_world(req)
	puts resp.greeting
	```

I've elected to raise an error (which will be a subclass of `Twirp::Error`) if a Twirp error response is received, rather that take the ruby approach of returning a result object. Exceptions will also be raised by the `HTTP::Client` in case of transport errors.

### Twirp server

Implement a handler (subclassing the generated abstract class):

	```crystal
	class ExampleHandler < ExampleService
	  def hello_world(req : HelloWorldRequest) : HelloWorldResponse
	    HelloWorldResponse.new(greeting: "Hello #{req.name}")
	  end
	end
	```

Pass this to a Twirp server (which is itself a `HTTP::Handler`):

	```crystal
	require "twirp/server"
	
	twirp_server = Twirp::Server.new(ExampleHandler.new)
	```

Expose this via a `HTTP::Server`:

	```crystal
	server = HTTP::Server.new(twirp_server)
	address = server.bind_tcp 8080
	puts "Listening on http://#{address}"
	server.listen
	```

To return a Twirp error, raise the appropriate `Twirp::Error` from your handler. For example:

	```crystal
	class ExampleHandler < ExampleService
	  def hello_world(req : HelloWorldRequest) : HelloWorldResponse
	    raise Twirp::Error::Unauthenticated.new("Sorry!")
	  end
	end
	```

#### Logging

`Twirp::Server` produces log output when handling handling requests. This can be customised, e.g.:

	```crystal
	Twirp::Log.level = Log::Severity::Warn
	```

## Development

Install shards and build

	shards install
	shards build

Verify that example generates cleanly

	cd example && make clean generate && cd -

Run server and client:

	crystal run example/server.cr
	crystal run example/client.cr

There are currently no specs, sorry.

## Contributors

- [Martyn Loughran](https://github.com/mloughran) - creator and maintainer

With thanks to https://github.com/jgaskins/grpc for the generator (which is more or less verbatim), and for inspiring the double-macro approach for the service DSL (since I'm still wrapping my head around crystal macros).
