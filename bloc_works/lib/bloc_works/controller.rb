require "erubis"

module BlocWorks
  class Controller
    def initialize(env)
      @env = env
      @routing_params = {}
      # @request_data = Rack::Request.new(env) #removed to deal with instruction from checkpoint
    end

    def dispatch(action, routing_params = {})
      @routing_params = routing_params
      text = self.send(action)
      if has_response?
        rack_response = get_response
        [rack_response.status, rack_response.header, [rack_response.body].flatten]
      else
        [200, {'Content-Type' => 'text/html'}, [text].flatten]
      end
    end

    def self.action(action, response = {})
      proc { |env| self.new(env).dispatch(action, response) }
    end

    def request
      @request ||=Rack::Request.new(@env)
    end

    def params
      request.params.merge(@routing_params) #altered to match new instructions from checkpoint
    end

    def response(text, status = 200, headers = {})
      raise "Cannot respond multiple times" unless @response.nil?
      @response = Rack::Response.new([text].flatten, status, headers)
    end

    def render(*args)
      response(create_response_array(*args))
    end

    def redirect(arg)
      if arg.is_a?(String)
        headers = Hash.new

        headers['Location'] = arg

        response("", 302, headers)
      else
        controllerName = arg.delete('controller') || params["controller"]
        if controllerName.nil?
          puts "No controller"
        else
          puts "This thing:" + controllerName.capitalize
        end
        controllerName = controllerName.capitalize
        actionName = arg.delete('action') || params["action"]

        controllerClass = Object.const_get("#{controllerName}Controller")
        proc_response = controllerClass.action(actionName, arg)
        proc_response.call(@env)
      end
    end

    def get_response
      @response
    end

    def has_response?
      !@response.nil?
    end

    def create_response_array(view, locals = {})
      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
      template = File.read(filename)

      eruby = Erubis::Eruby.new(template)

      self.instance_variables.each do |name|
        key = name.to_s[1..-1]
        # puts key
        value = instance_variable_get(name.to_s)

        locals[key] = value
      end

      eruby.result(locals)
    end

    def controller_dir
      klass = self.class.to_s
      klass.slice!("Controller")
      BlocWorks.snake_case(klass)
    end
  end
end
