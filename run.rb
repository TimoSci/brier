require_relative './config.rb'
# APP_PATH = "~/code/brier"  # change this with setup.rb
load "#{APP_PATH}/src/cli.rb"

client = CLI.new
keyword = ARGV.first
client.submit(keyword)
