Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*'
    resource(
      '*',
      headers: :any,
      expose: %i[Authorization],
      methods: %i[get patch put post options head]
    )
  end
end
