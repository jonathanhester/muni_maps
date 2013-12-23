Muni Maps
====================
Hosted at http://muni.jonathanhester.com

This is a quick implementation of a web app that uses
([NextBus's API](http://www.nextbus.com/xmlFeedDocs/NextBusXMLFeed.pdf)) to display
predicted SF Muni arrival times at nearby bus stops on a google map.
I wanted the least cumbersome way to lookup nearby arrival times.
It uses the browser's Geolocation capability to determine the initial location. If
the browser doesn't return a location within 3 seconds, it defaults to the center
of San Francisco.

Motivation
---------------
This is to solve the use case where you are familiar with the surrounding bus
lines and just want to know their arrival times.  I found the Android
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

### Front-end

The frontend is a fullscreen google map with javascript that

1. geolocates the user (note this requires user to explicitly allow location permission),
2. queries the backend to get a list of nearby stops with their corresponding bus routes
3. queries Nextbus's API directly with all the route/stop combos from #2
4. displays Markers and InfoWindows for each bus stop

Whenever the user stops dragging the map, it will query with the new map center.
A future TODO would be to add refresh functionality (or poll) and be smarter about
when and what data to load.  If the user is doing several drags to move the map
far, they likely don't care about the information being requested between each drag.
Also, if the user moves the map to a location that already has "up-to-date" data,
there's no need to request it again.  If data requests were costly, one cool solution
might be to internally countdown the predicted times and do less periodic refreshes
to re-sync the times.


Its dependencies include jQuery and Google Maps JS API


### Back-end

The backend is a Sinatra app responsible for returning nearby bus stops and all the routes
that use the stop.  This was my first Sinatra app but I found it fitting given the simplicity
of the server's responsibilities.  It uses 2 Nextbus API endpoints to load the data into 4 models.

Besides the query it needs to serve, it also has a function that refreshes all the data.
Given that bus routes/stops shouldn't change much, it shouldn't need to be updated too frequently.
This function should be wrapped in a script and added as a cron job.
It takes a couple minutes to refresh and while that could be optimized, you'd have to watch
out for Nextbus's API limits.


Testing
---------------
There are some basic tests for both the Javascript (QUnit) and the Ruby (Test::Unit).
The QUnit tests the basic parsing of data from the 2 JSON calls.  It could be extended
to cover more cases and the code that draws the markers and infowindows.

The QUnit tests can be seen at http://muni.jonathanhester.com/test.html


Author
---------------
Jonathan Hester
http://lnkd.in/bDPdcGc