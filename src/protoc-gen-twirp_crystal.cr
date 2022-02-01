require "./twirp"
require "./twirp/generator"

# Run with LOG_LEVEL=DEBUG to see debug output
Log.setup_from_env(backend: Log::IOBackend.new(STDERR))

req = Protobuf::CodeGeneratorRequest.from_protobuf(STDIN)

STDERR.puts "Generating twirp classes... (twirp.cr v#{Twirp::VERSION})"

Twirp::Generator.call(req).to_protobuf(STDOUT)
