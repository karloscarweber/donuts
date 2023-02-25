# Donuts
A Pastery Application

This is a pseudo code application directory thing that shows what we WANT the ideal application using our framework to look like, be organized, and conventions used in the framework. It's ephemeral and can be changed. There are no hard decisions or wrong answers yet. 

We operate by consensus, but also hope to just have fun.

We're using Camping as the base. This means that Camping will need to have large portions rewritten to work the way we want it to. Thankfully Camping is pretty small and this isn't that hard. The only hard requirement for camping is to have a minifed core that fits in that little file. Because it's funny as hell. 


# Stack Goals:
Database:
	- Sqlite
	- Extralite
	- Sequel
View:
	- Phlex, Replace Mab with Phlex
Routing
	- Roda / Camping (We still might just use Roda underneath)
Server:
	- Tipi
	- Falcon
Jobs:
	- Custom job scheudling and operation class
Frontend:
	- LiveView or Turbo
	- Alpine or Stimulus
Asset pipeline:
	- Vite?
	- Maybe just rollup.js, which ironically is behind vite.
	
# Application Goals:
- Optionally allow your whole application to fit in a single file. So, Compact, yet clear syntax.
- Very sensible defaults.
- Simple and inspectible architecture.

	
# TABS vs Spaces
Tabs. For accessibility reasons.


## Some camping stuff
I'm rewriting Camping's core as I build this out, basically to match what we decide on.

A note on that: I thought that Camping might be mildly difficult to match some of Roda's succinct syntax for routing and filter type functions, but I was wrong. Camping can do it really well. 

Uninstall Camping then reinstall the local copy:

```
bundle exec gem uninstall camping
bundle update camping
```