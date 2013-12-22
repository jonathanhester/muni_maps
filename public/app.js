(function() {
	var GOOGLE_MAP_OPTIONS = {

	};

	var map;
    var infowindow;
    var busStopMarkersCache = {};

	// maybe we want to customize based on device, resolution, etc
	function getGoogleMapOptions() {
		return GOOGLE_MAP_OPTIONS;
	}

	function log(message) {
		if (console.log)
			console.log(message);
	}

	function initialize() {
		if (navigator.geolocation) {
			navigator.geolocation.getCurrentPosition(function(position) {
				initMap(position);
				loadStations(position.coords.latitude, position.coords.longitude, function() {

				});
			}, function(positionError) {
				log("There was an error getting position.");
			});
		} else {
			log("Geolocation is not supported by this browser.");
		}

	}
	function initMap(position) {
		var lat = position.coords.latitude;
		var lng = position.coords.longitude;

		var mapOptions = $.extend(getGoogleMapOptions(), {
			center : new google.maps.LatLng(lat, lng),
			zoom : 18
		});
		map = new google.maps.Map(document.getElementById("map-canvas"),
				mapOptions);
        google.maps.event.addListener(map, 'dragend', function() {
            var center = map.getBounds().getCenter();
            loadStations(center.lat(), center.lng());
        });

		showCurrentLocation(position);

		function showCurrentLocation(position) {
			var myloc = new google.maps.Marker({
				position : new google.maps.LatLng(lat, lng),
				clickable : false,
				icon : new google.maps.MarkerImage(
						'//maps.gstatic.com/mapfiles/mobile/mobileimgs2.png',
						new google.maps.Size(22, 22), new google.maps.Point(0,
								18), new google.maps.Point(11, 11)),
				shadow : null,
				zIndex : 999,
				map : map
			});
			return myloc;
		}
	}

	function loadStations(lat, lng, callback) {
        var params = {lat: lat, lng: lng};
		$.getJSON("stops", params, function(stations) {
			NextBusApi.loadPredictions(stations, function(predictions) {
				$.each(stations, function(index, station) {
					drawStation(station, predictions[station.stopTag]);
				});
			});
		});

		function getStationWindowContent(station, predictions) {
            //removes occasional scrollbar on linux
            //http://www.canbike.ca/information-technology/2013/11/01/firefox-infowindow-scrollbar-fix-google-maps-api-v3.html
			var content = "<div style=\"line-height:1.35;overflow:hidden;white-space:nowrap;\"";
			content += station.title;
			content += "<br />";

			$.each(station.routes, function(i, route) {
				content += "<br />";
				var busPredictions = predictions[route.routeTag];
				if (busPredictions && busPredictions.predictions) {
					var estimates = gatherEstimates(busPredictions.predictions);
					content += "Route: " + busPredictions.routeTitle + "<br />";
					content += "Direction: " + busPredictions.direction + "<br />";
					content += "Arrivals: " + estimates + "<br />";
				}
			});
            content += "</div>";
			return content;
		}
		
		function gatherEstimates(estimates) {
			var estimateString = [];
			$.each(estimates, function(i, e) {
				if (e.minutes > 5)
					estimateString.push(e.minutes + "min");
				else
					estimateString.push(e.minutes + "min" + e.seconds % 60 + "sec");
			});
			return estimateString.join(",");
		}

		function drawStation(station, predictions) {
            if (!busStopMarkersCache[station.stopTag]) {
                busStopMarkersCache[station.stopTag] = new google.maps.Marker({
                    position : new google.maps.LatLng(station.lat, station.lng),
                    map : map
                });
            }
            var marker = busStopMarkersCache[station.stopTag];

            if (!infowindow)
                infowindow = new google.maps.InfoWindow();

            var content = getStationWindowContent(station, predictions);


			google.maps.event.addListener(marker, 'click', function() {
                infowindow.setContent(content);
				infowindow.open(map, marker);
			});

		}
	}

	var NextBusApi = {
		loadPredictions : function(stops, callback) {
			var url = "http://webservices.nextbus.com/service/publicXMLFeed";
			var stopsString = getStopsParam(stops);
			var params = {
				command : "predictionsForMultiStops",
				a : "sf-muni",
				stops : stopsString
			};
			$.ajax(url, {
				data : params,
				traditional : true,
				success : function(xml) {
					callback(parsePredictions(xml));
				}
			});

			function parsePredictions(xml) {
				var predictions = {};
				$(xml)
						.find("predictions")
						.each(
								function() {
									var routeTag = $(this).attr("routeTag");
									var stopTag = $(this).attr("stopTag");
									predictions[stopTag] = predictions[stopTag]
											|| {};
									predictions[stopTag][routeTag] = predictions[stopTag][routeTag]
											|| {};
									predictions[stopTag].stopTitle = $(this)
											.attr("stopTitle");
									predictions[stopTag][routeTag].routeTitle = $(
											this).attr("routeTitle");
									$(this)
											.find("direction")
											.each(
													function() {
														predictions[stopTag][routeTag].direction = $(
																this).attr(
																"title");
														predictions[stopTag][routeTag].predictions = [];
														$(this)
																.find(
																		"prediction")
																.each(
																		function() {
																			var prediction = {};
																			prediction.seconds = $(
																					this)
																					.attr(
																							"seconds");
																			prediction.minutes = $(
																					this)
																					.attr(
																							"minutes");
																			prediction.vehicle = $(
																					this)
																					.attr(
																							"vehicle");
																			predictions[stopTag][routeTag].predictions
																					.push(prediction);
																		});
													});
								});
				return predictions;
			}

			function getStopsParam(stops) {
				var stopsParam = [];
				$.each(stops, function(i, stop) {
					$.each(stop.routes, function(j, route) {
						stopsParam.push(route.routeTag + "|" + stop.stopTag);
					});
				});
				return stopsParam;
			}

		}
	};

	google.maps.event.addDomListener(window, 'load', initialize);
})();