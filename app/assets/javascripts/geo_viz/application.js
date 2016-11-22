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
//= require_tree .
//= require annotations/application.js

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

	if ($("#alternatives .modal-dialog").length > 0) {
		$('#alternatives').modal('options');
		var body = $( 'show' );
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

$(document).on("change", "#extract-controls #name_content", function(e) {
	$.getScript("/placenames/geocode.js?q="+$(this).val()+"&target=extract-controls");
});

$(document).on("keypress", "form", function (e) {
    if (e.keyCode == 13) {
        return false;
    }
});

$(document).on("click", "tr.alternative", function(e) {
	if (!$(this).hasClass("selected")) {
		var json = $(this).data("json");
		// Move currently selected row to alternatives table
		var selected = $("#selected-body").find("tr").first().remove();
		$(selected).removeClass("selected");
		$("#alternatives-body").append(selected);
		// Move newly selected row from alternatives table to selected table
		var alternative = $(this).remove();
		$(alternative).addClass("selected");
		$("#selected-body").append(alternative);
		// Update fields in extract-controls
		var data = $(this).data("json");
		$("#extract-controls #latitude_content").val(data["lat"]);
		$("#extract-controls #longitude_content").val(data["lng"]);
		$("#extract-controls #name_content").val(data["toponymName"]);
		$("#extract-controls #country_content").val(data["countryCode"]);
		$("#extract-controls #population_content").val(data["population"]);
		$("#extract-controls #gazref_content").val(data["geonameId"]);
		$("#extract-controls #type_content").val(data["fcode"]);
	}
});

function addMarkerToMap(item) {
	var marker = newMapMarker(extractMap, item, "extract-map");
	google.maps.event.addListener(marker, 'dragend', function(e) {
		var lat = e.latLng.lat();
		var lng = e.latLng.lng();
		$("#extract-annotation").find("#latitude_content").first().val(lat);
		$("#extract-annotation").find("#longitude_content").first().val(lng);
		$.getScript("/placenames/geocode.js?lat="+lat+"&lng="+lng+"&target=extract-controls");
	});
	mapMarkers.push(marker);
	extractMap.setCenter(marker.getPosition());
}

function elementIdsToString(elements) {
	var arr = [];
	for (var i = 0; i < elements.length; i++) {
		arr.push($(elements[i]).attr("id"));
	}
	return arr.join(" ");
}

function elementListToString(elements) {
	var arr = [];
	for (var i = 0; i < elements.length; i++) {
		arr.push($(elements[i]).html());
	}
	return arr.join(" ");
}

function processAnnotationSelection(parentId, selectedElements) {
	addClassToSelected(parentId, selectedElements, "selected-for-annotation");
	var placename = elementListToString(selectedElements);
	$("#"+parentId).parent().find(".edit_metadata_group #id_content").first().val(elementIdsToString(selectedElements));
	$("#"+parentId).parent().find(".edit_metadata_group #name_content").first().val(placename);
	$.getScript("/placenames/geocode.js?q="+placename+"&target="+$("#"+parentId).parent().attr("id"));
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