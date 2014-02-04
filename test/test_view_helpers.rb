require 'test_helper'

class TestViewHelpers < MiniTest::Unit::TestCase

  def test_without_any_options_or_special_configuration_the_view_helper_encodes_the_image_url_correctly
    Rack::Thumb::Proxy.configuration.reset_defaults!
    assert_equal "/http%3A%2F%2Fwww.example.com%2F1.png", vh.proxied_image_url("http://www.example.com/1.png")
  end

  def test_without_any_options_with_a_mount_point_configured_the_view_helper_encodes_the_image_url_correctly
    Rack::Thumb::Proxy.configuration.reset_defaults!
    Rack::Thumb::Proxy.configuration.mount_point("/mount/")
    assert_equal "/mount/http%3A%2F%2Fwww.example.com%2F1.png", vh.proxied_image_url("http://www.example.com/1.png")
  end

  def test_with_a_width_option_only_configured_the_view_helper_encodes_the_image_url_correctly
    Rack::Thumb::Proxy.configuration.reset_defaults!
    assert_equal "/50x/http%3A%2F%2Fwww.example.com%2F1.png", vh.proxied_image_url("http://www.example.com/1.png", '50x')
  end

  def test_with_a_height_option_only_configured_the_view_helper_encodes_the_image_url_correctly
    Rack::Thumb::Proxy.configuration.reset_defaults!
    assert_equal "/x50/http%3A%2F%2Fwww.example.com%2F1.png", vh.proxied_image_url("http://www.example.com/1.png", 'x50')
  end

  def test_with_a_width_and_height_option_configured_the_view_helper_encodes_the_image_url_correctly
    Rack::Thumb::Proxy.configuration.reset_defaults!
    assert_equal "/75x50/http%3A%2F%2Fwww.example.com%2F1.png", vh.proxied_image_url("http://www.example.com/1.png", '75x50')
  end

  def test_with_a_width_and_height_option_as_a_hash_configured_the_view_helper_encodes_the_image_url_correctly
    Rack::Thumb::Proxy.configuration.reset_defaults!
    assert_equal "/45x90/http%3A%2F%2Fwww.example.com%2F1.png", vh.proxied_image_url("http://www.example.com/1.png", {:width => 45, :height => 90})
  end

  def test_with_a_width_height_and_gravity_options_as_a_hash_configured_the_view_helper_encodes_the_image_url_correctly
    Rack::Thumb::Proxy.configuration.reset_defaults!
    assert_equal "/45x90s/http%3A%2F%2Fwww.example.com%2F1.png", vh.proxied_image_url("http://www.example.com/1.png", {:width => 45, :height => 90, :gravity => :s})
  end

  private

    def vh
      ViewHelperSurrogate.new
    end

end
