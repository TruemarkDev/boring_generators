# frozen_string_literal: true

require 'test_helper'
require 'generators/boring/rest_client/install/install_generator'

class RestClientInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::RestClient::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_rest_client_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem 'rest-client'
    end
  end
end