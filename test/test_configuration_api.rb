require 'test_helper'

class TestConfigurationApi < MiniTest::Unit::TestCase

  def test_it_should_return_a_configuration_object
    assert Rack::Thumb::Proxy.configuration.is_a?(Rack::Thumb::Proxy::Configuration)
  end

  def test_default_options
    Rack::Thumb::Proxy.configuration.reset_defaults!
    default_configuration = Rack::Thumb::Proxy.configuration
    assert_equal nil, default_configuration.secret
    assert_equal 10, default_configuration.key_length
    assert_equal '/', default_configuration.mount_point
    assert_equal({'Cache-Control' => 'max-age=86400, public, must-revalidate'}, default_configuration.cache_control_headers)
  end

  def test_it_should_take_a_block_which_is_class_evaluated_keeping_all_options
    Rack::Thumb::Proxy.configuration.reset_defaults!
    configuration = Rack::Thumb::Proxy.configure do
      secret      '123'
      key_length  10
      mount_point '/'
    end
    assert_equal '123', configuration.secret
  end

  def test_setting_option_labels_via_the_configuration_api
    Rack::Thumb::Proxy.configuration.reset_defaults!
    configuration = Rack::Thumb::Proxy.configure do
      option_label :thumbnail, '50x75c'
    end
    assert configuration.option_labels.has_key?(:thumbnail)
  end

  def test_hash_signatures_are_correctly_enabled_and_disabled_based_on_the_presense_of_the_secret
    Rack::Thumb::Proxy.configuration.reset_defaults!
    configuration = Rack::Thumb::Proxy.configuration
    refute configuration.secret
    refute configuration.hash_signatures_in_use?
    configuration.secret('something truthy')
    assert configuration.secret
    assert configuration.hash_signatures_in_use?
  end

end
