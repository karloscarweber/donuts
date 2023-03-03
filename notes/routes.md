# Routes

Yeah so I think it would be swell to have declarative Routes. We can make a really great interface for routing that makes buckets of sense.

Firstly I really dislike how routing is handled in other frameworks, with the exception of Sinatra and Roda. Rails for example uses a routes file that passes the URLs to particular actions. a resources helper assumes certain methods and maps requests to them. Which is fine I guess. but this approach assumes a very CRUDDY interface. Apps aren't so Cruddy anymore. They often have lite APIs to hydrate parts of the page. Or use WebSockets to keep polling for particular thing. We want to make streaming html easy as hell. Where's the URL for that? Making bespoke api endpoints for your app should be really really easy.

If you want a raw page without any controller, then you'll to make an empty controller method. That's dumb. why not, like a pages directory of just views? or something like that.

So, To be basic. I think we need a cascading routing tree. 

NOTE: I'm using the term Controller to also basically mean Route. Perhaps changing the name to Route makes more sense.

Some Ideas:

## Controller based routing:
```ruby
module Donuts::Controllers
	class Toot < Camper # '/toot'
		def get
			"You got this."
		end
		
		# yes you can toot, and you'll get a positive response from that
		def post(name="",toot="")
			tooted = Models::Toot.new(name, toot).save
			Responses::Toot::New.new(tooted) # The New Toot response will read the tooted save result and format itself accordingly.
		end
	end
end
```
With controller based routing, routes are bespoke, and honestly pretty damn cools. Camping does this thing where a route is a class, and it's methods are the get/post/put endpoints. I love that.

## Direct route management
```ruby
Camping.routes do |r|
	r.on '/' do
		r.get do
			"This is the homepage"
		end
		r.on '/toot' do
			r.get do
				"You got this."
			end
			r.post do |name,toot|
				tooted = Models::Toot.new(name, toot).save
				Responses::Toot::Succes.new(tooted)
			end
		end
	end
end
```
I really like this form too. Feels a lot like Roda because it basically is. Advantages are that You can map out your routes and execute code in the intermediary parts. Dis-advantage is that your Routing file could beceom really unruly because your whole application could be stuck inside. The Cascade model is very clear though. I really want a sort of inherited cascade model for Camping moving forward. That you build up context as you move through routes.

## Inherited Controller Based Routes
```ruby
module Donuts::Controllers
	class Users < Camper # /users
	end
	class Account < Users # /users/account
	end
end
```
I like the idea of Inheritance being used to grab the context and routing of a parent. Like a lot. Middleware could be the same too. Per Route Middleware might be a cool thing to think about.

## Explicent Controller Based routes
```ruby
module Donuts::Controllers
	class Users < R '/users'
		def get
			"All the users"
		end
	end
	class Account < R '/account', '/users/account' # /account and /users/account
		def get
			"Your account"
		end
	end
end
```
Camping has this cool convention where if you use the `R` method in the controllers module, it creates an anonymous Class, then fills it with all the necessary goodies for a controller, with you're explicit url, or urls.

## Folder based routing
```ruby
# app/controlers/pages/index.rb
class Index < Camper # URL: /pages
	def get
		"All the pages you can imagine."
	end
end
```
I'm not even sure how to pull this one off. Maybe the file is executed in a modules context when loaded. and that context delivers a parent URL for the Index. or a prefix. It would be fun to map your applications url structure to the structure of your controllers in that directory.