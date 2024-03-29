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

## Explicet Controller Based routes
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

## Proc/Block based route matching.
Another approach is to make a Roda type block tree, and even pass a Proc, which is a Module to the matched Routes. Then in your modules you define `to_proc` and `call`. to_proc would just pass the request to the desired method/module/class thing; Whatever it is we want. We would then also have a place to add Before/After Filters, or even custom middleware if we chose.
```ruby

# Maybe we can set a route using 
r.on "Foo", &Foos

module Foos
	def to_proc
		method(:call).to_proc
	end
	
	def call(request)
		_before.call
		# request.get &Index
		# request.post &Create
		
		# perform route matching here
		# that_matches is a refinement or extra method on the _routes array.
		# it will iterate over the routes, finding the one that matches the request,
		# then issue a to_proc call on it, cache it, then run through call also.
		# This is what happens on App Modules. or apps. Once we get to a controller
		# class, AKA `class Post`, or something, the to_proc, and call methods will
		# directly pass the call the right constructed block.
		_routes.that_matches(request).call
		
		_after.call
	end
end
```

I really like this idea because procs and blocks are fast. This gives us an opportunity to also build our routes/controllers in a pleasant way, give them context and circumstance, and yet still keep things fast.

I really like the idea that we could *"compile"* our routes and controllers into a fast block based routing tree. Sincerely I think this is the way to go.

Namespacing a Camping module into another Camping Module will automatically prefix it's URLs. I think. We might need to use Classes so that we can take advantage of Inheritance.
```ruby
Camping.goes :Donuts # make your first Camping app. First app is scoped to '/'
module Donuts
	
	# Routes class or module matches a proc to a URL.
	# Do this inside of a module to capture it's instance variables and reference
	# them.
	Routes.on '/' do
		"Do something amazing!"
	end
	
	# Controller based routing too!
	module Controllers
		class Posts
			def get
				"Do something Amazing"
			end
		end
	end
	
	Camping.goes :Users # or Donuts.goes :Users
	module Users::Controllers		
		class Index < R '/all_users' # 
			def get
				"List all Users"
			end
		end
	end
	
end

# List of routes?
# Routes.list
#	<Route: @url="/", @proc="&block", @ancestor="Donuts">
# Maybe have a Route object that gets built up from these 

Camping::Server.start # starts the server, but also compiles the routing tree/list thing.
Camping.Routes [
	<Route: @url="/", @proc="&Controllers::", @ancestor="Donuts">
	<Route: @url="/posts", @proc="&Donuts::Controllers::Posts", @ancestor="Donuts::Controllers">
	<Route: @url="/users", @proc="&block", @ancestor="Donuts::Users::Controllers::Index">
]

# The routing tree can then be Flattened into a proc -> 
# Routes class or module matches a proc to a URL.
Camping::Routes.on '/' do |r|
	"Do something amazing!"
	r.on '/posts', &Donuts::Controllers::Posts
	r.on '/users', &Donuts::Users::Controllers::Index
end
```

My only wonder is if each proc will preserve the context that they are executed. I'm thinking YES, and that calling placing generated `r.on` statements into a proce that's then evaled to create the routing table will give us the results we expect.

Under this method the `Routes` object holds a graph of all routes and controllers set up, then builds the actual routing object using Eval. I also like this because we can make pretty good `Route` objects that hold a lot of Data, and give our introspection tools a lot to work with. Lots of details about how it's working.

### About that Proc Stuff
I've ben thinking about how routing ought to work and the implications of using the to_proc method. I really like it and Camping's Routes should probably work like this underneath. But how exactly?

I know we're making a constructed routing tree through a compilation process, and that we have intermediate Route objects that we're making for each App/Controller/SubApp/Thing. So how do we respect inheritance, and binding actions in a predictable manner?

Maybe when we inherit an execution context, as in an App having a controller inside that also has a before block, we are really executing a proxy block that then routes our real request to the method we want to execute?
```ruby
module Donuts
	_before -> { ensure_user }
	module Controllers
		class Account < Camper
			_before -> { @account = get_account_data}
			def get
				"Welcome back #{@account.name}."
			end
		end
	end
end
```

So in this case both the Donuts before block and the Account before block are executed. How do we prevent that? I think we can solve that in our compile stage. We'll flag that we want to ignore the previous before block, then add our own.

```ruby
module Donuts
	_before -> {ensure_user }
	module Controllers
		class Account < Camper
			_fresh_before() # flags that we want to start fresh with our before block
			_before -> { @account = get_account_data }
			def get
				"Welcome back #{@account.name}."
			end
		end
	end
end
```

We're going to have controller inheritance and App Nesting. Ideally an inherited controller will have it's before block inherited from it's parent. If we want to add to it without replacing it we run into a problem.

```ruby
class ConnectedApps < R Account
	_before -> { @apps = get_user_apps } # get_user_apps depends on user data. But where is it? We'll error here.
	def get
		request.body = "<ul>"
		@apps.each { |a| request.body << "<li>#{a.name}<li>" }
		request.body = "</ul>"
		request.body
	end
end
```

Perhaps the solution is to append to the before?
```ruby
class ConnectedApps < R Account
	# appends to the before
	_append_before -> { @apps = get_user_apps }
end
```

This would make a new, compound proc that references the original proc then calls the new one.

What do ya'll think of this?