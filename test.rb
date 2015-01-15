puts "Starting up"

require 'rubygems'
require 'bundler/setup'
require 'httparty'
require 'json'
require 'redis'

#
# Setup
#

$count = ENV["COUNT"]
$api_url = ENV["API_URL"]
$api_token = ENV["API_TOKEN"]
$api_accept = ENV["API_ACCEPT"]

#
# Fetch servers
#

puts "Fetching #{$count} random servers"

response = HTTParty.get( $api_url, {
  query: { count: $count },
  headers: {
    "X-API-Token" => $api_token,
    "Accept" => $api_accept
  }
})
servers = JSON.parse( response.body )

puts "Got #{servers.size} servers"

#
# Test
#

servers.each do |server|
  (1..4).each do |i|
    puts "Connecting to #{server['host']}:#{server['port']}"
    begin
      start = Time.now
      r = Redis.new( url: server["url"], timeout: 1 )
      r.ping
      puts "Successful: (#{Time.now-start}s)"
      r.quit
    rescue
      puts "Failed: #{$!.inspect}"
    end
  end
end

