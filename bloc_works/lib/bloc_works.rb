require_relative "bloc_works/version"
require "bloc_works/dependencies"
require "bloc_works/controller"

module BlocWorks
  class Application
     def self.call(env)
       [200, {'Content-Type' => 'text/html'}, ["Hello Blocheads!"]]
     end
   end
end
