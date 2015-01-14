puts "Starting up"

require 'rubygems'
require 'bundler/setup'
require 'redis'

(1..10).each do |i|
  puts "Try: #{i}"
  begin
    start = Time.now
    Redis.new( url: ENV["REDISGREEN_URL"], timeout: 1 ).ping
    puts "Successful: (#{Time.now-start}s)"
  rescue
    puts "Failed: #{$!.inspect}"
  end
end

