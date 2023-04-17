# frozen_string_literal: true

require "test_helper"
require "generators/boring/letter_opener/install/install_generator"

class AuditInstallGeneratorTest < Rails::Generators::TestCase
  tests Boring::PryByebug::InstallGenerator
  setup :build_app
  teardown :teardown_app

  include GeneratorHelper

  def test_should_install_pry_byebug_gem
    Dir.chdir(app_path) do
      quietly { generator.add_pry_byebug_gem }

      assert_file "Gemfile" do |content|
        assert_match(/pry-byebug/, content)
      end
    end
  end

end