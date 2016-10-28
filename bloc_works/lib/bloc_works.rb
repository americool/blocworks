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
         response = self.controller_and_action(env)
       end

       response
     end
   end
end
