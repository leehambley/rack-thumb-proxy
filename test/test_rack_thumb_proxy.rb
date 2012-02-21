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
    stub_image_request!('250x.gif', 'http://www.example.com/images/kittens.gif')

    get "/" + escape("http://www.example.com/images/kittens.gif")
    assert last_response.ok?
    assert_equal file_size_for_fixture('250x.gif'), last_response.headers.fetch('Content-Length')
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

    def filename_for_fixture(file)
      File.expand_path('test/fixtures/' + file)
    end

end
