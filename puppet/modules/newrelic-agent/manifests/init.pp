class newrelic-agent{
 

file { "/mnt/<%= name %>/shared/config/newrelic.yml":
    content => template("newrelic-agent/newrelic-ruby.rb"),
  }


 }
  
