#!/usr/bin/env ruby

require 'uri'
require 'webrick'

host = ENV['BLACKBOX_EXPORTER_HOST'] or raise "BLACKBOX_EXPORTER_HOST not set."
port = ENV['PORT'] || 8081

server = WEBrick::HTTPServer.new Port: port

server.mount_proc '/' do |req, res|
  _, probe, mod, *url = req.unparsed_uri.split("/")

  mod    = mod
  target = url.join("/")

  require 'net/http'
  uri      = URI("http://#{host}/probe?target=#{target}&module=#{mod}")
  body     = Net::HTTP.get(uri)
  res.body = body
end

trap 'INT'  do server.shutdown end
trap 'TERM' do server.shutdown end

server.start
