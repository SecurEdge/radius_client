#### DESCRIPTION:

Ruby Radius Server Library

#### FEATURES

* Import your own radius dictionaries
* Authentication
* Accounting

#### SYNOPSIS:

```ruby

require 'rubygems'
require 'radiustar'

# Load dictionaries from freeradius directory
# NOTICE: here the Dictionary.new() only accept a parameter of "folder name" but not the dictionary file
dict = Radiustar::Dictionary.new('/usr/share/local/freeradius/')

# Lets get authenticated
auth_custom_attr = {
  'Framed-Address'  => '127.0.0.1',
  'NAS-Port'        => 0,
  'NAS-Port-Type'   => 'Ethernet'
}
secret = 'testing123'
request_options = { dict: dict, secret: secret }

req = Radiustar::Request.new('127.0.0.1:1812', request_options)
reply = req.authenticate('testing', 'password', auth_custom_attr)

if reply[:code] == 'Access-Accept'
  req = Radiustar::Request.new('127.0.0.1:1813', request_options)

  acct_custom_attr = {
    'Framed-Address'    => '127.0.0.1',
    'NAS-Port'          => 0,
    'NAS-Port-Type'     => 'Ethernet',
    'Acct-Session-Time' => 0
  }

  timings = Time.now
  reply = req.accounting(:start, 'testing', 'password', '123456', acct_custom_attr)

  sleep(rand 5)
  acct_custom_attr['Acct-Session-Time'] = Time.now - timings
  reply = req.accounting(:update, 'testing', 'password', '123456', acct_custom_attr)

  sleep(rand 5)
  acct_custom_attr['Acct-Session-Time'] = Time.now - timings
  reply = req.accounting(:stop, 'testing', 'password', '123456', acct_custom_attr)
end
```

#### REQUIREMENTS:

* Ruby >=2.2.3

#### INSTALL:

`gem install radiustar`

#### DEVELOPMENT:

After cloning the project install gems with `bundle`. Run `rake test` to check tests.

#### Thanks:

Thanks to everyone who has contributed to this project.
Without your help and support, this would not have been possible.

#### LICENSE:

Originally released under the CC0 1.0 Universal license by [PJ Davis](https://github.com/pjdavis) in 2010.
