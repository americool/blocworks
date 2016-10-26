require "bloc_works/version"
require "bloc_works/dependencies"
require "bloc_works/controller"
require "bloc_works/router"
require "bloc_works/utility"

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
