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
dict = Radiustar::Dictionary.new('/usr/share/freeradius/')

# Lets get authenticated
auth_custom_attr = {
  'Framed-Address'  => '127.0.0.1',
  'NAS-Port'        => 0,
  'NAS-Port-Type'   => 'Ethernet'
}

req = Radiustar::Request.new('127.0.0.1', { :dict => dict })
reply = req.authenticate('John Doe', 'hello', 'testing123', auth_custom_attr)

if reply[:code] == 'Access-Accept'
  req = Radiustar::Request.new('127.0.0.1:1813', { :dict => dict })

  acct_custom_attr = {
    'Framed-Address'  => '127.0.0.1',
    'NAS-Port'        => 0,
    'NAS-Port-Type'   => 'Ethernet',
    'Acct-Session-Time' => 0
  }

  timings = Time.now
  reply = req.accounting_start('John Doe', 'testing123', '123456', acct_custom_attr)

  sleep(rand 5)
  acct_custom_attr['Acct-Session-Time'] = Time.now - timings
  reply = req.accounting_update('John Doe', 'testing123', '123456', acct_custom_attr)

  sleep(rand 5)
  acct_custom_attr['Acct-Session-Time'] = Time.now - timings
  reply = req.accounting_stop('John Doe', 'testing123', '123456', acct_custom_attr)
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