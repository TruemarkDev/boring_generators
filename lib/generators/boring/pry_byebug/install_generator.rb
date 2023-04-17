# frozen_string_literal: true

module Boring
  module PryByebug
    class InstallGenerator < Rails::Generators::Base
      desc "Adds pry-byebug gem to the application for step-by-step debugging and stack navigation capabilities to pry using byebug"

      def add_pry_byebug_gem
        say "Adding pry_byebug gem", :green

        gem_content = <<~RUBY
          \tgem "pry-byebug"
        RUBY

        insert_into_file "Gemfile", gem_content, after: /group :development do/

        Bundler.with_unbundled_env do
          run "bundle install"
        end
      end

    end
  end
end