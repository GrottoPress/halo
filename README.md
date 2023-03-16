# Halo

**Halo** is a simple SMTP adapter for [Carbon](https://github.com/luckyframework/carbon) mailer.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     halo:
       github: GrottoPress/halo
   ```

2. Run `shards install`

## Usage

Set an instance of `Halo::Adapter` as *Carbon*'s adapter:

```crystal
require "carbon"
require "halo"

abstract class BaseEmail < Carbon::Email
end

BaseEmail.configure do |settings|
  settings.adapter = Halo::Adapter.new(
    host: "smtp.domain.tld",
    port: 587,
    username: "user@domain.tld",
    password: "a1b2c3",
    domain: "domain.tld" # HELO domain
  )
end
```

That's it! Send emails as usual. Check out *Carbon*'s [documentation](https://luckyframework.org/guides/emails/sending-emails-with-carbon) for details.

## Development

Run tests with `crystal spec -p`.

## Contributing

1. [Fork it](https://github.com/GrottoPress/halo/fork)
1. Switch to the `master` branch: `git checkout master`
1. Create your feature branch: `git checkout -b my-new-feature`
1. Make your changes, updating changelog and documentation as appropriate.
1. Commit your changes: `git commit`
1. Push to the branch: `git push origin my-new-feature`
1. Submit a new *Pull Request* against the `GrottoPress:master` branch.

