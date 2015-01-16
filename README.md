# Grape::Generate
Grape application template generator with batteries included

## Getting started

First, install gem into your system

    $ gem install 'grape-gen'
then grape-gen binary will be available in your shell.
To generate default app skeleton, simply use:

    $ grape-gen app your_app_name
After executing complete, dir __your_app_name__ will be created in current dir.  
Navigate into created dir and do ```$ bundle```

## Whats included?
* carrierwave
* sidekiq
* faye
* elastic search
* redis

## Grape API rack app
Rack app intended to be run under EventMachine-powered server (skeleton app using Thin)  
Every library used is patched to play ball with EventMachine event loop.  
To start web server:

    $ RACK_ENV=production thin start -p 9292
Example webserver responding to following API methods:

* POST /api/auth/register (display_name, email)
* POST /api/auth/approve_email (email, email_approvement_code)
* GET  /api/profile
* PUT  /api/profile (avatar, remove_avatar, display_name)

/api/profile methods is restricted to use only by registered users.  
API user must supply X-Authorize header, received from /api/auth/approve_email

When user approves email by calling POST /api/auth/approve_email with valid data,  
message containing user __display_name__ will be published into faye __/user/registered__ channel  
so all faye connections subscribed to /user/registered channel will receive info about newly registered user

## Faye (optional, enabled by default)
Include faye support into skeleton app.
To start faye server:

    $ thin start -p 9393 -R faye.ru -e production
While running web server and faye server, please, visit http://localhost:9292/faye  
Webpage contains simple implementation of faye client, connecting to localhost:9393 server  
After successful connection client subscribes on two channels: __/user/registered__ and __/time__  
Faye events received displayed at the top of webpage

## Sidekiq (optional, enabled by default)
Include support for background jobs via Sidekiq gem  
Besides of main Sidekiq gem it also adds gem supporting jobs scheduling  
Out of the box skeleton app have one scheduled job defined - __/jobs/pong_time.rb__  
Job, scheduled to run each 5 seconds, simply publishes current time into /time faye channel
so all faye connections subscribed to /time channel will receive current time string  
For more information take a look at /config/sidekiq.yml

## Mandrill (optional, enabled by default)
Include support for email delivery with Mandrill service via MandrillMailer gem.  
To have this gem running you should add your Mandrill api key to __/config/application.yml__  
After successful registration with __POST /api/auth/register__ app tries to send message to  user email using __/mailers/registraion_mailer.rb__  
To have email delivered please make sure you have changed __from__ address in __/mailers/registraion_mailer.rb__ and appropriate domain name is registered for api key you add to config.file.

## TODO

More documentation

## Contributing

1. Fork it ( https://github.com/AlexYankee/grape-gen/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
