#!/usr/bin/env ruby
# vpn monitor
# requires ruby 2.1.X
# TODO 

require 'rubygems'
require 'aws-sdk'
#require 'log4r'
require 'hipchat'
require 'pp'

hipchat = HipChat::Client.new("APINUMBER")

regions = ["us-west-2", "ap-southeast-1", "ap-northeast-1"]
regions.each do |region|
	ec2 = Aws::EC2::Client.new(region: region)
	#resp = ec2.describe_vpn_connections(vpn_connection_ids: ["vpn-XXXX"])'
	resp = ec2.describe_vpn_connections()
	resp.each do |vpns|
		vpns.vpn_connections.each do |vpn|
			if vpn.state.eql?("available")
				tunnels_up = 0
				vpn.vgw_telemetry.each do |tunnel|
					if tunnel.status.eql?("UP")
						tunnels_up += 1
					end
				end
				if tunnels_up == 0 
					hipchat["free beer"].send('AWS VPN', "#{region} #{vpn.vpn_connection_id} has no tunnels available", :color => 'red' )
				else
					puts "In #{region} #{vpn.vpn_connection_id} has #{tunnels_up} tunnel(s) up"
				end
			end
		end
	end
end
#pp resp