require "../src/twirp"

require "./example.twirp.cr"
require "./example.pb.cr"

client = Test::ExampleService::Client.new(URI.parse("http://localhost:8080"))

response = client.hello_world(Test::HelloWorldRequest.new(name: "twirp client"))

puts "Service replied: #{response.greeting}"
