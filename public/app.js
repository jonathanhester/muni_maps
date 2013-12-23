function log(message) {
    if (console.log)
        console.log(message);
}

google.maps.event.addDomListener(window, 'load', function () {
    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function (position) {
            var GOOGLE_MAP_OPTIONS = {
                styles:[
                    {
                        featureType:"poi",
                        stylers:[
                            { visibility:"off" }
                        ]
                    }
                ]
            };

            // maybe we want to customize based on device, resolution, etc
            function getGoogleMapOptions() {
                return GOOGLE_MAP_OPTIONS;
            }

            var mapOptions = $.extend(getGoogleMapOptions(), {
                center:new google.maps.LatLng(position.coords.latitude, position.coords.longitude),
                zoom:17
            });
            var map = new google.maps.Map(document.getElementById("map-canvas"),
                mapOptions);

            var muniMap = new MuniMap(map, position.coords.latitude, position.coords.longitude);
            muniMap.loadPredictions(position.coords.latitude, position.coords.longitude, muniMap.draw);

            //may want to make this smarter, like it waits 1 second after the
            //drag before initiating the load. On mobile, it might be common
            // to do a bunch of little drags to get where you want
            google.maps.event.addListener(map, 'dragend', function () {
                var center = map.getBounds().getCenter();
                muniMap.loadPredictions(center.lat(), center.lng(), muniMap.draw);
            });

        }, function (positionError) {
            log("There was an error getting position.");
        });
    } else {
        log("Geolocation is not supported by this browser.");
    }
});

