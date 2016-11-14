require './config/application'
# run BlocBooks::Application.new
app = BlocWorks::Application.new

use Rack::ContentType

app.route do
  map "", default: {"controller" => "books", "action" => "welcome" }, method: "GET"
  # map ":controller/:id/:action", method: "GET"
  # map ":controller/:id", default: {"action" => "show"}, method: "GET"
  # map ":controller", default: {"action" => "index"}, method: "GET"
  resources :books
  map "/books/:id/amazon", default: {"controller" => "books", "action" => "amazon" }, method: "GET"
  map "/books/:id/display", default: {"controller" => "books", "action" => "display" }, method: "GET"
end

run(app)
