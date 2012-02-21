# Rack::Thumb::Proxy

Resize remotely hosted images not hosted on your servers dynamically.
Safely proxy request

`Rack::Thumb::Proxy` is a project in the spirit of `Rack::Thumb`, but
for use in situations when one doesn't host the images statically on
one's own server, consider such an example:

    <img src="http://a-site-which-doesnt-run-ssl.com/the/product/image.png" />

One could download, resize, host and be responsible for this image, but
in the days of realtime systems, massive data, clustered storage,
etcetera, why bother? One could hot-link the image, but then this
doesn't work for cross-protocol, with https in the mix.

    <img src="/media/thumbs/http%3A%2F%2Fa-site-which-doesnt-run-ssl.com%2Fthe%2Fproduct%2Fimage.png" />

Where, in this case one has predefined `thumbs` as a category. One could
also do something such as:

    <img src="/media/50x50/http%3A%2F%2Fa-site-which-doesnt-run-ssl.com%2Fthe%2Fproduct%2Fimage.png" />

or even

    <img src="/media/50x50/http%3A%2F%2Fa-site-which-doesnt-run-ssl.com%2Fthe%2Fproduct%2Fimage.png" />

When combined with a CDN or Rack::Cache, this shouldn't cause too heavy
a performance penalty, and images from upstream will even be cached
locally.

## Safety

To ensure that someone doesn't decide to use your server resources to resize
their entire collection of cat pictures, there's a hash mechanism which
is also available. This works very much like `Rack::Thumb`.

To use this feature, simply configure `Rack::Thumb::Proxy` with a
`secret`, and a `key_length` (the latter may be ommitted and defaults
to 10), urls will be then generated with the following appearance:

    <img src="/media/15a5683b74/50x50/http%3A%2F%2Fa-site-which-doesnt-run-ssl.com%2Fthe%2Fproduct%2Fimage.png" />

The key is calculated as a result of the following pattern:

    "%s\t%s\t%s" % <secret>, <options>, <url encoded image source>

For example with a terrible secret of `secret`:

    echo "secret\t50x50\thttp%3A%2F%2Fa-site-which-doesnt-run-ssl.com%2Fthe%2Fproduct%2Fimage.png" | openssl dgst -sha1

The resulting SHA is as you see above. it is recommended that you choose
a secret using a token generation tool, if you are using Rails, you have
one baked-in simply use `rake secret` from your Rails project root.

Requests which do not match the expected format will receive a `400 Bad
Request` response.

## (Rails) Helpers

A helper module is provided which can be used in Rails, Sinatra, or your
unit tests. This is loaded automatically via a Railtie into Rails,
available from all views. The following methods are defined:

    proxied_image_url("image url", options)
    proxied_image_tag("image url", options)

Somewhat of a private API are the following, which you may find useful:

    signature_hash_for("image url", options)

The image url passed here should not be URL encoded, as
`Rack::Thumb::Proxy` will encode it correctly for you.

## `options`

    "50x"                  `[String]`Constrain to 50 pixels height, maintaining
                           original aspect ratio

    "x100"                 `[String]`Constrain to 100 pixels width, maintaining
                           original aspect ratio

    "50x75n"               `[String]` Constrain to 50 pixels height, distorting the
                           image to acheive a 75 pixels width with *northern* gravity
                           (see below)

    "50x75"                `[String]` Crop to 50 pixels height, without distorting the
                           image to acheive a 75 pixels width

    :label                 `[Symbol]` Take the options specified in 
                           the label (see below)

    {width: 123, height: } `[Hash]` The keys `width`, `height`, and
                           `gravity` are accepted

## Option Labels

One can use the configuration API as such to name a label:

    Rack::Thumb::Proxy.configure do
      option_label :product_thumbnail, "100x100"
    end

## Gravity

Gravity can be specified which will pull the crop (in the case that both
width, and height are given), it will focus the cropped area of the
image, valid options are `n`, `ne`, `e`, `se`, `s`, `sw`, `w`, `nw`. The
default gracity is `c`, which will focus the crop on the centre of the
image.

## No Magic

If you don't need to resize the image, specifying a magical option of
`noop` disables any kind of resizing, this is useful if you just need to
use the software a as a proxy. When operating in this mode there is no
dependency on imagemagick.

## Installation

Add this line to your application's Gemfile:

    gem 'rack-thumb-proxy'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rack-thumb-proxy

## Usage

The included railtie will ensure that this is available in your Rails
application, you can simply use something like:

    match '/media', :to => Rack::Thumb::Proxy

If you need to configure additional options, this can be done in an
initializer, or by passing a configuaation hash to the
Rack::Thumb::Proxy initialzer. The former is preferred.

## Example Configuration

    Rack::Thumb::Proxy.configure do
      prefix     "/media/"
      secret     "d94bba3d2e0b4809a570158506"
      key_length 10
    end

When one doesn't want to use the configuration API, the more succinct
version would be to do something like:

    # ./config/routes.rb
    match '/media' => Rack::Thumb::Proxy { prefix: "/",
                            secret: "ABC1234", key_length: 10 }

    # config.ru
    use Rack::Thumb::Proxy { prefix: "/", secret: "ABC1234", key_length: 10 }

One complication is that when using the link generator functions, one
**must** use the configuration API, otherwise the default path will be
`/`.

## To Do

 * Implement Railtie/helpers.
 * Ensure the hash signatures are checked.
 * Make it possible to control the cache control header.
 * Don't use open-uri.
 * Check earlier in the process that upstream is an image,
   don't rely on MiniMagick to blow up on non-image content.
 * Take the cache-control headers from upstream
   if we can.
 * Allow a local cache for the images, perhaps somewhere
   in `/tmp`.
 * Actually support option labels, it just looks good in 
   the readme right now, alas.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
