// Load the CycleStreets Journey Planner over a LeafletJS map.

// Load this script into an html page that has a leaflet map setup in the global variable window.map using this script tag near the end:
// <!-- Load CycleStreets journey planner -->
// <script src="http://www.cyclestreets.net/widgets/journeyplanner/journeyplanner.js"></script>

// Some ideas used in this file are based on Third party javascript book: http://thirdpartyjs.com/

/*jslint browser: true, devel: true, passfail: false, continue: true, eqeq: true, forin: true, nomen: true, plusplus: true, regexp: true, unparam: true, white: true */
/*global cyclestreetsNS, L, navigator, autocomplete, jQuery, $, map, osmLayer */ 

var CSjp = (function (window, undefined) {
    'use strict';

    // Create the global variable object
    var CSjp = {},

    // Configuration
    widgetServer = 'http://www.cyclestreets.net',
    tileServer = 'http://tile.cyclestreets.net/',
    cyclestreetsAPIserver = 'https://api.cyclestreets.net/v2/',
    cyclestreetsAPIkey = '73660e6f2b6ea0a6',
    preferedNameSearchBoundingBox = '-2.30983758690152,54.4998360406647,-3.24189445220635,54.0935416702061',	// N,E,S,W
    boundedSearch = '1',	// https://www.cyclestreets.net/api/v2/geocoder/
    defaultLatitude = 54.2966888554354,
    defaultLongitude = -2.77586601955394,
    defaultZoom = 10,
    appstoreLinkApple = false,
    appstoreLinkAndroid = false,

    // Set map bounds to UK and Ireland
    britishIslesBounds = [[49,-11],[61,2]], // SW, NE

    // Project name
    customName = 'Journey planner',

    // Cycle North Staffs uses these globals
    maxBoundsArea = window.maxBoundsArea || britishIslesBounds,
    fitBoundsArea = window.fitBoundsArea || false;

    // Check for development machine
// !! This stuff should somehow be part of configuration and not publicly visible
    if (/^http:\/\/cyclenorthstaffs\//.test(window.location.href)) {

	// Trace Paste
	console.log ('Using local widgets services');

	// Use local services
	widgetServer = 'http://localhost';
	tileServer = 'http://tile.localhost/';
	cyclestreetsAPIserver = 'https://api-fabian.cyclestreets.net/v2/';
	cyclestreetsAPIkey = 'bdcc8808c9de861c';
    }

    // function for loading a script, asynchronously
    function loadScript (url, callback) {

	// Declarations
	var script = document.createElement ('script'), entry;

	// This means the script can run as soon as it is loaded, rather than having to way for DOM ready.
	script.async = true;
	script.src = url;

	// Insert before the first script item - e.g. the one that triggered the loading of this script
	entry = document.getElementsByTagName ('script')[0];
	entry.parentNode.insertBefore (script, entry);

	// To determine when the script has been loaded, support two events
	// onload is the standard and onreadystatechange is for compatibility with IE8 and earlier
	script.onload = script.onreadystatechange = function () {

	    // Declarations
	    var rdyState = script.readyState;

	    // onreadystatechange fires every time the state of the loading script changes
	    // The complete and loaded states indicate the script has been loaded
	    if (!rdyState || /complete|loaded/.test (script.readyState)) {

		// Fire the callback
		callback ();

		// Detach handlers to avoid memory leaks in IE8
		script.onload = script.onreadystatechange = null;
	    }
	};
    }

    // Function for loading a stylesheet - whch are always asynchronous
    function loadStylesheet (url) {

	var link = document.createElement ('link'), entry;

	link.rel = 'stylesheet';
	link.type = 'text/css';
	link.href = url;

	entry = document.getElementsByTagName('script')[0];
	entry.parentNode.insertBefore (link, entry);
    }

    // Note that because the css references images this folder has to be copied to widget folder:
    // user@machine:/websites/www/content$ cp -pr js/jquery-ui-1.11.4.custom/css/images/ widget/
    // And similarly the jquery images:
    // user@machine:/websites/www/content$ cp images/jquery/ widget/images/ -R
    loadStylesheet (widgetServer + '/widgets/journeyplanner/jquery-ui-1.10.4.custom.css'); // !! Slightly modified - look for double exclaimation marks within.
    loadStylesheet (widgetServer + '/widgets/journeyplanner/style.css');

    /// Start nested loading of all the required components

    // jQuery
    // http://cdnjs.com/
    // Protocol relative url
    //loadScript ('//cdnjs.cloudflare.com/ajax/libs/jquery/1.11.1/jquery.min.js', function () {
    loadScript (widgetServer + '/js/jquery-1.11.1.min.js', function () {
    //loadScript (widgetServer + '/js/jQuery_cutdown.js', function () {

	// Namespace the library, Page 37
	// CSjp.$ = CSjp.jQuery = jQuery.noConflict (true);
	// var jQuery = window.jQuery.noConflict (true),  $ = jQuery;

	// jQueryUI - which depends on jQuery
	//loadScript ('//cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/jquery-ui.min.js', function () {
	loadScript (widgetServer + '/js/jquery-ui-1.11.4.custom/jquery-ui.min.js', function () {
	//loadScript (widgetServer + '/js/jQueryUi_cutdown.js', function () {

	    // Autocomplete
	    loadScript (widgetServer + '/js/autocomplete.js', function () {

		// CycleStreets
		loadScript (widgetServer + '/js/cyclestreets.js', function () {

		    // Initialise the cyclestreetsNS object
		    cyclestreetsNS.map = map; // Their map object global
		    cyclestreetsNS.setApiKey (cyclestreetsAPIkey);
		    cyclestreetsNS.setApiV2Url (cyclestreetsAPIserver);
		    cyclestreetsNS.setBaseUrl (widgetServer);
		    // cyclestreetsNS.setDebugMode (true);
		    cyclestreetsNS.setLocalTileHost (tileServer);

		    cyclestreetsNS.setGeocodingCountryCodes('gb');
		    cyclestreetsNS.setPreferedNameSearchBoundingBox(preferedNameSearchBoundingBox);
		    cyclestreetsNS.setBoundedSearch(boundedSearch);

		    // Load required map layers
		    cyclestreetsNS.initialize ({
    "mapnik": {
        "type": "OSM",
        "name": "OpenStreetMap default style",
        "tileHost": "http://tile.cyclestreets.net/mapnik/{z}/{x}/{y}.png",
        "options": {
            "attribution": "&copy; OpenStreetMap contributors, CC-BY-SA",
            "maxZoom": 19
        }
    },
    "osopendata": {
        "type": "OSM",
        "name": "OS Open Data",
        "tileHost": "http://tile.cyclestreets.net/osopendata/{z}/{x}/{y}.png",
        "options": {
            "attribution": "Contains Ordnance Survey data &copy; Crown copyright and database right 2010",
            "maxZoom": 19
        }
    }
		});

		    // Itinerary
		    loadScript (widgetServer + '/js/itinerary.js', function () {

			// Declarations
			var baselayers, html, journeyPlannerPanel, stopProp, planLI, jpOptionsUL, routeStyle;

			// Setup the itinerary markers
			cyclestreetsNS.itinerary.setItineraryMarkers('/images/itinerarymarkers/', {
    "start": {
        "iconUrl": "start-large.png",
        "className": "waypointicon",
        "iconSize": [22,43],
        "iconAnchor": [11,43],
        "shadowUrl": "shadow-large.png",
        "shadowSize": [50,45],
        "shadowAnchor": [13,43]
    },
    "waypoint": {
        "iconUrl": "waypoint-large.png",
        "className": "waypointicon",
        "iconSize": [22,43],
        "iconAnchor": [11,43],
        "shadowUrl": "shadow-large.png",
        "shadowSize": [50,45],
        "shadowAnchor": [13,43]
    },
    "finish": {
        "iconUrl": "finish-large.png",
        "className": "waypointicon",
        "iconSize": [22,43],
        "iconAnchor": [11,43],
        "shadowUrl": "shadow-large.png",
        "shadowSize": [50,45],
        "shadowAnchor": [13,43]
    },
    "temporary": {
        "iconUrl": "temporary-large.png",
        "className": "waypointicon",
        "iconSize": [22,43],
        "iconAnchor": [11,43],
        "shadowUrl": "shadow-large.png",
        "shadowSize": [50,45],
        "shadowAnchor": [13,43]
    },
    "selected": {
        "iconUrl": "selected-large.png",
        "className": "waypointicon",
        "iconSize": [22,43],
        "iconAnchor": [11,43],
        "shadowUrl": "shadow-large.png",
        "shadowSize": [50,45],
        "shadowAnchor": [13,43]
    }
			});


			// Add CycleStreets to map attribution
			cyclestreetsNS.map.attributionControl.addAttribution ('Journey planner by <a href="http://www.cyclestreets.net/" title="Journey planner and photomap">CycleStreets</a>');

			// Location near Cycle North Staffs
			cyclestreetsNS.itinerary.setLongitude (defaultLongitude);
			cyclestreetsNS.itinerary.setLatitude (defaultLatitude);
			cyclestreetsNS.itinerary.setZoom (defaultZoom);

			// Modify the route style
			routeStyle = cyclestreetsNS.itinerary.getRouteStyle();
			routeStyle.weight = 12; // Use same values as Cycle North Staffs
			routeStyle.opacity = 0.7; // Use same values as Cycle North Staffs
			cyclestreetsNS.itinerary.setRouteStyle(routeStyle);

			// Config
			cyclestreetsNS.itinerary.setDraggableMarkers (true);
			cyclestreetsNS.itinerary.setCrowFlyParameters (9, 300000);
			cyclestreetsNS.itinerary.setSpeedkmph (20);
			cyclestreetsNS.itinerary.setSpeedPromptText ('');
			cyclestreetsNS.itinerary.setSpeedOptions ({'16': 'Speed 10mph (16km/h)',
			       '20': 'Speed 12mph (20km/h)',
			       '24': 'Speed 15mph (24km/h)'});
			cyclestreetsNS.itinerary.setMaxWaypoints (2);
			cyclestreetsNS.itinerary.setInitialWaypoints ([false,false]);

			cyclestreetsNS.itinerary.setClickRouting ('balanced');
			cyclestreetsNS.itinerary.setExperimentalStyling (true);
			cyclestreetsNS.itinerary.setArchive ('full'); // Full archiving is needed to generate the elevation profile
			cyclestreetsNS.itinerary.setDesiredFields ('id,path,start,finish,length,time,plan,streets,walk,timeFormatted,lengthMileage,calories,grammesCO2saved,turn,name,distance');
			cyclestreetsNS.itinerary.initialize ();

			// Get base layers
			baselayers = cyclestreetsNS.createBaseLayers ();

			// Add the Cycle North Staffs baselayer from their global
			if (window.osmLayer) {baselayers[customName] = osmLayer;}
			// Add the layer switcher
//			cyclestreetsNS.layerSwitcher = L.control.layers(baselayers, {}).addTo(cyclestreetsNS.map);
			
			// Define appstore links
			if (appstoreLinkApple || appstoreLinkAndroid) {
				var appstoreHtml;
				appstoreHtml  = '<p>';
				if (appstoreLinkApple) {
					appstoreHtml += '<a href="' + appstoreLinkApple + '"><img class="ios" src="http://www.cyclestreets.net/images/mobile/appstore.png" /></a>';
				}
				if (appstoreLinkAndroid) {
					appstoreHtml += '<a href="' + appstoreLinkAndroid + '"><img class="android" src="http://www.cyclestreets.net/images/mobile/google-play.png" /></a>';
				}
				appstoreHtml += '</p>';
				var appstorePanel = L.control({position: 'topright'});
				appstorePanel.onAdd = function(map) {
				    var div = L.DomUtil.create('div', 'appstorePanel');
				    div.innerHTML = appstoreHtml;
				    div.id = 'appstorePanel';
				    return div;
				};
				appstorePanel.addTo(map);
			}
			
			// Define journey planner panel
			html = '<h3></h3>' + // Journey planner
			    '<div id="journeyPlannerPanel">' +
			    '<input id="hideJourneyPlannerPanel" type="button" value="Hide">' +
			    '<input id="plannewroute" type="button" value="Clear">' +
			    '<input id="swapwaypoints" type="button" value="Swap">' +
			    '<h1>Journey planner</h1>' +
			    '<form id="placeFindingPanel" method="post" action="" enctype="application/x-www-form-urlencoded" accept-charset="UTF-8"></form><!-- #placeFindingPanel  -->' +
			    '<div id="itineraryListing"></div>' +
				'</div>';

			// Add the panel to the top left of the map
			journeyPlannerPanel = L.control({position: 'topleft'});
			journeyPlannerPanel.onAdd = function(map) {
			    var div = L.DomUtil.create('div', 'journeyPlannerPanel');
			    div.innerHTML = html;
			    div.id = 'jp';
			    return div;
			};
			journeyPlannerPanel.addTo(map);

			// Make the journey planner section collapsible
			$('#jp').accordion({
			    header: "h3",
			    collapsible: true
			});

			$('#hideJourneyPlannerPanel').click(function() {
			    $('#jp').accordion('option', 'active', false);
			});


			// Planning panel
			cyclestreetsNS.itinerary.setupPlanningPanel ();

                        // Add click handler to new button
			$('#plannewroute')
			    .click(function(){

				// Reset the itinerary
				cyclestreetsNS.itinerary.reset();

				// Hide the buttons
				$('#plannewroute').hide();
				$('#swapwaypoints').hide();
			    });

			// Hide the button
                        $('#plannewroute').hide();

                        // Add click handler to swap button
			$('#swapwaypoints')
			    .click(function(){

				// Reset the itinerary
				cyclestreetsNS.itinerary.swapwaypoints();
			    });

			// Hide the button
                        $('#swapwaypoints').hide();

			// Redefine the default ajax fn
			cyclestreetsNS.itinerary.ajaxJourneySuccess = function (data)
			{
			    // Declarations
			    var routeSummary, listHtml, i, feature, arrow, arrowBase = widgetServer + '/images/icons/turnArrows/turn_', street, modeIcon, limit, planFeature = false, itineraryId;

			    // Erase any old route and display the new route
			    cyclestreetsNS.itinerary.redisplayNewRoute (data);

			    // Limit for searching features
			    limit = data.features.length;

			    // Find the first planned route summary
			    for (i = 0; i < limit; i += 1) {

				// Bind
				feature = data.features[i];

				// Skip if no path
				if (!feature.properties || !feature.properties.path) {continue;}

				// Look for a match
				if (/^plan\/(quietest|balanced|fastest)$/g.test(feature.properties.path)) {planFeature = feature;break;}
			    }

			    // Abandon if not found
			    if (!planFeature) {return;}
			    
			    // Bind
			    routeSummary = planFeature.properties;
			    itineraryId = data.properties.id;

			    // Start some html
			    listHtml  = '<p class="routesummary">';
			    listHtml += routeSummary.timeFormatted + ', ' + routeSummary.lengthMileage + '<br />';
			    listHtml += routeSummary.calories + ' calories' + '<br />';
			    listHtml += routeSummary.grammesCO2saved + 'g CO<sub>2</sub> saved';
			    listHtml += '</p>';

// 			    listHtml += '<h2>Route #' + itineraryId + ' detail</h2>';
				
			    // Link to print the pdf
			    listHtml += '<p class="print"><a href="' + widgetServer + '/journey/' + itineraryId + '/' + routeSummary.plan + '/print.pdf"><img src="' + widgetServer + '/images/fileicons/acrobat.gif" alt="PDF" /> Print</a></p>';

			    // Start the street listing
			    listHtml += '<table class="streets">';
				
				// Headings
				listHtml += '<tr>';
				listHtml += '<th></th>';
				listHtml += '<th></th>';
				// listHtml += '<th>Time</th>';
				listHtml += '<th>Distance</th>';
				listHtml += '<th>Section</th>';
				listHtml += '</tr>';
				
			    // Limit
			    limit = data.features.length;

			    // Add route details
			    for (i = 0; i < limit; i += 1) {

				// Bind the feature
				feature = data.features[i];

				// If not worthy skip
				if (!feature ||
				    !feature.properties ||
				    !feature.properties.path ||
				    !/^plan\/(quietest|balanced|fastest)\/street\/\d+$/g.test(feature.properties.path)
				   ) {continue;}

				// Useful binding
				street = feature.properties;

				// Determine the turn arrow
				switch (street.turn) {
				    // Arrows are available at multiples of 18 degrees
				case 'straight on':	arrow = arrowBase + '000_to_000';break;
				case 'bear right':	arrow = arrowBase + '000_to_054';break;
				case 'turn right':	arrow = arrowBase + '000_to_090';break;
				case 'sharp right':	arrow = arrowBase + '000_to_126';break;
				case 'double back':	arrow = arrowBase + '000_to_180';break;
				case 'sharp left':	arrow = arrowBase + '000_to_234';break;
				case 'turn left':	arrow = arrowBase + '000_to_270';break;
				case 'bear left':	arrow = arrowBase + '000_to_306';break;

				    // Use a spacer for other turns
				default: arrow = widgetServer + '/images/icons/spacer';
				}

				// Walking or cycling icon
				modeIcon =  widgetServer + '/images/icons/extras/' + (street.walk ? 'footprints' : 'bike_black');

					// Add to the list
					listHtml += '<tr>';
					listHtml += '<td><img src="' + arrow + '.png" title="' + street.turn + '" alt="' + street.turn + ' arrow"/></td>';
					listHtml += '<td><img src="' + modeIcon + '.png" title="' + (street.walk ? 'walking' : 'cycling') + '" alt="' + (street.walk ? 'walking' : 'cyclling') + ' icon"/></td>';
					// listHtml += '<td class="duration">' + street.durationFormatted + '</td>';
					listHtml += '<td class="distance">' + street.distance + 'm</td>';
					listHtml += '<td>' + street.name + '</td>';
					listHtml += '</tr>';
				}
				listHtml += '</table>';

				// Elevation profile
				listHtml += '<h2>Elevation profile</h2>';
			    listHtml += '<img src="' + widgetServer + '/journey/' + itineraryId + '/elevation' + itineraryId + routeSummary.plan + '240x100.png" width="240" height="100" alt="Elevation profile: shows hills on your route" />';

			    // Insert the html
			    $('#itineraryListing').html(listHtml);

                            // Show the new and swap buttons
                            $('#plannewroute').show();
                            $('#swapwaypoints').show();
			};

			// Base layer change
			cyclestreetsNS.map.on ('baselayerchange', function (layer) {

			    // Custom area
			    var customArea = layer.name === customName;

			    // Restrict bounds
			    cyclestreetsNS.map.setMaxBounds (customArea ? maxBoundsArea : britishIslesBounds);

			    // Move to custom area
			    if (customArea && fitBoundsArea) {cyclestreetsNS.map.fitBounds (fitBoundsArea);}
			});

			// Stop propagation bubbling up for click, double-click and mousedown (which may start a drag) events on other control panes - useful for when the box is over the map
			stopProp = function (event) {event.stopPropagation();};
			$('.leaflet-control-container').click     (stopProp);
			$('.leaflet-control-container').dblclick  (stopProp);
			$('.leaflet-control-container').mousedown (stopProp);

			// Journey planner options list
			jpOptionsUL = $('#jpOptions ul').first();

			// It seems that 'class' should be quoted when used as a key - if not it gives errors in IE7
			planLI = $('<li>', {id: 'planLI', 'class': 'untouched', text: ''});

			// Create the select and add to the list item
			cyclestreetsNS.itinerary.createSelect({id: 'plan',
							       name: 'plan',
							       onclick: '$("#planLI").attr("class", "touched");'},
							      {'quietest': 'Quietest route',
							       'balanced': 'Balanced route',
							       'fastest': 'Fastest route'},
							      cyclestreetsNS.itinerary.getClickRouting())
			    .appendTo(planLI)
			    .change(function (x) {
				cyclestreetsNS.itinerary.setClickRouting($("#plan").val());
				cyclestreetsNS.itinerary.mayPlanRoute();
			    });

			// Add to the list
			planLI.appendTo(jpOptionsUL);

		    }); // End of loading js/itinerary.js
		}); // /cyclestreets
	    }); // /autocomplete 
	}); // /jqueryui
    }); // /jquery

    // Trace
    // console.log ('CSjp widget loaded');

    // Result
    return CSjp;

} (window));

// End of file
