# frozen_string_literal: true

module Boring
  module RestClient
    class InstallGenerator < Rails::Generators::Base
      desc 'Add RestClient to your Rails app'

      def add_rest_client_gem
        say 'Adding RestClient gem', :green
        
        gem 'rest-client'
      end
    end
  end
end