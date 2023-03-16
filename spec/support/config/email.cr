BaseEmail.configure do |settings|
  settings.adapter = Halo::Adapter.new("localhost", SMTP_PORT)
end
