class GenericServer
  def close
    @server.close unless @server.closed?
  end
end

class Store
  def reset
    @messages.clear
  end
end

SMTP_PORT = 2525
SMTP_STORE = Store.new

server = SMTPServer.new(SMTP_STORE, SMTP_PORT)

Spec.before_each { SMTP_STORE.reset }

Spec.after_suite { server.close }

server.run
