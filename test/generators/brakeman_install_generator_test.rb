# frozen_string_literal: true

require 'test_helper'
require 'generators/boring/brakeman/install/install_generator'

class AuditInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Brakeman::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_add_brakeman_gem
    Dir.chdir(app_path) do
      quietly { generator.add_brakeman_gem }

      assert_file "Gemfile" do |content|
        assert_match(/brakeman/, content)
      end
    end
  end

  def test_should_add_all_default_configurations_for_brakeman
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file 'config/brakeman.yml' do |content|
        assert_match(/- reports\/brakeman\.json/, content)
        assert_match(/- reports\/brakeman\.html/, content)
      end

      assert_no_file '.github/workflows/scan.yml'
      assert_no_file '.gitlab-ci.yml'
    end
  end

  def test_should_skip_configurations_for_brakeman
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--skip_config"] }

      assert_no_file '.github/workflows/scan.yml'
      assert_no_file '.gitlab-ci.yml'
      assert_no_file 'config/brakeman.yml'
    end
  end

  def test_should_add_github_actions_configurations_for_brakeman
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--github"] }

      assert_file 'config/brakeman.yml'
      assert_no_file '.gitlab-ci.yml'

      assert_file '.github/workflows/scan.yml' do |content|
        assert_match(/name: Scan/, content)
        assert_match(/- name: Scan for security vulnerabilities/, content)
        assert_match(/run: bundle exec brakeman/, content)
      end
    end
  end

  def test_should_add_gitlab_ci_configurations_for_brakeman
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--gitlab"] }

      assert_file 'config/brakeman.yml'
      assert_no_file '.github/workflows/scan.yml'

      assert_file '.gitlab-ci.yml' do |content|
        assert_match(/stage: scan/, content)
        assert_match(/- bundle exec brakeman/, content)
      end
    end
  end

  def test_should_append_scan_to_existing_stages_in_gitlab_ci
    Dir.chdir(app_path) do
      create_gitlab_ci_file

      run_generator [destination_root, "--gitlab"]

      stages_configuration = <<~RUBY
        stages:
          - scan
      RUBY

      assert_file '.gitlab-ci.yml' do |content|
        assert_match(stages_configuration, content)
        assert_match(/stage: scan/, content)
        assert_match(/- bundle exec brakeman/, content)
      end
    end
  end

  private

  def create_gitlab_ci_file
    `touch #{app_path}/.gitlab-ci.yml`

    stages_configuration = <<~RUBY
      stages:
    RUBY

    `echo "#{stages_configuration}\n" >> #{app_path}/.gitlab-ci.yml`
  end
end
