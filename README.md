© 2016 Flatstack

Based on [radiustar](https://github.com/pjdavis/radiustar).

#### DESCRIPTION:

Ruby Radius Server Library

#### FEATURES

* Import your own radius dictionaries
* Authentication
* Accounting

#### SYNOPSIS:

```ruby
require 'radius_client'

# Load dictionaries from freeradius directory
# NOTICE: here the Dictionary.new() only accept a parameter of "folder name" but not the dictionary file
dict = RadiusClient::Dictionary.new('/usr/local/share/freeradius/')

# Lets get authenticated
auth_custom_attr = {
  'Framed-Address'  => '127.0.0.1',
  'NAS-Port'        => 0,
  'NAS-Port-Type'   => 'Ethernet'
}
secret = 'testing123'
request_options = { dict: dict, secret: secret }

req = RadiusClient::Request.new('127.0.0.1:1812', request_options)
reply = req.authenticate('testing', 'password', auth_custom_attr)

if reply[:code] == 'Access-Accept'
  req = RadiusClient::Request.new('127.0.0.1:1813', request_options)

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

#### INSTALL:

`gem install radius_client`

or in `Gemfile`:

```ruby
gem "radius_client", git: "https://github.com/slavakisel/radius_client"
```

#### DEVELOPMENT:

After cloning the project install gems with `bundle`. Run `rake test` to check tests.
