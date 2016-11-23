var geoVizStarted;
var extractMap = null;
geoVizStarted = function() {
	if ($("#extract-annotation").length > 0) {
		var height = $("#extract-annotation").innerHeight() - $("#extract-content").height() - 155;
		var width = $("#extract-annotation").innerWidth() / 2 - 20;
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
	var group_entity = $("#extract-controls").find("div.group-entity").first();
	if ($(group_entity).hasClass("update")) {
		$.getScript("/documents/"+$("#extract-content").data("document-id")+"/placenames/geocode.js?entity_id="+$(group_entity).data("entity-id")+"&q="+$(this).val());
	} else {
		$.getScript("/documents/"+$("#extract-content").data("document-id")+"/placenames/geocode.js?q="+$(this).val());
	}
});

$(document).on("keypress", "form", function (e) {
    if (e.keyCode == 13) {
        return false;
    }
});

$(document).on("click", "div.word.annotated", function(e) {
	$.getScript("/documents/"+$("#extract-content").data("document-id")+"/entities/"+$(this).data("entity-id")+".js");
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
		setExtractControls($(this).data("json"));
	}
});

function addMarkerToMap(item) {
	var marker = newMapMarker(extractMap, item, "extract-map");
	google.maps.event.addListener(marker, 'dragend', function(e) {
		var lat = e.latLng.lat();
		var lng = e.latLng.lng();
		$("#extract-annotation").find("#latitude_content").first().val(lat);
		$("#extract-annotation").find("#longitude_content").first().val(lng);
		$.getScript("/documents/"+$("#extract-content").data("document-id")+"/placenames/geocode.js?lat="+lat+"&lng="+lng);
	});
	mapMarkers.push(marker);
	extractMap.setCenter(marker.getPosition());
}

function clearExtractControls() {
	$("#name_content").parent().find("a").first().remove();
	$("#extract-controls #latitude_content").val("");
	$("#extract-controls #longitude_content").val("");
	$("#extract-controls #name_content").val("");
	$("#extract-controls #country_content").val("");
	$("#extract-controls #population_content").val("");
	$("#extract-controls #gazetteer_content").val("");
	$("#extract-controls #gazref_content").val("");
	$("#extract-controls #type_content").val("");
}

function setExtractControls(data) {
	if (data["id"])
		$("#extract-controls #id_content").val(data["id"]);
	$("#extract-controls #latitude_content").val(data["lat"]);
	$("#extract-controls #longitude_content").val(data["lng"]);
	$("#extract-controls #name_content").val(data["toponymName"]);
	$("#extract-controls #country_content").val(data["countryCode"]);
	$("#extract-controls #population_content").val(data["population"]);
	$("#extract-controls #gazetteer_content").val("geonames");
	$("#extract-controls #gazref_content").val(data["geonameId"]);
	$("#extract-controls #type_content").val(data["fcode"]);
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
	clearMapMarkers();
	clearExtractControls();
	var placename = elementListToString(selectedElements);
	$("#"+parentId).parent().find(".edit_metadata_group #id_content").first().val(elementIdsToString(selectedElements));
	$("#"+parentId).parent().find(".edit_metadata_group #name_content").first().val(placename);
	$.getScript("/documents/"+$("#extract-content").data("document-id")+"/placenames/geocode.js?q="+placename);
}

function processAnnotationStart(parentId) {
	clearMapMarkers();
	clearExtractControls();
}

function resetMapBounds() {
	var bounds = new google.maps.LatLngBounds();
	bounds.extend(new google.maps.LatLng(47.0, 1.0));
	bounds.extend(new google.maps.LatLng(51.0, 10.0));
	extractMap.fitBounds(bounds);
}
