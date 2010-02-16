# Classes Java usadas nesse arquivo
import 'java.util.Hashtable'
import 'javax.naming.InitialContext'

module Sparrow
  module Connection

    #
    # Metodo usado para configurar a conexao com o middleware de JMS.
    #
    def self.configure
      @@properties = ConnectionProperties.new
      
      yield @@properties
    end
    
    #
    # Metodo usado para obter a configuracao para conexao com o middleware de JMS.
    #
    def self.connection_properties
      @@properties
    end
    
    #
    # Metodo usado para criar um novo Client JMS.
    #
    def self.new_client
      jndi_context_builder = JNDI::ContextBuilder.new(@@properties.jms_client_jar, @@properties.jndi_properties)
      
      Client.new(@@properties, jndi_context_builder)
    end

    #
    # Configuracoes necessarias para que clientes JMS se conetem
    # ao middleware de mensageria via contexto JNDI.
    #
    class ConnectionProperties
      attr_reader :jms_client_jar, :jndi_properties,
                  :enabled_connection_factories, :enabled_queues, :enabled_topics
      
      def use_jms_client_jar(client_jar)
        @jms_client_jar = client_jar
      end
      
      def use_jndi_properties(jndi_properties = {})
        @jndi_properties = jndi_properties
      end
      
      def enable_connection_factories(jndi_names = {})
        @enabled_connection_factories = jndi_names
      end
      
      def enable_queues(jndi_names = {})
        @enabled_queues = jndi_names
      end
      
      def enable_topics(jndi_names = {})
        @enabled_topics = jndi_names
      end
    end

    #
    # Cliente JMS que possibilita a conexao com o servidor de aplicacoes Java EE
    # que prove o servico JMS.
    #
    class Client
      def initialize(connection_properties, jndi_context_builder)
        @connection_properties = connection_properties
        @jndi_context_builder  = jndi_context_builder
        
        @jndi_name_of_enabled_connection_factories = @connection_properties.enabled_connection_factories
        @jndi_name_of_enabled_queues               = {}
        @jndi_name_of_enabled_topics               = {}

        # Conexoes, filas, topicos, senders e receivers que serao habilitados
        @connection_factories               = {}
        @queues                             = {}
        @queue_senders                      = {}
        @queue_receivers                    = {}
        @topics                             = {}
        @topic_senders                      = {}
        @topic_receivers                    = {}

        # Foi startado?
        @started = false
      end
      
      def is_started?
        @started
      end
      
      def start
        raise InvalidClientStateError.new('started', 'start') if is_started?
        
        begin
          @jndi_context = @jndi_context_builder.build
        rescue => cause
          raise ClientInitializationError.new(@connection_properties, cause)
        end
        
        @connection_factories = lookup_resource(@jndi_name_of_enabled_connection_factories)
        @queues               = lookup_resource(@jndi_name_of_enabled_queues)
        @topics               = lookup_resource(@jndi_name_of_enabled_topics)
        
        @started = true
      end
      
      def is_stoped?
        !@started
      end
      
      def stop
        raise InvalidClientStateError.new('stoped', 'stop') if is_stoped?
        
        @jndi_context.close
        
        @started = false  
      end

      def queue_connection_factory_enabled?
        @jndi_name_of_enabled_connection_factories.include?(:queue_connection_factory)
      end

      def queue_connection_factory
        @connection_factories[:queue_connection_factory]
      end

      def topic_connection_factory_enabled?
        @jndi_name_of_enabled_connection_factories.include?(:topic_connection_factory)
      end

      def topic_connection_factory
        @connection_factories[:topic_connection_factory]
      end

      def enable_queues(jndi_names = {})
        raise InvalidClientStateError.new('started', 'enable_queues') if is_started?
        
        @jndi_name_of_enabled_queues = jndi_names
      end
      
      def queue_enabled?(queue_name)
        @jndi_name_of_enabled_queues.include?(queue_name)
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

      def enable_topics(jndi_names = {})
        raise InvalidClientStateError.new('started', 'enable_topics') if is_started?
        
        @jndi_name_of_enabled_topics = jndi_names
      end
      
      def topic_enabled?(topic_name)
        @jndi_name_of_enabled_topics.include?(topic_name)
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
      
      # -- Private methods -- #
      private
      
        def lookup_resource(jndi_names = {})
          lookuped = {}
          
          jndi_names.each do |key, jndi_name|
            lookuped[key] = @jndi_context.lookup(jndi_name)
          end
          
          lookuped
        end
    end
    
    class ClientInitializationError < StandardError
      attr_reader :properties, :cause
      
      def initialize(properties, cause)
        super("Could not open connection to server. Verify the properties's properties.")
        
        @properties = properties
        @cause      = cause
      end
    end

    class InvalidClientStateError < StandardError
      attr_reader :state, :operation
      
      def initialize(state, operation)
        super("Could not did #{operation} because client is #{state}.")
        
        @state     = state
        @operation = operation
      end
    end
  end
  
  module JNDI
    
    #
    # Builder para construcao de contexto JNDI para conexao com o middleware
    # de JMS.
    #
    class ContextBuilder
      attr_accessor :jms_client_jar, :jndi_properties
      
      def initialize(jms_client_jar, jndi_properties)
        @jms_client_jar = jms_client_jar
        @jndi_properties   = jndi_properties
      end
      
      #
      # Constroi um contexto JNDI inicial a partir das configuracoes atuais.
      #
      def build
          # Carrega a biblioteca cliente do servidor de aplicacoes
          require @jms_client_jar
          
          InitialContext.new(to_jndi_environment_hashtable)
      end

      # --- Private methods --- #
      private

        #
        # Cria um Hashtable Java contendo as configuracoes atuais.
        #
        def to_jndi_environment_hashtable
          jndi_env = Hashtable.new
        
          jndi_env.put(
            InitialContext::INITIAL_CONTEXT_FACTORY,
            @jndi_properties[:initial_context_factory])
            
          jndi_env.put(
            InitialContext::PROVIDER_URL,
            @jndi_properties[:provider_url])
            
          jndi_env.put(
            InitialContext::SECURITY_PRINCIPAL,
            @jndi_properties[:security_principal]) if @jndi_properties[:security_principal]
            
          jndi_env.put(
            InitialContext::SECURITY_CREDENTIALS,
            @jndi_properties[:security_credentials]) if @jndi_properties[:security_credentials]
        
          jndi_env
        end
    end
  end
end
