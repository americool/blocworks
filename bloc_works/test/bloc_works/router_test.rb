require_relative '../../lib/bloc_works'
require 'test/unit'
require 'rack/test'

$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "controllers")

class RouterTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    BlocWorks::Application
  end

  def test_controller_and_action
    get "/home/test_welcome"

    assert(last_response.ok?)
    puts "---"
    puts last_response
    puts "---"
    puts last_response.body
  end
end
