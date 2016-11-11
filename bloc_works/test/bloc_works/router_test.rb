require_relative '../../lib/bloc_works'
require 'test/unit'
require 'rack/test'

$LOAD_PATH << File.join(File.dirname(__FILE__), "..", "controllers")

class RouterTest < Test::Unit::TestCase
  include Rack::Test::Methods


  def app
    @app ||= BlocWorks::Application.new
  end

  # def test_controller_and_action
  #   get "/home/test_welcome"
  #
  #   assert(last_response.ok?)
  #   assert_equal("HEY IT WORKED", last_response.body)
  # end

  def test_fav_icon
    get "/favicon.ico"
    assert(last_response.not_found?)
  end

  def test_map
    app.route {}
    app.router.map("/home/test_welcome", "home#welcome")
    assert_equal([{:regex=>/^\/home\/test_welcome$/, :vars=>[], :destination=>"home#welcome", :options=>{:default=>{}}}], app.router.rules)
  end

  def test_look_up
    app.route {}
    app.router.map("/home/test_welcome", "home#welcome")
    destination = app.router.look_up_url("/home/test_welcome")
    assert(destination.is_a?(Proc))
  end
end
