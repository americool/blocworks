module BlocWorks
  class Application
    def controller_and_action(env)
      _, controller, action, _ = env["PATH_INFO"].split("/", 4)
      controller = controller.capitalize
      controller = "#{controller}Controller"

      controllerClass = Object.const_get(controller)
      controller = controllerClass.new(env)

      [200, {'Content-Type' => 'text/html'}, [controller.send(action)]]

      #[404, {'Content-Type' => 'text/html'}, []]
      #[Object.const_get(controller), action]
    end

    def fav_icon(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end
    end
  end
end
