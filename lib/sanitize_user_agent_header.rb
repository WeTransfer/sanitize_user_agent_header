require "sanitize_user_agent_header/version"

# This middleware will ensure that the User-Agent request header is actually
# UTF-8, which will prevent bad things down the road. Strictly speaking,
# the _string_ must be kept in an ISO encoding (single byte header limitations).
# But pragmatically we use this header in many places, and applying an explicit
# decode to it is a chore. Also, we are not violating the spec, merely "matching"
# the encoding of an input variable to the internal encoding of the system.
class SanitizeUserAgentHeader
  HTTP_USER_AGENT = 'HTTP_USER_AGENT'.freeze
  private_constant :HTTP_USER_AGENT
  
  def initialize(app)
    @app = app
  end
  
  def call(env)
    if env[HTTP_USER_AGENT]
      env[HTTP_USER_AGENT] = opportunistically_convert_to_utf8(env[HTTP_USER_AGENT])
    end
    @app.call(env)
  end
  
  # http://stackoverflow.com/questions/10384741/is-a-unicode-user-agent-legal-inside-an-http-header
  def opportunistically_convert_to_utf8(str)
    try_encodings = %w( ISO-8859-1 CP1252 )
    try_encodings.each do |enc|
      begin
        encoded_as_utf8 = str.force_encoding(enc).encode(Encoding::UTF_8)
        return encoded_as_utf8
      rescue Encoding::UndefinedConversionError
      end
    end
    # Last resort, just strip it of everything
    str.force_encoding(Encoding::ISO8859_1)
    str.encode(Encoding::ASCII, invalid: :replace, undef: :replace, replace: '?').encode(Encoding::UTF_8)
  end
  
  if defined?(Rails)
    require_relative 'sanitize_user_agent_header/railtie'
  end
end
