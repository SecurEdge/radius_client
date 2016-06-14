Based on [radiustar](https://github.com/pjdavis/radiustar).

#### DESCRIPTION:

Ruby Library for interacting with (freeradius server)[http://freeradius.org/]

#### FEATURES

* Import your own radius dictionaries
* Authentication
* Accounting

#### SYNOPSIS:

```ruby
require 'radius_client'

RadiusClient.configure do |config|
  config.host = "127.0.0.1"
  config.secret = "testing123"
  config.dictionary_dir = "/usr/local/share/freeradius"
end

# Lets get authenticated
auth_custom_attr = {
  'Framed-Address'  => '127.0.0.1',
  'NAS-Port'        => 0,
  'NAS-Port-Type'   => 'Ethernet'
}

req = RadiusClient::Request.new
reply = req.authenticate('testing', 'password', auth_custom_attr)

if reply[:code] == 'Access-Accept'
  req = RadiusClient::Request.new(port: 1813)

  acct_custom_attr = {
    'Framed-Address'    => '127.0.0.1',
    'NAS-Port'          => 0,
    'NAS-Port-Type'     => 'Ethernet',
    'Acct-Session-Time' => 0
  }

  timings = Time.now
  reply = req.accounting(:start, 'testing', 'password', acct_custom_attr)

  sleep(rand 5)
  acct_custom_attr['Acct-Session-Time'] = Time.now - timings
  reply = req.accounting(:update, 'testing', 'password', acct_custom_attr)

  sleep(rand 5)
  acct_custom_attr['Acct-Session-Time'] = Time.now - timings
  reply = req.accounting(:stop, 'testing', 'password', acct_custom_attr)
end
```

#### REQUIREMENTS:

* Ruby >=2.2.3
* Freeradius >= 3.0.1

#### INSTALL:

`gem install radius_client`

or in `Gemfile`:

```ruby
gem "radius_client", git: "https://github.com/fs/radius_client"
```

#### CONFIGURATION:

Generate rails config:

`rails generate radius_client:install radius_client`

#### DEVELOPMENT:

After cloning the project install gems with `bundle`. Run `rake test` to check tests.
