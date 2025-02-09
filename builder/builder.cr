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

# Create output directory
exec("mkdir -p .out")

shard_yml = File.open("shard.yml") do |file|
  YAML.parse(file)
end

shard_yml["targets"].as_h.each do |bin, main_path|
  main_file = main_path["main"].as_s
  output_file = ".out/#{bin}"
  
  # Build the binary
  exec("crystal build #{main_file} -o #{output_file} --release --static --no-debug")
  
  # Package the binary
  exec "mkdir -p lambda"
  exec "zip -j lambda/#{bin}.zip #{output_file}"
end
