= dm-sanitizer

* http://github.com/pat/dm-sanitizer

== Description:

This package lets DataMapper properties be easily sanitized using Sanitize.

== Features and problems:

=== Features

* Sanitize String based properties by default
* Lets choose sanitization mode on per property basis
* Allows user defined sanitization modes

=== problems

* None known. Contact me if you find them.

== Synopsis:

  require 'rubygems'
  require 'dm-core'
  require 'dm-sanitizer'

  DataMapper.setup(:default, 'sqlite3::memory:')

  class SomeModel
    include DataMapper::Resource

    property :id,     Serial
    property :title,  String
    property :story,  Text
  end
  SomeModel.auto_migrate!

  obj = SomeModel.new
  obj.title = '<h1>Hi there</h1>'
  obj.story = '<em>Some sanitization <strong>needed</strong></em>'
  obj.save
  puts obj.title == 'Hi there'
  puts obj.story == 'Some sanitization needed'

  class SomeOtherModel
    include DataMapper::Resource
    sanitize :default_mode => :basic, :modes => {:restricted => :title}, :exclude => [:junk]

    property :id,     Serial
    property :title,  String
    property :story,  Text
    property :junk,   Text
  end
  SomeOtherModel.auto_migrate!

  obj = SomeOtherModel.new
  obj.title = '<h1><strong>Hi</strong> <a href="#">there</a></h1>'
  obj.story = '<h3><a href="#">Scince</a> knows many gitiks</h3>'
  obj.junk  = '<script>alert("xss")</script>'
  obj.save

  puts obj.title == '<strong>Hi</strong> there'
  puts obj.story == '<a href="#" rel="nofollow">Scince</a> knows many gitiks'
  puts obj.junk  == '<script>alert("xss")</script>'

== Requirements:

* DataMapper (dm-core)
* Sanitize (sanitize)

== Installation:

sudo gem install dm-sanitizer

== License

(The MIT License)

Copyright (c) 2009 Sergei Zimakov

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.