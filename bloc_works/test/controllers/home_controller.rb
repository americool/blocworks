class HomeController < BlocWorks::Controller
  def test_welcome
    [200, {'Content-Type' => 'text/html'}, ["HEY IT WORKED"]]
  end
end 
