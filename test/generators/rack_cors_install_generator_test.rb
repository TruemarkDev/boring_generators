# frozen_string_literal: true

require 'test_helper'
require 'generators/boring/rack_cors/install/install_generator'

class RackCorsInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::RackCors::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper
  include ActiveSupport::Testing::Isolation

  def destination_root
    app_path
  end

  def test_should_configure_rack_cors
    Dir.chdir(app_path) do
      quietly { run_generator }

      assert_gem 'rack-cors'

      assert_file 'config/initializers/cors.rb' do |content|
        assert_match(/Rails.application.config.middleware.insert_before 0, Rack::Cors do/, content)
        assert_match(/origins '*'/, content)
      end
    end
  end

  def test_should_configure_custom_origins
    Dir.chdir(app_path) do
      quietly { run_generator %w[--origins=localhost:3000 example.com] }

      assert_file 'config/initializers/cors.rb' do |content|
        assert_match(/Rails.application.config.middleware.insert_before 0, Rack::Cors do/, content)
        assert_match(/origins 'localhost:3000', 'example.com'/, content)
      end
    end
  end
end
