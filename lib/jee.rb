# Defini��o do diret�rios onde est�o as libs
JEE_LIB_DIR = File.expand_path(File.dirname(__FILE__)) + '/jee'

# Antes de qualquer outra, a fundamental
require 'java'

# Biblioteca essencial de integra��o com JMS
require "#{JEE_LIB_DIR}/sparrow-essential.jar"

#  Biblioteca Java EE principal
require "#{JEE_LIB_DIR}/javaee-1.5.jar"

# Biblioteca da API JMS
require "#{JEE_LIB_DIR}/jms.jar"