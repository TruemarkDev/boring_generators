# frozen_string_literal: true

module Boring
  module Brakeman
    class InstallGenerator < Rails::Generators::Base
      desc 'Adds Brakeman to the application'
      source_root File.expand_path('templates', __dir__)

      RUBY_VERSION_FILE = '.ruby-version'

      class_option :skip_config, type: :boolean, aliases: '-c',
                                 desc: 'Skip adding Brakeman configuration. Defaults to false'
      class_option :ci, type: :string, aliases: '-ci',
                        enum: %w[gitlab github none],
                        default: 'none',
                        desc: 'Tell us which git repository to configure.'
      class_option :ruby_version, type: :string, aliases: '-v',
                                  desc: "Tell us the ruby version which you use for the application. Defaults to the ruby version in your app's Gemfile"

      def add_brakeman_gem
        say 'Adding Brakeman gem', :green

        gem 'brakeman', group: :development
      end

      def configure_brakeman
        return if options[:skip_config]

        say 'Setting up Brakeman', :green

        template 'brakeman.yml', 'config/brakeman.yml'
      end

      def configure_git_repository_ci
        if options[:ci] == 'github'
          configure_github_actions_for_brakeman
        elsif options[:ci] == 'gitlab'
          configure_gitlab_ci_for_brakeman
        end
      end

      private

      def configure_github_actions_for_brakeman
        @ruby_version = options[:ruby_version]

        say 'Adding Brakeman configurations to .github/workflows/brakeman.yml', :green

        template 'github/brakeman.yml', '.github/workflows/brakeman.yml'
      end

      def configure_gitlab_ci_for_brakeman
        @ruby_version = options[:ruby_version]

        say 'Adding Brakeman configurations to .gitlab-ci.yml', :green

        ci_file_content = <<~RUBY
          scan:
            stage: scan
            image: ruby:#{@ruby_version}
            script:
              - gem install bundler -v "$(grep -A 1 "BUNDLED WITH" Gemfile.lock | tail -n 1)" --no-document
              - bundle install --jobs $(nproc)
              - bundle exec brakeman
        RUBY

        stages_configuration = <<~RUBY
          stages:
            - brakeman
        RUBY

        if File.exist?('.gitlab-ci.yml')
          gitlab_ci_file = YAML.safe_load(File.open('.gitlab-ci.yml'), aliases: true) || {}

          if gitlab_ci_file['stages']
            if gitlab_ci_file.include?('brakeman')
              say 'Configuration for brakeman already exists in .gitlab-ci.yml', :yellow

              return
            else
              inject_into_file '.gitlab-ci.yml', optimize_indentation("\n- scan", 2).chomp, after: /stages:/
            end
          else
            prepend_to_file '.gitlab-ci.yml', "#{stages_configuration}\n"
          end

          append_to_file '.gitlab-ci.yml', ci_file_content
        else

          create_file '.gitlab-ci.yml', "#{stages_configuration}\n#{ci_file_content}"
        end
      end
    end
  end
end
