class Halo::Adapter < Carbon::Adapter
  def initialize(
    @host : String,
    @port = 587,
    @credentials : Credentials? = nil,
    domain = nil,
    @tls = false
  )
    @domain = domain.presence || @host
    @tls = @credentials ? true : tls
  end

  def self.new(
    username : String,
    password : String,
    host,
    port = 587,
    domain = nil
  )
    credentials = {password: password, username: username}
    new(host, port, credentials, domain)
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

      email.attachments.each do |attachment|
        case attachment
        in Carbon::AttachFile
          attach **attach_file_args(attachment)
        in Carbon::AttachIO
          attach **attach_io_args(attachment)
        in Carbon::ResourceFile
          message_resource **resource_file_args(attachment)
        in Carbon::ResourceIO
          message_resource **resource_io_args(attachment)
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

  private def attach_file_args(attachment)
    {
      file_path: attachment[:file_path],
      file_name: attachment[:file_name],
      mime_type: attachment[:mime_type]
    }
  end

  private def attach_io_args(attachment)
    {
      io: attachment[:io],
      file_name: attachment[:file_name],
      mime_type: attachment[:mime_type]
    }
  end

  private def resource_file_args(attachment)
    {
      file_path: attachment[:file_path],
      cid: attachment[:cid],
      file_name: attachment[:file_name],
      mime_type: attachment[:mime_type]
    }
  end

  private def resource_io_args(attachment)
    {
      io: attachment[:io],
      cid: attachment[:cid],
      file_name: attachment[:file_name],
      mime_type: attachment[:mime_type]
    }
  end
end
