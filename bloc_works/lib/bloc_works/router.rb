module BlocWorks
  class Application
    attr_reader :router

    def controller_and_action(env)
      _, controller, action, _ = env["PATH_INFO"].split("/", 4)
      controller = controller.capitalize
      controller = "#{controller}Controller"

      controllerClass = Object.const_get(controller)
      controller = controllerClass.new(env)

      if controller.has_response?
         status, header, response = controller.get_response
         [status, header, [response.body].flatten]
      else
         [200, {'Content-Type' => 'text/html'}, [text]]
      end

      #[404, {'Content-Type' => 'text/html'}, []]
      #[Object.const_get(controller), action]
    end

    def fav_icon(env)
      if env['PATH_INFO'] == '/favicon.ico'
        return [404, {'Content-Type' => 'text/html'}, []]
      end
    end

    def route (&block)
      @router ||= Router.new
      @router.instance_eval(&block)
    end

    def get_rack_app(env)
      if @router.nil?
        raise "No routes defined"
      end
      link = env["PATH_INFO"]
      if link.length > 1 && link[-1] == "/"
        link.chop!
      end
      method = env["REQUEST_METHOD"]
      @router.look_up_url(method, link)
    end
  end

  class Router
    attr_reader :rules

    def initialize
      @rules = []
    end

    def url_parser(parts)
      vars, regex_parts = [], []

      parts.each do |part|
        case part[0]
        when ":"
          vars << part[1..-1]
          regex_parts << "([a-zA-Z0-9]+)"
        when "*"
          vars << part[1..-1]
          regex_parts << "(.*)"
        else
          regex_parts << part
        end
      end
      regex = regex_parts.join("/")
      maping_tool = {regex: Regexp.new("^/#{regex}$"), vars: vars}
    end

    def resources(resource)
      map "#{resource}", default: {"controller" => resource, "action" => "index"}, method: "GET"
      map "#{resource}/new", default: {"controller" => resource, "action" => "new"}, method: "GET"
      map "#{resource}", default: {"controller" => resource, "action" => "create"}, method: "POST"
      map "#{resource}/:id", default: {"controller" => resource, "action" => "show"}, method: "GET"
      map "#{resource}/:id/edit", default: {"controller" => resource, "action" => "edit"}, method: "GET"
      map "#{resource}/:id", default: {"controller" => resource, "action" => "update"}, method: "PUT"
      map "#{resource}/:id", default: {"controller" => resource, "action" => "destroy"}, method: "DELETE"
    end

    def map(url, *args)
      raise "Too many args!" if args.size > 2

      options = {}
      options = args.pop if args[-1].is_a?(Hash)
      options[:default] ||= {}

      destination = nil
      destination = args.pop if args.size > 0

      parts = url.split("/")
      parts.reject! {|part| part.empty?}

      maping_tool = url_parser(parts)

      maping_tool.merge!({destination: destination, options: options})
      @rules.push(maping_tool)
    end

    def get_rule_params(rule, rule_match)
      options = rule[:options]
      params = options[:default].dup

      rule[:vars].each_with_index do |var, index|
        params[var] = rule_match.captures[index]
      end
      params
    end

    def look_up_url(method, url)
      @rules.each do |rule|
        rule_match = rule[:regex].match(url)
        method_match = rule[:options][:method] == method

        if rule_match && method_match
          params = get_rule_params(rule, rule_match)
          destination = rule[:destination]

          if destination.nil?
            controller = params["controller"]
            action = params["action"]
            destination = "#{controller}##{action}"
          end

          return get_destination(destination, params)
        end
      end
    end

    def get_destination(destination, routing_params = {})
      if destination.respond_to?(:call)
        return destination
      elsif destination =~ /^([^#]+)#([^#]+)$/
        name = $1.capitalize
        controllerClass = Object.const_get("#{name}Controller")
        return controllerClass.action($2, routing_params)
      end
      raise "Destination not found: #{destination}"
    end
  end
end
