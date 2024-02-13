require "../spec_helper"

describe Halo::Adapter do
  it "delivers email" do
    SpecEmail.new.deliver

    SMTP_STORE.count.should eq(1)

    email = SMTP_STORE.messages.first.not_nil!

    email.should contain("From: Halo <noreply@halo.tld>")
    email.should contain("To: user@domain.tld")
    email.should contain("Subject: Hello")
    email.should contain("Content-Type: text/plain")
    email.should contain("Content-Type: text/html")
    email.should contain("X-Private: Yes")
    email.should contain("io-attachment.txt")
    email.should contain("SGVsbG8sIFdvcmxkIQ==")
  end
end
