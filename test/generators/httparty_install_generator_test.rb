# frozen_string_literal: true

require 'test_helper'
require 'generators/boring/httparty/install/install_generator'

class HttpartyInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::Httparty::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_install_httparty_successfully
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem 'httparty'
    end
  end
end