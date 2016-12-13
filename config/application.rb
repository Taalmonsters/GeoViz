require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module GeoViz
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de
    
    config.app_name = "GeoViz"
    config.app_version = File.read(Rails.root.join("VERSION.txt"))

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true
    
    # Hide demo banner
    config.demo = false
    
    # Allow sign up of more than one user
    config.prevent_sign_up = false
    
    # Blacklab configuration
    config.blacklab_index_name = "geoviz"
    
    # Taalmonsters configuration
    config.pages = [["home", "/", "", 0], ["extracts", "/documents", "", 1], ["metadata", "/metadata", "", 2], ["users", "/users", "", 3]]
    config.admin_name = ENV["ADMIN_NAME"]
    config.admin_email = ENV["ADMIN_EMAIL_ADDRESS"]
    config.admin_password = ENV["ADMIN_PASSWORD"]
    config.email_provider_username = ENV["SMTP_EMAIL_ADDRESS"]
    config.email_provider_password = ENV["SMTP_EMAIL_PASSWORD"]
    config.domain_name = ENV["DOMAIN_NAME"]
    config.email_server_address = ENV["SMTP_EMAIL_SERVER"]
    config.email_server_port = ENV["SMTP_EMAIL_PORT"]
    config.application_host = ENV["GEOVIZ_APPLICATION_HOST"]
    
    # Nested metadata configuration
    config.document_fields = ["geoparser_locs", "annotated_locs"]
    config.hide_document_lock_in_index = true
    config.custom_filters = {
      "AnnotatedByUser" => { :klass => "Extract", :method => "annotated_by_user" },
      "TokenCount" => { :klass => "Extract", :method => "token_count_in_range" },
      "Content" => { :klass => "Extract", :method => "content_contains" }
    }
    config.default_document_sort = "extracts.name"
    config.default_document_order = "asc"
  end
end
