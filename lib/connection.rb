# Classes java usadas nesse arquivo
import 'java.util.Hashtable'
import 'javax.naming.InitialContext'

module Sparrow
  module JMS
    module Connection

      #
      # Configura��es necess�rias para que clientes JMS se conectem
      # ao servidor de aplica��es Java EE via JNDI Context.
      #
      class Properties
        attr_accessor :client_jar_file,
                      :initial_context_factory, :provider_url,
                      :security_principal, :security_credentials
        
        #
        # Cria um Hashtable Java contendo as configura��es atuais.
        #
        def to_jndi_environment_hashtable
          jndi_env = Hashtable.new
          
          jndi_env.put(
            InitialContext::INITIAL_CONTEXT_FACTORY, @initial_context_factory)
              
          jndi_env.put(
            InitialContext::PROVIDER_URL, @provider_url)
              
          jndi_env.put(
            InitialContext::SECURITY_PRINCIPAL, @security_principal)
              
          jndi_env.put(
            InitialContext::SECURITY_CREDENTIALS, @security_credentials)
          
          jndi_env
        end
        
        #
        # Constroi um contexto JNDI inicial a partir das configura��es atuais.
        #
        def build_jndi_context
            # Carrega a biblioteca cliente do servidor de aplica��es
            require @client_jar_file
            
            InitialContext.new(to_jndi_environment_hashtable)
        end
      end
    
      #
      # Cliente JMS que possibilita a conex�o com o servidor de aplica��es Java EE
      # que prov� o servi�o JMS.
      #
      class Client
        attr_reader :properties
        
        def initialize(&configurator)
          @properties = Properties.new
          
          begin
            configurator.call(@properties)
          
            @jndi_context = properties.build_jndi_context
          rescue => cause
            raise ClientInitializationError.new(@properties, cause)
          end
          
          # Conex�es, filas, t�picos, senders e receivers que ser�o habilitados
          @connection_factories = {}
          @queues               = {}
          @queue_senders        = {}
          @queue_receivers      = {}
          @topics               = {}
          @topic_senders        = {}
          @topic_receivers      = {}
        end

        def enable_connection_factories(jndi_names={})
          jndi_names.each_pair do |key, jndi_name|
            @connection_factories[key] = @jndi_context.lookup(jndi_name)
          end
        end

        def queue_connection_factory
          @connection_factories[:queue_connection_factory]
        end

        def topic_connection_factory
          @connection_factories[:topic_connection_factory]
        end

        def enable_queues(jndi_names={})
          jndi_names.each do |key, jndi_name|
            @queues[key] = @jndi_context.lookup(jndi_name)
          end
        end
        
        def queue_enabled?(queue_name)
          @queues.include?(queue_name)
        end
        
        def queue(queue_name)
          raise NameError, "Queue '#{queue_name}' does not exist." unless queue_enabled?(queue_name)
          
          @queues[queue_name]
        end

        def queue_sender(queue_name)
          @queue_senders[queue_name] ||=
              Messaging::Sender.new(queue_connection_factory, queue(queue_name))
        end

        def queue_receiver(queue_name)
          @queue_receivers[queue_name] ||=
              Messaging::Receiver.new(queue_connection_factory, queue(queue_name))
        end

        def enable_topics(jndi_names={})
          jndi_names.each do |key, jndi_name|
            @topics[key] = @jndi_context.lookup(jndi_name)
          end
        end
        
        def topic_enabled?(topic_name)
          @topics.include?(topic_name)
        end
        
        def topic(topic_name)
          raise NameError, "Topic '#{topic_name}' does not exist." unless topic_enabled?(topic_name)
          
          @topics[topic_name]
        end

        def topic_sender(topic_name)
          @topic_senders[topic_name] ||=
              Messaging::Sender.new(topic_connection_factory, topic(topic_name))
        end

        def topic_receiver(topic_name)
          @topic_receivers[topic_name] ||=
              Messaging::Receiver.new(topic_connection_factory, topic(topic_name))
        end
      end
      
      class ClientInitializationError < StandardError
        attr_reader :properties, :cause
        
        def initialize(properties, cause)
          super("Could not open connection to the server. Verify the properties's properties.")
          
          @properties = properties
          @cause         = cause
        end
      end
    end
  end
end
