require 'spec_helper'
require 'rack'
require 'rack/test'

describe SanitizeUserAgentHeader do
  include Rack::Test::Methods
  
  let(:app) {
    app_proc = ->(env) {
      [200, {}, [env.fetch('HTTP_USER_AGENT', '<NONE>').encode(Encoding::UTF_8)]]
    }
    SanitizeUserAgentHeader.new(app_proc)
  }

  it 'calls the app when no user agent header is set' do
    get '/'
    expect(last_response.body).to eq("<NONE>")
  end

  it 'calls the app when the user agent is just ASCII' do
    get '/', {}, {'HTTP_USER_AGENT' => 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1)'}
    expect(last_response.body).to eq("Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1)")
  end

  describe 'with non-ASCII characters in the User-Agent header combined with UTF-8 params' do
    ['ISO-8859-1', 'CP1252'].each do | windows_encoding |
      it "decodes the UA header and prevents encoding errors for UA header in #{windows_encoding}" do
        # From our actual bug records
        utf8_ua = 'Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; Pernod Ricard España)'
        windows_ua = utf8_ua.encode(windows_encoding)
        post '/', {'message' => 'Voiçi un header'}, {'HTTP_USER_AGENT' => windows_ua}
        expect(last_response).to be_ok
        expect(last_response.body).to eq('Mozilla/5.0 (compatible; MSIE 9.0; Windows NT 6.1; WOW64; Trident/5.0; Pernod Ricard España)')
      end
    end
  end
end
