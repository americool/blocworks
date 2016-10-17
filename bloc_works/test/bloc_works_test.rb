require_relative '../lib/bloc_works'
require 'test/unit'
require 'rack/test'

class ApplicationTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    BlocWorks::Application
  end

  def test_call
    get "/"

    assert(last_response.ok?)
    puts "---"
    puts last_response
    puts "---"
    puts last_response.body
  end
end
