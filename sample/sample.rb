require 'rubygems'
require 'jsparrow'

JSparrow::Connection.configure do |connection|
  connection.use_jms_client_jar '/opt/openjms/lib/openjms-0.7.7-beta-1.jar'

  connection.use_jndi_properties :initial_context_factory => 'org.exolab.jms.jndi.InitialContextFactory',
                                 :provider_url            => 'tcp://localhost:3035'
                               # :security_principal      => 'user',
                               # :security_credentials    => 'password'

  connection.enable_connection_factories :queue_connection_factory => 'ConnectionFactory', 
                                         :topic_connection_factory => 'ConnectionFactory'
end

jms_client = JSparrow::Connection.new_client
jms_client.enable_queues :pardal_queue => 'PardalQueue'

jms_client.start

jms_client.queue_sender(:pardal_queue).send_text_message('jsparrow rocks!') do |msg|
  msg.set_string_property('recipient', 'jsparrow-example')
end

jms_client.queue_receiver(:pardal_queue).receive_message(
    :timeout  => 5000,
    :selector => "recipient = 'jsparrow-example'"
  ) do |msg|
  
  puts "is text message? #{msg.is_text_message?}"    # is text message? true
  puts "message: #{msg.text}"                        # message: jsparrow rocks!
end

jms_client.stop