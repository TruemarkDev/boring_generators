# frozen_string_literal: true

require 'boring_generators/generator_helper'

module Boring
  module Ci
    module GitlabCi
      class InstallGenerator < Rails::Generators::Base
        desc 'Adds Gitlab CI to the application'
        source_root File.expand_path("templates", __dir__)

        class_option :ruby_version, aliases: '-rv', type: :string
        class_option :test_framework, aliases: '-tf', type: :string, default: 'minitest',
                      desc: "Tell us the test framework you use for the application. Defaults to Minitest."

        include BoringGenerators::GeneratorHelper

        def add_gitlab_ci_configuration
          @ruby_version = options[:ruby_version] || app_ruby_version
          @run_test_command = test_framework

          template('ci.yml', '.gitlab-ci.yml')
          template('database.yml.tt', 'config/database.yml.ci')

          show_readme
        end

        private

        def test_framework
          if options[:test_framework] == 'rspec'
            'bundle exec rspec'
          else
            'bundle exec test'
          end
        end

        def show_readme
          readme "README"
        end
      end
    end
  end
end
