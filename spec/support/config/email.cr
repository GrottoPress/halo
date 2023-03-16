BaseEmail.configure do |settings|
  settings.adapter = Halo::Adapter.new(
    host: "localhost",
    port: SMTP_PORT,
    credentials: nil
  )
end
