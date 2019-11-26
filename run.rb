
path = "~/code/brier"  # change this with setup.rb
load "#{path}/src/cli.rb"

client = CLI.new
keyword = ARGV.first
client.submit(keyword)
