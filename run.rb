
load './src/cli.rb'

client = CLI.new
keyword = ARGV.first
client.submit(keyword)
