require 'minitest/autorun'
require 'minitest/reporters'
require 'mocha/minitest'

# Configuración de formato de salida para tests
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(color: true)]

# Permitir que requiramos archivos desde la raíz del proyecto
$LOAD_PATH.unshift File.expand_path('../', __dir__) 