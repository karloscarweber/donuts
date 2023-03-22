# Donuts
A Pastery Application

This is a pseudo code application directory thing that shows what we WANT the ideal application using our framework to look like, be organized, and conventions used in the framework. It's ephemeral and can be changed. There are no hard decisions or wrong answers yet.

There are 3 main areas
1. lib -> Literally copied camping into it so we could mess around here without fussing around with another repo yet.
2. app -> Where the "ideal" app structure would go.
3. notes -> A folder with notes about how things work, or could work.

The IDEA is to get a prototype working with RACKUP. This Readme will probably eveolve to remove lots of notes and instead become a vision document.


# Participate
We operate by consensus, but also hope to just have fun.

We're using Camping as the base. This means that Camping will need to have large portions rewritten to work the way we want it to. Thankfully Camping is pretty small and this isn't that hard. The only hard requirement for camping is to have a minifed core that fits in that little file. Because it's funny as hell.

# Development / Experimentation pattern / plan
I'm going to move Camping's source code into this Repo as I rewrite and rework it. No Bundle installing.gi The idea is to change it into the shape we want as fast as possible. Once we nail a really good interface and have it working the way we want we'll work backward to get the Camping Repo to adopt the newer design.

# Stack Goals:
Database:
- Sqlite
- Extralite
- Sequel

View:
- Phlex (Replace Mab with Phlex)(Actually MAB and Phlex, but make it easy to just use Phlex. Like all examples should have a toggle between them)

Routing
- ~~Roda / Camping (We still might just use Roda underneath)~~ We're using Camping, with a new routing API, and block based Controller/Route execution.

Servers:
- Tipi
- Falcon

Jobs:
- Custom job scheduling and operation class

Frontend:
- LiveView or Turbo
- Alpine or Stimulus

Asset pipeline:
- Vite?

# BIG IDEAS
- Be good at making websites! Like for reals. seriously. Capeche.
- Easy to make things testable and hella fast.
- Mountains of examples, and online documentation. REALLY WELL DOCUMENTED.
- These docs need to encompass more than just this framework, or Ruby. But include HTML, CSS, Javascript, deployment, etc... The goal should be developer success with the their goal of making websites.
- No "best practices" here. There shouldn't be any hard rules on how to do things. That's how _why worked and we should work in a similar fashion. having too much pomp and circumstance feels like it increases barriers to entry.
- We spell colour and behaviour like this.
- Beginner friendly. Honestly everything should be focused on helping new developers and juniors.

# Application Goals:
- Optionally allow your whole application to fit in a single file. So, Compact, yet clear syntax.
- Very sensible defaults.
- Simple and inspectible architecture.

# Pages
What if we had a pages directory of straight up templates that were rendered as static pages. Instead of having empty controllers everywhere. We could even use controller inheritance to casually pass variables to the templates if we wanted to. You know for funsies!

It's just really dumb that throwing up a static page in a dynamic website is so hard, you know?

How this would work? We'd probably need a way to inherit/override templates from the core app, in a cascade kinda way, to populate the pages. The pages are at a variety of urls, we set templates or layouts based on a controller or route. If the page matches one of those routes or controllers, then it inherits the template. Front Matter could be used to overwrite the template/layout.

# Big Tent little Tent
I keep thinking about how Camping is a Micro-Framework and that's not the goal. But also, every framework is a micro framework. There is a small core that everything is built around. Plugin systems and middleware can make a small framework pretty fully featured real quick. So the goal should be an easily understood, fast, good micro CORE, and make our plugin system so good that we can add anything we need/want very simply.

To clarify, I want very easy to understand and good defaults. The micro-framework is the router, the plugin system, the middleware, and the glue that brings all of that together. I hope we ship a lot of plugins and middleware, like RODA does.

# Some nice defaults/plugins:
- A user/login/logout/reset password system. Easy to extend if you need to. Simple to understand and extend.
- Some CSS!!!! Reset and base styles. I hate how every base Rails project looks so bad off the bat. Nothing should be this bad. Especially in 2023. The front end is treated like a jokey javascript playground.
- Composable and Testable Components. Make it easy to organize, test, and view components as you're working on them. Web Components: Have them in one place.
- Documentation by default. Drop in a documentation server and ship it with the framework. It should be possible to run a single command, and have a searchable website with all of your site's internal documentation.
- Make Cryptography easy. Built in and very good libraries for two-party and single party cryptography.

# Streaming services and Websockets
Make it easy to use and easy to understand. Falcon and Tipi are our Server targets. Why? because they are concurent and stream focused. Samuel Williams has an [excellent talk](https://ruby.social/@joeldrapper/109942394828795458) on the subject.

# Gear (Plugin) based routes, ui, components, etc...
Camping Gear should be able to add routes to the app, add Styles and Scripts to the app, and interface with the database. A common use case would be a login system that offers login, signup, reset password, logout, sign-in with email. All of that, with some assumption that the `User` Model will be accessed in a certain way, and will have certain methods. Would be great to just: `Donuts.pack Identity` and have all that taken care of.

# Standard hooks and conventions for really common stuff.
Like that user thing, but really for everything. Make it easy to know the lifecycle of a request. The hooks of Camping, and give any middleware or gear opportunity to overwrite or act upon that.

# Mail?
How do we do mail in this system? I have no idea.

# TABS vs Spaces
Tabs. For accessibility reasons.

# Testing
Use Green Dots for testing.

## Some camping stuff
I'm rewriting Camping's core as I build this out, basically to match what we decide on.

A note on that: I thought that Camping might be mildly difficult to match some of Roda's succinct syntax for routing and filter type functions, but I was wrong. Camping can do it really well.

## Problem with Namespacing:
What has a suffix and what doesn't? In Camping a class is a route, it then implements one of the http methods to respond to a request. Routes can be derived from the name of the Controller: `EditPage` would match `/edit/page`. Additionally you could pile routes into a class and match all requests to that single class: ` class EditPage < R '/silliness', 'another/silly/route'`.

The issue comes when we try to name models. In Rails, for example, Models don't have a prefix or a suffix, but every other main structural piece does though: `IndexView`, `ApplicationController`, `StoreMailer`. It's Controllers that don't have a prefix in Camping. Camping get's around this by placing Helpers, Views, Models, etc... in their own module to namespace them: `Models::User` for example.

Do we want to keep this convention? Should we do something different? I'm not sure.

## index.rb
I like the html convention that index.html is the defacto root of a webpage. What if we do the same thing with our namespaces for the parts of the framework. `index.rb` could be the root controller, for example. It also makes sense to make `views/index.rb` be the index of the site.

## internal notes
Uninstall Camping then reinstall the local copy:

```
bundle exec gem uninstall camping
bundle update camping
```


### Development
use the rerun gem to trigger basic.rb to reload everything.
```
rerun ruby basic.rb
```
This will load the default server and set everything up appropriately.
