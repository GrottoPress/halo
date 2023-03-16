class SpecEmail < BaseEmail
  from Carbon::Address.new("Halo", "noreply@halo.tld")
  to "user@domain.tld"
  reply_to "hello@halo.tld"
  subject "Hello"

  header "X-Private", "Yes"
  header "Message-ID", "<abc123@halo.tld>"
  header "Sender", "hello@halo.tld"

  def text_body
    "Hello, World!"
  end

  def html_body
    "<h1>Hello, World!</h1>"
  end
end
