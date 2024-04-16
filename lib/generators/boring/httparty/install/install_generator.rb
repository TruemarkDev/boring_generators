# frozen_string_literal: true

module Boring
  module Httparty
    class InstallGenerator < Rails::Generators::Base

      def add_httparty_gem
        say 'Adding httparty gem', :green
        
        gem 'httparty'
      end
    end
  end
end
