# Basic Rack App.
We're going to work backwards from a basic rack app, then adapt a camping Router into it to get this rolling faster.

We want to, by default, support Everything awesome that Rack 3 supports. It might even be cool to fork the Rack stuff like Camping already does.

Keeping Camping's Dynamic router, and at least on Development, reloading is a priority. But we also might be able to introduce a "compile" step to routes and generate a more streamlined routing tree for Camping.

Priorities:
1. Support Rack 3.0 completely.
2. Make middleware ease to add, introspect, and understand.
3. Have Clear hooks for Camping gear to make additions and changes to Camping, Add Middleware, or overwrite small parts of the application or just parts of the application.
4. Have the default routing and response patterns very easy and succinct. Just a couple of lines to return a response.

First off a Rack App:
```ruby
run do |env|
  [200, {}, ["Hello World"]]
end
```

That's it. Basically we return a status code, that's the first number. It says if everything was A OK or not. The second value, is a hash of values. All of these values are provided by the "environment". They are things like, what URL was requested, query parameters, whether it's https or http. you know, stuff like that.

so, in between the beginning and the end of the your code, you can add something call *middleware*. Because it's Ware that you stick in the middle. Super useful for enforcing stuff like https, or sessions, or for short circuiting the request if you're just serving a file.

## So where does Camping Come in?
Well Camping is like Glue Code. It's used to help you organize all the fancy stuff that you want to do. Where do you put your files? The database? How do you process forms and stuff? That's what Camping helps with. Camping is brilliant at this and we're just here to make it a little better.

## Ideal Request -> Response Architecture
* You have a number of apps in an Array. These are objects.
```ruby
	[Donuts,Pages,Login,API]
```
* When Camping recieves a Rack Request, it Cycles through each Camping App to determine which one should receive the request. Then it calls that app with the request.
* The Camping app process the request with it's associated middleware all intact and stuff. Individual endpoints or routes can have special middleware called *before* and *after* statements. Code that runs before and after the request.

There are a LOT of other little things that go into a website. Things that shouldn't be repeated or thought about EVERY TIME you want to make a website. The whole purpose of a web framework is to make all the common stuff automatic, and everything else easy and/or achievable.