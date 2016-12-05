$('#alternatives').modal("hide");
$('#annotate-fullscreen').modal("hide");

$(document).on('shown.bs.modal', '#annotate-fullscreen', function () {
	if ($("#extract-map-fullscreen").hasClass("new")) {
		google.maps.event.trigger(maps["extract-map-fullscreen"], 'resize');
		focusMap(maps["extract-map-fullscreen"], "extract-map-fullscreen");
		$("#extract-map-fullscreen").removeClass("new");
	}
});

$(document).on("click", "#new-marker", function(e) {
	e.preventDefault();
	if ($(this).hasClass("disabled")) {
		if ($(this).hasClass("new")) {
			alert("Please select one or more words in the text before dropping a marker.");
			$(this).removeClass("new");
		}
	} else {
		addMarkerToMap(maps["extract-map"], {
			"lat": 0.0,
			"lng": 0.0,
			"label": "Drag me",
			"letter": "D",
			"draggable": true,
			"color": "13986D",
			"infowindow": "<div>Drag me</div>"
		});
		addMarkerToMap(maps["extract-map-fullscreen"], {
			"lat": 0.0,
			"lng": 0.0,
			"label": "Drag me",
			"letter": "D",
			"draggable": true,
			"color": "13986D",
			"infowindow": "<div>Drag me</div>"
		});
	}
});

$(document).on("change", "#extract-controls #name_content", function(e) {
	var group_entity = $("#extract-controls").find("div.group-entity").first();
	if ($(group_entity).hasClass("update")) {
		$.getScript("/placenames/geocode.js?entity_id="+$(group_entity).data("entity-id")+"&q="+$(this).val());
	} else {
		$.getScript("/placenames/geocode.js?q="+$(this).val());
	}
});

$(document).on("keypress", "form", function (e) {
    if (e.keyCode == 13) {
        return false;
    }
});

$(document).on("click", "div.word.annotated", function(e) {
	$.getScript("/extracts/sources/"+$("#extract-content").data("source-document-id")+"/metadata_groups/"+$("#extract-content").data("metadata-group-id")+"/entity_mentions/"+$(this).data("entity-mention-id")+".js");
});

$(document).on("click", "tr.alternative", function(e) {
	var json = $(this).data("json");
	console.log(json);
	// Update fields in extract-controls
	setExtractControls(json);
	clearMarkersForGroup("extract-map", "New");
	clearMarkersForGroup("extract-map-fullscreen", "New");
	addMarkerToMap(json, "extract-map");
	addMarkerToMap(json, "extract-map-fullscreen");
	if (!$(this).hasClass("selected")) {
		// Move currently selected row to alternatives table
		var selected = $("#selected-body").find("tr").first().remove();
		$(selected).removeClass("selected");
		$("#alternatives-body").append(selected);
		// Move newly selected row from alternatives table to selected table
		var alternative = $(this).remove();
		$(alternative).addClass("selected");
		$("#selected-body").append(alternative);
	}
});

function addMarkerToMap(item, mapId) {
	var map = maps[mapId];
	var marker = newMapMarker(map, item, mapId);
	google.maps.event.addListener(marker, 'dragend', function(e) {
		var lat = e.latLng.lat();
		var lng = e.latLng.lng();
		$("#extract-controls").find("#latitude_content").first().val(lat);
		$("#extract-controls").find("#longitude_content").first().val(lng);
		var group_entity = $("#extract-controls").find("div.group-entity").first();
		if ($(group_entity).hasClass("update")) {
			$.getScript("/placenames/geocode.js?entity_id="+$(group_entity).data("entity-id")+"&lat="+lat+"&lng="+lng);
		} else {
			$.getScript("/placenames/geocode.js?lat="+lat+"&lng="+lng);
		}
	});
	mapMarkers[mapId].push(marker);
	map.setCenter(marker.getPosition());
}

function clearExtractControls(clearId) {
	$("#name_content").parent().find("a").first().remove();
	if (clearId)
		$("#extract-controls #id_content").val("");
	$("#extract-controls #latitude_content").val("");
	$("#extract-controls #longitude_content").val("");
	$("#extract-controls #name_content").val("");
	$("#extract-controls #country_content").val("");
	$("#extract-controls #population_content").val("");
	$("#extract-controls #gazetteer_content").val("");
	$("#extract-controls #gazref_content").val("");
	$("#extract-controls #type_content").val("");
}

function clearMarkersForGroup(mapId, group) {
	var keep = [];
	for (var i = 0; i < mapMarkers[mapId].length; i++) {
		var marker = mapMarkers[mapId][i];
		if (marker.title === group) {
			marker.setMap(null);
		} else {
			keep.push(marker);
		}
	}
	mapMarkers[mapId] = keep;
}

function loadInfowindowContent(mapId, item, infowindow) {
	$.ajax({
	    url: '/placenames/infowindow.json?lat='+item["lat"]+'&lng='+item["lng"],
	    context: $("#"+mapId),
	    success: function(data){
	    	infowindow.setContent(data["html"]);
	    }
	});
}

function setExtractControls(data) {
	if (data["id"])
		$("#extract-controls #id_content").val(data["id"]);
	$("#extract-controls #latitude_content").val(data["lat"]);
	$("#extract-controls #longitude_content").val(data["lng"]);
	$("#extract-controls #name_content").val(data["label"]);
	$("#extract-controls #country_content").val(data["country"]);
	$("#extract-controls #population_content").val(data["population"]);
	$("#extract-controls #gazetteer_content").val(data["gazetteer"]);
	$("#extract-controls #gazref_content").val(data["gazref"]);
	$("#extract-controls #type_content").val(data["type"]);
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
	addClassToSelected($("#"+parentId).data("label"), selectedElements, "selected-for-annotation");
	clearMapMarkers();
	clearExtractControls();
	var placename = elementListToString(selectedElements);
	$("[id=id_content]").val(elementIdsToString(selectedElements));
	$("[id=name_content]").val(placename);
	
	var group_entity = $("#extract-controls").find("div.group-entity").first();
	if ($(group_entity).hasClass("update")) {
		$.getScript("/placenames/geocode.js?entity_id="+$(group_entity).data("entity-id")+"&q="+placename);
	} else {
		$.getScript("/placenames/geocode.js?q="+placename);
	}
}

function processAnnotationStart(parentId) {
//	$("#new-marker").addClass("disabled");
//	clearExtractControls(true);
	$.getScript("/extracts/sources/"+$("#extract-content").data("source-document-id")+"/metadata_groups/"+$("#extract-content").data("metadata-group-id")+"/entity_mention");
}

function resetMapBounds(map) {
	var bounds = new google.maps.LatLngBounds();
	bounds.extend(new google.maps.LatLng(47.0, 1.0));
	bounds.extend(new google.maps.LatLng(51.0, 10.0));
	map.fitBounds(bounds);
}
