generate: example.twirp.cr example.pb.cr
	crystal tool format

example.twirp.cr:
	protoc --twirp_crystal_out=. --plugin=../bin/protoc-gen-twirp_crystal example.proto
	# The -i switch works differently in GNU vs BSD sed
	sed -i '' 's/^require/# &/g' example.twirp.cr || sed -i 's/^require/# &/g' example.twirp.cr

example.pb.cr:
	protoc --crystal_out=. --plugin=../bin/protoc-gen-crystal example.proto

clean:
	rm -f example.twirp.cr example.pb.cr
