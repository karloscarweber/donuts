# Autoloading
We're gona use Zeitwerk Autoloading to get some magic to work. But we also want to load in a particular order, and load things in an environmental context. So how do we do that.

1. We set up autoloading for each App, namespaceing it to their app directory.
2. We load all of the lib folder, we just load it.
3. We then load all of the app directories in order.

Why do we add autoloading first if we're gonna just preload everything? Yeah good question. It's so that when we preload all of our code, and our code is referencing other parts of our application, the autoloader will grab that part and the preloading won't collapse.