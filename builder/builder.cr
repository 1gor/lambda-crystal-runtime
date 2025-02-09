require "yaml"
require "compress/zip"
require "io"

BUILDER_PATH = "/lambda-builder"

def exec(command)
  io = IO::Memory.new
  res = Process.run(command, shell: true, output: io)
  output = io.to_s
  puts io.to_s if output.size > 0
  raise "command execution error" unless res.success?
  res.success?
end

puts "Start building binaries..."

exec("shards build --static --release --no-debug -o bootstrap")

shard_yml = File.open("shard.yml") do |file|
  YAML.parse(file)
end

shard_yml["targets"].as_h.each do |bin, main_path|
  bin_path = main_path["main"].as_s.split("/")[0...-1].join("/") + "/" + bin.as_s

  exec "mkdir -p lambda"
  exec "zip -j lambda/#{bin}.zip bootstrap"
end
