puts "Starting up"

require 'rubygems'
require 'bundler/setup'
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

if rand > 0.5
  require 'httparty'

  start = Time.now

  response = HTTParty.get( $api_url, {
    query: { count: $count },
    headers: {
      "X-API-Token" => $api_token,
      "Accept" => $api_accept
    }
  })
  $servers = JSON.parse( response.body )

  puts "FETCHED\thttparty\t#{$servers.count} servers\t#{Time.now-start}"
else
  require 'uri'
  require 'net/http'

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

  puts "FETCHED\tnet/http\t#{$servers.count}\t#{Time.now-start}"
end

#
# Test
#

$servers.each do |server|
  (1..4).each do |i|
    label = "#{server['host']}:#{server['port']}"
    begin
      start = Time.now
      r = Redis.new( url: server["url"], timeout: 1 )
      r.ping
      puts "SUCCESS\t#{label}\t#{Time.now-start}"
      r.quit
    rescue
      puts "FAILED\t#{label}\t#{$!.inspect}"
    end
  end
end

