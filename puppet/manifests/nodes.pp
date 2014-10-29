#default node for all client ,that will do systembase init module
node default {
       include systembase

#this will try to match ec2tag_name to init more modules
       case $ec2tag_name {

#match tag prod-web-*
                /^prod-web-*/: {
                $rails_env = 'production'
                $hostbase = 'prod'
                include puppetclient
                include common
                include ss-nginx
                include ruby
                include newrelic
                include newrelic-agent
                include systembase
                               }

                }

	
			    }

#this will use orgin puppet node type without default and ec2tag
node 'nagios.nicerelease.com' {
	include puppetclient
	#include app
	#include appserver
	include nagios-server 
	include ec2-ses
	#include systembase

}
