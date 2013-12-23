Muni Maps
====================
Hosted at http://muni.jonathanhester.com

This is a quick implementation of a web app that uses NextBus's API
([Nextbus](http://www.nextbus.com/xmlFeedDocs/NextBusXMLFeed.pdf)) to display
predicted sf muni arrival times at nearby bus stops on a google map.
I wanted the least cumbersome way possible to lookup nearby arrival times.
It uses the browser's Geolocation capability to determine the initial location.

Motivation
---------------
This is to solve the use case where you are familiar with the surrounding bus
lines and just want to know the nearby arrival times.  I found the Android
([Muni+ App](http://muniapp.us/)) that
[SFMTA recommends](http://www.sfmta.com/getting-around/transit/mobile-apps) unsatisfactory.
The mobile version of [Nextbus](http://www.nextbus.com/) has the same idea but
it displays the predictions in a list rather than a map.  This normally works great
except when the browser inaccurately geolocates the user.  In that case, you have to keep
scrolling down until you find your routes.

Implementation
---------------
This really should be a native app to get the improved geolocation accuracy and Google Maps
performance.

The frontend is a fullscreen google map with javascript that
* geolocates the user(note this requires user to explicitly allow location permission),
* queries the backend to get a list of nearby stops with their corresponding bus routes
* queries Nextbus's API directly with all the route/stop combos
* displays Markers and InfoWindows for each bus stop

Whenever the user stops dragging the map, it will query with the new map center.
Future TODOs would be to add refresh functionality (or poll) and be smarter about
when and what data to load.  If the user is doing several drags to move the map
far, they likely don't care about the information being requested between each drag.
Also, if the user moves the map to a location that already has "up-to-date" data,
there's no need to request it again.  If data requests were costly, one cool solution
might be to internally countdown the predicted times and do less periodic refreshes
to re-sync the times.


Its dependencies include jQuery and Google Maps JS API

The backend is a Sinatra app responsible for returning nearby bus stops and all the routes
that use the stop.
This information probably won't change much so it shouldn't need to be updated too frequently.
It takes a couple minutes to refresh and while that could be optimized, you'd have to watch
out for Nextbus's API limits.


Testing
---------------
There are some basic tests for both the Javascript (QUnit) and the Ruby (Test::Unit).
The QUnit tests the basic parsing of data from the 2 JSON calls.  It could be extended
to cover more cases and the code that draws the markers and infowindows.

The QUnit tests can be seen at http://muni.jonathanhester.com/test.html


Jonathan Hester
http://lnkd.in/bDPdcGc