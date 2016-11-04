require_relative "bloc_works/version"
require_relative "bloc_works/dependencies"
require_relative "bloc_works/controller"
require_relative "bloc_works/router"
require_relative "bloc_works/utility"

module BlocWorks
  class Application
     def call(env)
       response = self.fav_icon(env)

       if response.nil?
         rack_app = get_rack_app(env)
        #  puts "\n\n0000000\n"
        #  puts rack_app
         response = rack_app.call(env)
       end

       response
     end
   end
end
