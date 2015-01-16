puts "Starting up"

require 'rubygems'
require 'bundler/setup'
require 'uri'
require 'net/http'
require 'json'
require 'redis'

#
# Setup
#

$count = ENV["COUNT"]
$api_url = ENV["API_URL"]
$api_token = ENV["API_TOKEN"]
$api_accept = ENV["API_ACCEPT"]
$timeout = ENV["TIMEOUT"].to_i

#
# Fetch servers
#

start = Time.now

uri = URI( $api_url+"?count=#{$count}" )
params = { count: $count }
uri.query = URI.encode_www_form( params )

req = Net::HTTP::Get.new( uri )
req["X-API-Token"] = $api_token
req["Accept"] = $api_accept
http = Net::HTTP.new( uri.host, uri.port )
http.use_ssl = uri.scheme == "https"
$servers = JSON.parse( http.request( req ).body )

puts "FETCHED\t#{$servers.count}\t#{Time.now-start}"

#
# Test
#

$servers.each do |server|
  (1..4).each do |i|
    label = "#{server['host']}:#{server['port']}\t#{server['az']}\t#{server['aws_id']}"
    begin
      start = Time.now
      r = Redis.new( url: server["url"], timeout: $timeout )
      r.ping
      puts "SUCCESS\t#{label}\t#{Time.now-start}"
      r.quit
    rescue
      puts "FAILED\t#{label}\t#{$!.inspect}\t#{Time.now-start}"
    end
  end
end

