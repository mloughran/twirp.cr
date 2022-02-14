require "../src/twirp"
require "../src/twirp/server"

require "./example.twirp.cr"
require "./example.pb.cr"

class ExampleHandler < Test::ExampleService
  def hello_world(req : Test::HelloWorldRequest) : Test::HelloWorldResponse
    Test::HelloWorldResponse.new(greeting: "Hello #{req.name}")
  end
end

twirp_server = Twirp::Server.new(ExampleHandler.new)

server = HTTP::Server.new(twirp_server)
address = server.bind_tcp 8080
puts "Listening on http://#{address}"
server.listen
