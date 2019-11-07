# frozen_string_literal: true

require "sanitize_user_agent_header/version"

# This middleware will ensure that the User-Agent request header is actually
# UTF-8, which will prevent bad things down the road. Strictly speaking,
# the _string_ must be kept in an ISO encoding (single byte header limitations).
# But pragmatically we use this header in many places, and applying an explicit
# decode to it is a chore. Also, we are not violating the spec, merely "matching"
# the encoding of an input variable to the internal encoding of the system.
class SanitizeUserAgentHeader
  HTTP_USER_AGENT = 'HTTP_USER_AGENT'
  private_constant :HTTP_USER_AGENT

  def initialize(app)
    @app = app
  end

  def call(env)
    if env[HTTP_USER_AGENT]
      env[HTTP_USER_AGENT] = convert_string_to_utf8(env[HTTP_USER_AGENT])
    end
    @app.call(env)
  end

  # http://stackoverflow.com/questions/10384741/is-a-unicode-user-agent-legal-inside-an-http-header
  def convert_string_to_utf8(str)
    with_switchable_encoding = str.dup # for frozen strings
    # Try UTF-8 first because it is easier to affirm that the string is invalid UTF-8.
    # Any byte sequence is valid ISO and we will try it second
    with_switchable_encoding.force_encoding(Encoding::UTF_8)
    if with_switchable_encoding.valid_encoding?
      return with_switchable_encoding.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '?')
    end

    # If we ended up here the string is certainly _not_ UTF-8 and must be interpreted as ISO
    with_switchable_encoding.force_encoding(Encoding::ISO8859_1)
    with_switchable_encoding.encode(Encoding::UTF_8, invalid: :replace, undef: :replace, replace: '?')
  end

  if defined?(Rails)
    require_relative 'sanitize_user_agent_header/railtie'
  end
end
