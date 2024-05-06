# frozen_string_literal: true

require "test_helper"
require "generators/boring/ci/gitlab_ci/install/install_generator"

class GitlabCiInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Ci::GitlabCi::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def destination_root
    app_path
  end

  def test_should_add_configurations_for_gitlab_ci
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_file('.gitlab-ci.yml') do |content|
        assert_match(/image: \$BASE_DOCKER_IMAGE/, content)
        assert_match(/bundle exec test/, content)
      end
      assert_file('config/database.yml.ci')
    end
  end

  def test_should_configure_test_stage_for_rspec
    Dir.chdir(app_path) do
      quietly { run_generator [destination_root, "--test_framework=rspec"]}

      assert_file('.gitlab-ci.yml') do |content|
        assert_match(/bundle exec rspec/, content)
      end
      assert_file('config/database.yml.ci')
    end
  end
end
