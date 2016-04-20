# chatapp [![Build Status](https://semaphoreci.com/api/v1/pdore/chatapp/branches/master/shields_badge.svg)](https://semaphoreci.com/pdore/chatapp) [![Code Climate](https://codeclimate.com/github/doredesign/chatapp/badges/gpa.svg)](https://codeclimate.com/github/doredesign/chatapp)

A basic chat application.


Features
--------

 * Supports multiple concurrent users
 * Supports Multi person conversations
 * Could eventually support a native client
 * Shows when "User x is typing"
 * Shows message read states


Installation
------------

Make sure you have JDK 8 and jruby 1.7.20+ installed.

Clone the repo locally:
```
git clone https://github.com/doredesign/chatapp.git
```

Ensure you are using the `jruby-9.0.0.0` ruby.

Install gem dependencies:
```
bundle install
```

Set up the database:
```
bundle exec rake db:setup
```

Start the local app server:
```
JUBILEE=1 bundle exec jubilee --eventbus eventbus
```

Visit the app at [http://localhost:8080](http://localhost:8080)


Running the test suite
----------------------

```
bundle exec rake
```


Troubleshooting
---------------

From the [Jubilee gem](https://github.com/isaiah/jubilee):

> Under the default setup, jubilee runs 4 instances of webservers, each with it's own jruby runtime, if you find that jubilee crashes or hangs with OutOfMemeoryError, please tune your JVM OPTS like this:
>
> `export JAVA_OPTS="-Xms1024m -Xmx2048m -XX:PermSize=512m -XX:MaxPermSize=512m"`
>
> If your OS memory is quite limited, please run jubilee with
>
> `jubilee -n 1`
>
