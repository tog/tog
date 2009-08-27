Edge
----
* Updated tog gem to require Desert 0.5.2 that fix some "Plugin schema migrations should successfully convert from the 'old' scheme to the 'new' scheme"" [Thanks Andrei!]

0.5.3
----

0.5.2
----

0.5.1
----

0.5.0
----

0.4.4
----

0.4.2
----
* #106 New "tog:plugins:db:version" task 
0.4.0
----
* Changed the list_specs based on files by one based on classes
* togify: Use github's tarballs instead of a git clone to a) remove git dependecy on togify and b) use a tagged release of tog plugins instead of the edge

0.3.0
----
* Rubigen dependency added to gemspec.

0.2.1
----
* [#89 status:resolved] From now tog:plugins:copy_resources don't copy .svn dirs to app's public directory...
* tog-desert dependency added.
* New `--development` flag on togify. This'll clone the tog core plugins from `git@github.com:tog/#{plugin}.git` instead of `git://github.com/tog/#{plugin}.git` allowing developers to change tog plugins inside a togified app.

0.2.0
-----
* Initial public code release