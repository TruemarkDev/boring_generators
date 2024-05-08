# frozen_string_literal: true

module Boring
  module RackCors
    class InstallGenerator < Rails::Generators::Base
      desc 'Adds rack-cors gem to the app'
      source_root File.expand_path("templates", __dir__)

      class_option :origins, type: :string, default: '*',
                   desc: 'Specify which origins are allowed to make CORS requests'

      def add_rack_cors_gem
        say 'Adding Rack CORS gem', :green

        gem 'rack-cors'
      end

      def configure_rack_cors
        say 'Configuring Rack CORS', :green

        @origins = options[:origins].split(' ').map { |origin| "'#{origin.strip}'" }.join(', ')

        template 'cors.rb', 'config/initializers/cors.rb'

        show_alert_message
      end

      private

      def show_alert_message
        say "❗️❗️\nPlease restart your rails server for the changes to take effect.\n", :yellow
      end
    end
  end
end
