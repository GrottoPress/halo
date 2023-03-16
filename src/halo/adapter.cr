class Halo::Adapter < Carbon::Adapter
  def initialize(
    @host : String,
    @credentials : Credentials?,
    @port = 587,
    domain = nil,
    @tls = true
  )
    @domain = domain.presence || @host
  end

  def self.new(
    host,
    username : String,
    password : String,
    port = 587,
    domain = nil,
    tls = true
  )
    credentials = {password: password, username: username}
    new(host, credentials, port, domain, tls)
  end

  def deliver_now(email : Carbon::Email)
    EMail.send(config) do
      subject(email.subject)
      from(email.from.address, email.from.name)

      email.to.each { |_to| to(_to.address, _to.name) }
      email.cc.each { |_cc| cc(_cc.address, _cc.name) }
      email.bcc.each { |_bcc| bcc(_bcc.address, _bcc.name) }

      email.headers.each do |name, value|
        case name.downcase
        when "reply-to"
          reply_to(value)
        when "message-id"
          message_id(value)
        when "return-path"
          return_path(value)
        when "sender"
          sender(value)
        else
          custom_header(name, value)
        end
      end

      if text = email.text_body
        message(text)
      end

      if html = email.html_body
        message_html(html)
      end
    end
  end

  private def config
    EMail::Client::Config.new(
      @host,
      @port,
      helo_domain: @domain
    ).tap do |config|
      config.client_name = "Carbon"

      config.use_tls(EMail::Client::TLSMode::STARTTLS) if @tls

      @credentials.try do |credentials|
        config.use_auth(credentials[:username], credentials[:password])
      end

      config.tls_context.set_modern_ciphers

      config.tls_context.add_options(
        OpenSSL::SSL::Options::NO_SSL_V2 |
        OpenSSL::SSL::Options::NO_SSL_V3 |
        OpenSSL::SSL::Options::NO_TLS_V1 |
        OpenSSL::SSL::Options::NO_TLS_V1_1
      )
    end
  end
end
