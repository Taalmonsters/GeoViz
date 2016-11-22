// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or any plugin's vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require turbolinks
//= require_tree .

var geoVizStarted;
var extractMap = null;
geoVizStarted = function() {
	if ($("#extract-annotation").length > 0) {
		var height = $("#extract-annotation").innerHeight() - $("#extract-content").height() - 100;
		var width = $("#extract-annotation").innerWidth() / 2 - 20;
		$("#extract-map").height(height);
		$("#extract-controls").height(height);
		$("#extract-map").width(width);
		$("#extract-controls").width(width);
	}
};

$(document).ready(geoVizStarted);

$(document).on("click", "#new-marker", function(e) {
	e.preventDefault();
	clearMapMarkers();
	addMarkerToMap({
		"lat": 0.0,
		"lng": 0.0,
		"label": "Drag me",
		"letter": "D",
		"draggable": true,
		"color": "13986D",
		"infowindow": "<div>Drag me</div>"
	});
});

function addMarkerToMap(item) {
	var marker = newMapMarker(extractMap, item, "extract-map");
	google.maps.event.addListener(marker, 'dragend', function(e) {
		var lat = e.latLng.lat();
		var lng = e.latLng.lng();
		$("#extract-annotation").find("#latitude_content").first().val(lat);
		$("#extract-annotation").find("#longitude_content").first().val(lng);
		$.getScript("/placenames/geocode.js?latitude="+lat+"&longitude="+lng+"&target=extract-controls");
	});
	mapMarkers.push(marker);
	extractMap.setCenter(marker.getPosition());
}

function processAnnotationSelection(parentId, selectedElements) {
	addClassToSelected(parentId, selectedElements, "selected-for-annotation");
	var placename = elementListToString(selectedElements);
	$("#"+parentId).parent().find(".edit_metadata_group #id_content").first().val(elementIdsToString(selectedElements));
	$("#"+parentId).parent().find(".edit_metadata_group #name_content").first().val(placename);
	$.getScript("/placenames/geocode.js?query="+placename+"&target="+$("#"+parentId).parent().attr("id"));
}

function processAnnotationStart(parentId) {
	clearMapMarkers();
	$("#"+parentId).parent().find(".edit_metadata_group #id_content").first().val("");
	$("#"+parentId).parent().find(".edit_metadata_group #name_content").first().val("");
	$("#"+parentId).parent().find(".edit_metadata_group #latitude_content").first().val("");
	$("#"+parentId).parent().find(".edit_metadata_group #longitude_content").first().val("");
	$("#"+parentId).parent().find(".edit_metadata_group #population_content").first().val("");
	$("#"+parentId).parent().find(".edit_metadata_group #gazetteer_content").first().val("");
	$("#"+parentId).parent().find(".edit_metadata_group #gazref_content").first().val("");
	$("#"+parentId).parent().find(".edit_metadata_group #type_content").first().val("");
	$("#"+parentId).parent().find(".edit_metadata_group #country_content").first().val("");
}

function resetMapBounds() {
	var bounds = new google.maps.LatLngBounds();
	bounds.extend(new google.maps.LatLng(47.0, 1.0));
	bounds.extend(new google.maps.LatLng(51.0, 10.0));
	extractMap.fitBounds(bounds);
}