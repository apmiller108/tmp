Sidekiq.configure_server do |config|
  config.redis = { url: Rails.application.credentials[:redis_url] }

  config.on(:startup) do
    schedule_file = 'config/sidekiq_cron.yml'
    if File.exist?(schedule_file)
      Sidekiq::Cron::Job.load_from_hash!(YAML.load_file(schedule_file), source: 'schedule')
    end
  end

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end

  config.server_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Server
  end

  SidekiqUniqueJobs::Server.configure(config)
end

Sidekiq.configure_client do |config|
  config.redis = { url: Rails.application.credentials[:redis_url] }

  config.client_middleware do |chain|
    chain.add SidekiqUniqueJobs::Middleware::Client
  end
end
