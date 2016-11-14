require "erubis"

module BlocWorks
  class Controller
    def initialize(env)
      @env = env
      @routing_params = {}
      # @request_data = Rack::Request.new(env) #removed to deal with instruction from checkpoint
    end

    def dispatch(action, routing_params = {})
      @routing_params = BlocWorks::convert_keys(routing_params)
      text = self.send(action)
      if has_response?
        rack_response = get_response
        [rack_response.status, rack_response.header, [rack_response.body].flatten]
      else
        [200, {'Content-Type' => 'text/html'}, [text].flatten]
      end
    end

    def self.action(action, response = {})
      proc { |env| self.new(env).dispatch(action, BlocWorks::convert_keys(response)) }
    end

    def request
      @request ||= Rack::Request.new(@env)
    end

    def params
      request.params.merge(@routing_params) #altered to match new instructions from checkpoint
    end

    def response(text, status = 200, headers = {})
      raise "Cannot respond multiple times" unless @response.nil?
      @response = Rack::Response.new([text].flatten, status, BlocWorks::convert_keys(headers))
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
        arg = BlocWorks::convert_keys(arg)
        controller_name = arg.delete('controller') || params["controller"]
        action_name = arg.delete('action') || params["action"]

        action_params = params.merge(arg);
        action_params['controller'] = controller_name
        action_params['action'] = action_name

        controller_name = controller_name.capitalize

        controller_class = Object.const_get("#{controller_name}Controller")
        proc_response = controller_class.action(action_name, action_params).call(@env)

        response(proc_response[2], proc_response[0], proc_response[1])
      end
    end

    def get_response
      @response
    end

    def has_response?
      !@response.nil?
    end

    def create_response_array(*args)
      if args[0].is_a?(Hash)
        view = params["action"]
        locals = args[0] || {}
      else
        view = args[0]
        locals = args[1] || {}
      end

      filename = File.join("app", "views", controller_dir, "#{view}.html.erb")
      template = File.read(filename)
      locals = BlocWorks::convert_keys(locals)

      eruby = Erubis::Eruby.new(template)

      self.instance_variables.each do |name|
        key = name.to_s[1..-1]
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
