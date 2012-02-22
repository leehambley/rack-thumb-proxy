require 'test_helper'

class TestRackThumbProxy < MiniTest::Unit::TestCase

  include Rack::Test::Methods

  def app
    Rack::Thumb::Proxy
  end

  def test_it_should_repond_with_not_found_when_the_upstream_url_is_bunk
    get "/something/that/doesnt/even/match/a/little/bit"
    assert last_response.not_found?
  end

  def test_it_should_return_success_with_the_correct_content_length_when_a_matching_url_is_found_for_a_noop_image
    stub_image_request!('250x.gif', 'http://www.example.com/images/noop-kittens.gif')
    get '/' + escape('http://www.example.com/images/noop-kittens.gif')
    assert last_response.ok?
    assert_equal file_size_for_fixture('250x.gif').to_s, last_response.headers.fetch('Content-Length')
    assert_equal file_hash_for_fixture('250x.gif'), file_hash_from_string(last_response.body)
    assert_dimensions last_response.body, 250, 250
  end

  def test_it_should_return_a_smaller_image_when_resizing_with_minimagick
    stub_image_request!('250x.gif', 'http://www.example.com/images/kittens.gif')
    get '/50x50/' + escape('http://www.example.com/images/kittens.gif')
    assert last_response.ok?
    assert_dimensions last_response.body, 50, 50
  end

  def test_it_should_crop_when_the_ratio_cannot_be_maintained
    stub_image_request!('200x100.gif', 'http://www.example.com/images/sharkjumping.gif')
    get '/50x50/' + escape('http://www.example.com/images/sharkjumping.gif')
    assert last_response.ok?
    assert_dimensions last_response.body, 50, 50
  end

  def test_it_should_retain_the_aspec_ratio
    stub_image_request!('200x100.gif', 'http://www.example.com/images/sharkjumping.gif')
    get '/50x/' + escape('http://www.example.com/images/sharkjumping.gif')
    assert last_response.ok?
    assert_dimensions last_response.body, 50, 25
  end

  def test_it_should_accept_the_gravity_setting_without_breaking_the_resize
    stub_image_request!('200x100.gif', 'http://www.example.com/images/sharkjumping.gif')
    get '/50x50e/' + escape('http://www.example.com/images/sharkjumping.gif')
    assert last_response.ok?
    east = last_response.body
    get '/50x50w/' + escape('http://www.example.com/images/sharkjumping.gif')
    assert last_response.ok?
    west = last_response.body
    refute_equal file_hash_from_string(east), file_hash_from_string(west)
  end

  def test_default_gravity_is_center_when_cropping
    stub_image_request!('200x100.gif', 'http://www.example.com/images/sharkjumping.gif')
    get '/75x75/' + escape('http://www.example.com/images/sharkjumping.gif')
    no_gravity = last_response.body
    get '/75x75c/' + escape('http://www.example.com/images/sharkjumping.gif')
    c_gravity = last_response.body
    assert_equal file_hash_from_string(no_gravity), file_hash_from_string(c_gravity)
  end

  def test_should_respond_with_the_proper_mimetype_for_known_image_types
    skip
  end

  def test_should_respond_with_application_octet_stream_mimetype_for_unknown
    skip
  end

  private

    def stub_image_request!(file, url)
      stub_request(:any, url).to_return(
        body: File.read(filename_for_fixture(file)),
        headers: {
          'Content-Length' => file_size_for_fixture(file)
        },
        status: 200
      )
    end

    def escape(string)
      CGI.escape(string)
    end

    def file_size_for_fixture(file)
      File.size(filename_for_fixture(file))
    end

    def file_hash_from_string(string)
      Digest::MD5.hexdigest(string)
    end

    def file_hash_for_fixture(file)
      file_hash_from_string(File.read(filename_for_fixture(file)))
    end

    def filename_for_fixture(file)
      File.expand_path('test/fixtures/' + file)
    end

    def fixture_file_exists?(file)
      File.exists?(file) rescue false
    end

    def assert_dimensions(input, expected_width, expected_height)
      unless fixture_file_exists?(input)
        tf = Tempfile.new('assert_dimensions')
        tf.write input
        tf.flush
        tf.rewind
        input = tf.path
      end
      actual_width, actual_height = Dimensions.dimensions(input)
      assert_equal "#{expected_width}x#{expected_height}", "#{actual_width}x#{actual_height}"
      ensure
        tf.close if tf rescue nil
    end

end
