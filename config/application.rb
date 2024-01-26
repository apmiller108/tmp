require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module Tmp
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 7.0

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    config.generators do |g|
      g.template_engine :haml
    end

    # view component path for the generator
    config.view_component.view_component_path = 'app/views/components'
    # view component path for previews
    config.view_component.preview_paths << "#{Rails.root}/spec/components/previews"
    # generate view component templates in a sub directory (eg, user_component/user_component.html.haml)
    config.view_component.generate.sidecar = true
    config.view_component.component_parent_class = 'ApplicationViewComponent'

    # config.eager_load_paths << Rails.root.join("extras")
    config.autoload_lib(ignore: %w[assets tasks])
    config.eager_load_paths << Rails.root.join('app', 'views', 'components')

    config.after_initialize do
      ActionText::ContentHelper.sanitizer.class.allowed_attributes += %w[
        aria-controls aria-expanded controls data-blob-target data-controller
        data-bs-target data-bs-toggle data-transcription-target data-turbo data-turbo-stream disabled
        id poster preload style type
      ]
      ActionText::ContentHelper.sanitizer.class.allowed_tags += %w[
        audio embed iframe source video button turbo-frame mark
      ]
    end

    # to_prepare block runs once at application startup and before reloading
    config.to_prepare do
      ActiveStorage::Blob.include(ActiveStorageBlobExtension)
      ActiveStorage::Attachment.include(ActiveStorageAttachmentExtension)
      ActionText::RichText.include(ActionTextRichTextExtension)
    end
  end
end
