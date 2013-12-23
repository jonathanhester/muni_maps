function log(message) {
    if (console.log)
        console.log(message);
}

google.maps.event.addDomListener(window, 'load', function () {
    var alreadyLoading = false;
    var SF_DEFAULT_LATITUDE = 37.7833;
    var SF_DEFAULT_LONGITUDE = -122.4167;

    function loadMuniMaps(lat, lng, zoom) {
        if (alreadyLoading)
            return;
        else
            alreadyLoading = true;

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
            center:new google.maps.LatLng(lat, lng),
            zoom:zoom
        });
        var map = new google.maps.Map(document.getElementById("map-canvas"),
            mapOptions);

        var muniMap = new MuniMap(map, lat, lng);
        muniMap.loadPredictions(lat, lng, muniMap.draw);

        //may want to make this smarter, like it waits 1 second after the
        //drag before initiating the load. On mobile, it might be common
        // to do a bunch of little drags to get where you want
        google.maps.event.addListener(map, 'dragend', function () {
            var center = map.getBounds().getCenter();
            muniMap.loadPredictions(center.lat(), center.lng(), muniMap.draw);
        });

    }

    function loadDefaultPosition() {
        loadMuniMaps(SF_DEFAULT_LATITUDE, SF_DEFAULT_LONGITUDE, 14);
    }

    if (navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function (position) {
            loadMuniMaps(position.coords.latitude, position.coords.longitude, 16);
        }, function (positionError) {
            log("There was an error getting position.");
            loadDefaultPosition();
        });
    } else {
        log("Geolocation is not supported by this browser.");
        loadDefaultPosition();
    }


    //give the browser 3 seconds to come up with a location for the user,
    //otherwise, just choose center of SF and zoom out a little bit
    //so they can easily find it themselves
    setTimeout(function() {
        loadDefaultPosition();
    },3000);


});

