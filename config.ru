require_relative 'autoload'

use Rack::Reloader
use Rack::Static, urls: ['/stylesheets'], root: 'public'
use Rack::Static, urls: ['/assets', '/assets/css', 'assets/js'], root: 'public'
use Rack::Session::Cookie, key: 'rack.session', secret: 'secret'

run Racker