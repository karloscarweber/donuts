# mesoframework
Camping is a Micro-Framework. But we want it to be a *meso-framework*. Somewhere between a micro-framework and a macro-framework.
**Wait what? Why?**
Well The whole point of Camping is to have something Very simple that you can get spooled up in a single file if you really want to. But what happens if you want to make your simple thing more complicated with more capabilities? Well you would leave Camping behind, and move on to something else. That's not cool. So Camping remaining a Micro-Framework means it's just a toy framework, it can't do much and won't be used.

So how do we overcome this? Well We need to give Camping more capabilities, but we don't want make it so big to be difficult to comprehend. The solution is a middle of the road approach called a meso-framework. Not micro, not macro, meso.

The idea is to have a simple and easy to understand core to camping. The Micro. The framework part of the framework. Make this easy to extend, not only with Hooks, but also with Middleware, and a well understood plugin system. We call this Gear. Next is to provide well documented, understood, and simple **Gear** that we can mixin to our projects. We can provide all the essentials through the gear. Isolate the the development and testing of the gear, and package this great stuff along with Camping.

Finally, We build out larger pieces of functionality based on our Core (Micro), and our 1st party gear (meso), to build larger and more powerful plugins (Macro).

The goal is to see Camping as your first choice for a new project. Small enough to immediately understand. Powerful enough to get you from 0-1 with everything you need. Developed enought to give you everything you need to keep on scaling.

## Strategy:
1. A simple, well understood Camping Core. **Camping.rb**.
2. First Class Gear to give us everything we need.
3. Larger gear to add Large Swaths of functionality.
4. Everything is well documented and tested. Tutorials, Guides, and Docs with Beginners as the target audience.

