Infiniverse Developer Readme
============================

This file serves as a starting point for new developers and
contains info about the different files and lists some coding
conventions and guidelines.

For compiling instructions, see Compiling.txt

Client Source
-------------

Code consists of the following files:

	infiniverse.bas		- Program entry point, main loop, input handling, UI
	game.bi				- Classes and things for representing game objects and stuff
	tiles.bi			- Classes and stuff tileengine uses
	tileengine.bas		- The core tile engine that handles the displaying of worlds
	keys.bas			- Player movement etc controls
	universe.bi			- Classes representing the universe and some static generators
	world.bas			- Real-time generators
	protocol.bi			- Stuff that is used in shared between client/server
	misc.bas			- Ugly macro hacks and some UI elements
	helps.bas			- Contains some help screens
	updater.bas			- A separate (but tightly integrated) updater app

Not in the source tree (within server):

	lobby.bas			- Connecting to server and joining/registering to the game
	networking.bas		- Client side networking logic and application protocol

Coding Style
------------

 * Write comments!
 * Intendation is one tab character, not spaces
 * Keywords are capitalized with CamelCase (e.g. OrElse, CInt; not orelse or CINT)
 * Class/type names and functions/subs with capitalized first letter and camel case
 * Variables and member functions with lower case first letter and camel case
 * Use compact, but clear coding
 * Parameter lists on one line if possible, but long ones may be divided to multiple lines
 * Code cross-platform
 	- targets Win32 and Linux
 	- e.g. no WinAPI, or if absolutely necessary, alternative for Linux must be provided
 	- use appropriate defines for platform dependant stuff
 * Avoid allocating memory (as it is easy to forget freeing)
 * Remember mutexes when using threads
 * Write comments!!!
 
 	
