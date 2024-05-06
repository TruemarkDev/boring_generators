# frozen_string_literal: true

module Boring
  module Ci
    module GitlabCi
      class InstallGenerator < Rails::Generators::Base
        desc 'Adds Gitlab CI to the application'
        source_root File.expand_path("templates", __dir__)

        RUBY_VERSION_FILE = ".ruby-version"
        DEFAULT_RUBY_VERSION = '.ruby-version'

        class_option :ruby_version, aliases: '-v',
                     desc: "Tell us the ruby version which you use for the application. Default to Ruby #{DEFAULT_RUBY_VERSION}, which will cause the action to use the version specified in the #{RUBY_VERSION_FILE} file."

        class_option :test_framework, aliases: '-tf', type: :string,
                      desc: "Tell us the test framework you use for the application. Default to Minitest."

        def add_gitlab_ci_configuration
          @ruby_version = options[:ruby_version] ? options[:ruby_version] : DEFAULT_RUBY_VERSION
          @run_test_command = test_framework

          template('ci.yml', '.gitlab-ci.yml')
          template('database.yml.tt', 'config/database.yml.ci')

          if @ruby_version == DEFAULT_RUBY_VERSION && !ruby_version_file_exists?
            say <<~WARNING, :red
              WARNING: The action was configured to use the ruby version specified in the .ruby-version
              file, but no such file was present. Either create an appropriate .ruby-version file, or
              update .github/workflows/ci.yml to use an explicit ruby version.
            WARNING
          end

          display_alert_message
          display_alert_message_for_pronto
        end

        private

        def ruby_version_file_exists?
          Pathname.new(destination_root).join(RUBY_VERSION_FILE).exist?
        end

        def test_framework
          if options[:test_framework] == 'rspec'
            'bundle exec rspec'
          else
            'bundle exec test'
          end
        end

        def display_alert_message_for_pronto
          say "❗️❗️\nPlease add your Gitlab personal access token under the variable `PRONTO_ACCESS_TOKEN` in project variables in order to configure linting in the project.\n", :yellow
        end

        def display_alert_message
          say "❗️❗️\nPlease add variables `RUN_TEST` and `RUN_LINT` in your CI/CD variables in order to run the lint and test stages as required and also make sure to add the environment variables under `env` variable in CI/CD.\n", :yellow
        end
      end
    end
  end
end
