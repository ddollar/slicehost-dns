#!/usr/bin/env ruby

require 'rubygems'
require 'activeresource' 
require 'preferences'
require 'ruby-debug'

PREFERENCES = Preferences::Manager.new :slicehostdns

class Zone < ActiveResource::Base 
  self.site = "https://#{PREFERENCES['password']}@api.slicehost.com/" 
end

class Record < ActiveResource::Base 
  self.site = "https://#{PREFERENCES['password']}@api.slicehost.com/" 
end

RAILS_DEFAULT_LOGGER = Logger.new('/tmp/foo')

def list
  zones = Zone.find(:all)
  records = Record.find(:all)

  zones.each do |zone|
    puts "#{zone.origin}"
    records.find_all { |record| record.zone_id == zone.id }.each do |record|
      puts "  #{record.name}"
    end
  end
end

def add(domain)
  zone = Zone.new(:origin => "#{domain}.", :ttl => 3600)
  zone.save
  Record.new(:record_type => 'A',  :zone_id => zone.id, :name => "*",          :data => "IP.ADD.RESS").save
  Record.new(:record_type => 'A',  :zone_id => zone.id, :name => "#{domain}.", :data => "IP.ADD.RESS").save
  Record.new(:record_type => 'NS', :zone_id => zone.id, :name => "#{domain}.", :data => "ns1.slicehost.net.").save
  Record.new(:record_type => 'NS', :zone_id => zone.id, :name => "#{domain}.", :data => "ns2.slicehost.net.").save
  Record.new(:record_type => 'NS', :zone_id => zone.id, :name => "#{domain}.", :data => "ns3.slicehost.net.").save
end

def rm(domain)
  Zone.find(:all).each do |zone|
    if zone.origin == "#{domain}."
      Zone.delete(zone.id)
    end
  end
end

if ARGV.length.zero?
  puts "USAGE:"
  puts "  SliceHostDNS.rb list"
  puts "  SliceHostDNS.rb add  [domain]"
  puts "  SliceHostDNS.rb rm   [domain]"
  exit 1
end

case ARGV[0]
  when 'list': list
  when 'add': add(ARGV[1])
  when 'rm': rm(ARGV[1])
end

#puts Zone.find(:all)

# # Creating a new Zone 
# myzone = Zone.new(:origin => ‘example.com’, :ttl => 3000) 
# myzone.save 
# # Creating a record for that Zone 
# myrecord = Record.new(:record_type => 'A', :zone_id => 12345, 
# 
#  
#  
#  
#  :name => 'www', :data => '127.0.0.1') 
# myrecord.save 
# # Updating the record 
# myrecord.ttl = 55000 
# myrecord.save 
# # Deleting the record 
# myrecord.destroy 
# # Back to our Zone 
# zid = myzone.id # The ID of the new Zone 
#                 # Let’s use this to re-retrieve the Zone 
# myzone = nil 
# myzone = Zone.find(zid) # Retrieving the same Zone we just created 
# myzone.ttl = 8000 
# myzone.save # Updating the TTL 
# myzone.destroy # Destroying the Zone 
