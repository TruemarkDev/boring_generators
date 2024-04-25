# frozen_string_literal: true

module Boring
  module RackMiniProfiler
    class InstallGenerator < Rails::Generators::Base
      desc 'Adds rack mini profiler to the application'

      def add_rack_mini_profiler_gem
        say 'Adding rack mini profiler gem', :green

        gem_content = <<~RUBY
          \t# Middleware that displays speed badge for every HTML page, along with (optional) flamegraphs and memory profiling.
          \tgem 'rack-mini-profiler', require: false
        RUBY

        insert_into_file "Gemfile", gem_content, after: /group :development do/

        Bundler.with_unbundled_env do
          run "bundle install"
        end
      end

      def configure_rack_mini_profiler
        say 'Configuring rack mini profiler', :green

        Bundler.with_unbundled_env do
          run 'bundle exec rails g rack_mini_profiler:install'
        end
      end
    end
  end
end