require "erubis"

module BlocWorks
  class Controller
    def initialize(env)
      @env = env
      @request_data = Rack::Request.new(env)
    end

    def params
      @request_data.params
    end

    def render(view, locals = {})
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
