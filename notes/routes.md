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
		request.get &Index
		request.post &Create
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



#### New spec draft: 

Hi Friends!

I've been working on making Camping a bit more capable when building out larger applications, while maintaining a succinct API and the only really good way to do this is to add a couple of interfaces for setting up controllers/routes. So! Here is a new spec for routing in camping:

## Defining Routes
In Camping you can define routes by calling an `Object` scoped helper method:
```ruby
get '/' do
	"This is a great response that we can just receive."
end
```

These methods define a route, or routes, accept a block at the end, and match an HTTP method that corresponds with their method name. Example: `get` matches `GET`, `post` matches `POST`.

Routes defined in this way may also accept parameters, These are passed to the block as named parameters:
```ruby
get '/users/:username' do |username|
	"Welcome to #{username}'s page."
end
```

You may be familiar with this method of route definition, it's the way that Sinatra Works.

## Controller Based routing
With Camping 3  we're introducing a new Class named `Camper` That our Controller Based Routes inherit from. Having no inheritance in Camping made setting up state in our controllers, or adding certain helper methods more complicated than it needed to be. So now we have `Camper`. 

To make controllers in our apps, do the following:
```ruby
module Donuts::Controllers
	class Toot < Camper # matches '/toot' URL.
    
		# have a before block executed.
		_before -> { before_method(); another_before_method() }
		
		# have a layout helper to execute a layout for this controller.
		_layout -> { Donuts::Views::SuperLayout }
		
		def get
			"You got this."
		end
		
		def post(name="",toot="") # matches named parameters name, and toot
			tooted = Models::Toot.new(name, toot).save
			Responses::Toot::New.new(tooted) # The New Toot response will read the tooted save result and format itself accordingly.
		end
	end
end
```

Controllers also give us the advantage of having `_before`, and `_layout` helper instance_methods. Giving us a block to execute before our methods, and for setting up a layout. `_after` is also planned.

## Inheritance based routing
You can also make a route based on inheriting from a parent class:
```ruby
module Donuts::Controllers
	class Users < Camper # /users
	end
	class Account < Users # /users/account
	end
end
```

Inheriting from routes in this manner also passes along the `_before` block and `_layout`. Maybe a strip method could let us strip out some of those options if they are different based on a sub page:
```ruby
module Donuts::Controllers
	class Account < Users # /users/account
		_strip_layout() # Strips the layout
		_strip_before :before_method # Strips just that before method.
	end
end
```

## Explicit Routing
You can also set explicit routes for Camping controllers:
```ruby
module Donuts::Controllers
	# matches /users
	class Users < R '/users'
		def get
			"All the users"
		end
	end
	# matches /account and /users/account
	class Account < R '/account', '/users/account' 
		def get
			"Your account"
		end
	end
end
```

## Cascading Routes
Camping 2.3 reintroduced the idea behind multiple apps. I think it's cool as hell. An Advantage to setting up multiple apps is *including* a base app into another app, thus inheriting it's Middleware, before filters, layouts, views, etc... I had an idea that you could also inherit the root route of an inherited app, just like Controllers can inherit from one another. I wanna call this *Cascading Routes*.
```ruby
Camping.goes :Donuts # make your first Camping app. First app is scoped to '/'
module Donuts

	# Routes class or module matches a proc to a URL.
	# Do this inside of a module to capture it's instance variables and reference
	# them.
	get '/' do
		"Do something amazing!"
	end
	
	# The Donuts' app controller module
	module Controllers
		class Posts
			def get # '/posts'
				"Do something Amazing"
			end
		end
	end
	
	Camping.goes :Users # or Donuts.goes :Users
	# Users app is namespaced into Donuts Module,
	# Because it *goes* inside of the Donuts module.
	module Users::Controllers
		class Index < R '/all_users' # 
			def get
				"List all Users"
			end
		end
	
		# Make an Account app inside of the Users app.
		# not only namespaced but also a *descendant* or *child* of
		# The Users app.
		Users.goes :Account
		module Account::Controllers
			class Index < Camper # /users/account because the parent 
				def get
					"List all Users"
				end
			end
		end
	end

end
```

I also had an idea about folder based routing, but that felt a bit too complicated to implement. Maybe Save that idea to add a generic **pages** folder to your app root that holds, maybe just markdown files, and generates static pages in a camping app without requiring a Route be made somewhere in a controller.

# Camping Named Routes
Camping also does this really clever thing where the name of a camping controller denotes it's route:
```ruby
module Nuts::Controllers
	class PostMypostX < Camper # matches /post/mypost/:a_number
	end
end
```
I would love to keep this API. for a lot of reasons.

## Flattened Routes
Now that we have all of this fancy routing stuff. How do we get our routes to fire? Camping has a very simple process. Each *App* that we create is added to a `Camping::Apps` constant, an array, in the Camping Module. Our Camping Server iterates over each app, and checks against a 'urls' array for that app, trying to find a match to the current request. I love this, and I would love to keep it this simple. But in the interest in exposing exactly how Camping's routes work, and to make it much faster, I believe we should Flatten these routes.

Every time a route is created in Camping, We'll now be making a `Route` Struct. it will have a reference to the Block that's executed whent the route runs, the route to be matched, named parameters that are passed, and anything else we can think of. Most importantly it will have a reference to WHERE the route was made and if it overwrites a previously set Route. My hope is that by placing routes into an intermediate object like this, and THEN building a routing tree from it, we'll be able to expose routing to developers in a very verbose way.

Also by making routes in this manner I hope to have plugins that can set their own routes, files, and actions in our camping apps, that can then be overwritten or customized down the line.

Hoping the Routes could look something like this:

```ruby
Camping::Server.start # starts the server, but also compiles the routing tree/list thing.
Camping.Routes [
	<Route: @url="/", @proc="&Controllers::", @ancestor="Donuts">
	<Route: @url="/posts", @proc="&Donuts::Controllers::Posts", @ancestor="Donuts::Controllers">
	<Route: @url="/users", @proc="&block", @ancestor="Donuts::Users::Controllers::Index">
]
```