class SanitizeUserAgentHeader::Railtie < Rails::Railtie
  initializer "sanitize_user_agent_header.configure_rails_initialization" do |app|
    app.middleware.use SanitizeUserAgentHeader
  end
end
