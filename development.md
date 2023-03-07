# Development list
- [x] Fix Autoloader and reloader to respect environment.
- [x] Work out Zeitwerk autoloading kinks.
- [ ] Eager Load the apps stuff. (Eager load controllers in order before building the routing tree thingy so that apps and their routes will be set up correctly.)

# to run the app in rerun mode:
run: `rerun bin/camping` to start the app in a hot reloadable fashion.

## Camping now uses Rerun for development. Or At least... YOU Do!
Camping's reloader isn't so bad, but in the interest of moving forward in a reloadable environment wihout rewriting the reloader yet, we decided to just not use the old reloader, and instead switch to using the rerun gem. It's simple, and that's all we need.