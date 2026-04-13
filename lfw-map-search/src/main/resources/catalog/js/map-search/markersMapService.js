(function () {
    goog.provide("lfw_markersmap_service");

    goog.require("gn_maps_manager");

    var module = angular.module("lfw_markersmap_service", [
        "gn_maps_manager"
    ]);

    module.factory('SearchMap', [
        "gnMapsManager",
        function(gnMapsManager) {
            class SearchMap {
                constructor(map = null) {
                    if (!map) {
                        map = gnMapsManager.createMap(gnMapsManager.SEARCH_MAP);
                    }

                    this.map = map;
                }
            }

            return SearchMap;
        }
    ]);

    module.service('markersMapService', [
        "gnMapsManager",
        "gnSearchSettings",
        "SearchMap",
        "$translate",
        function (gnMapsManager, gnSearchSettings, SearchMap, $translate) {

            this.bigMap = new SearchMap();
            this.miniMap = new SearchMap(gnSearchSettings.searchMap);
            
            this.bboxSource = new ol.source.Vector();

            this.bboxStyle = new ol.style.Style({
                stroke: new ol.style.Stroke({
                    color: "orange",
                    width: 2
                }),
                image: new ol.style.Circle({
                    radius: 4,
                    stroke: new ol.style.Stroke({
                        color: "darkcyan",
                        width: 2
                    })
                })
            });

            this.bboxLayer = new ol.layer.Vector({
                source: this.bboxSource,
                style: this.bboxStyle
            });

            /**
             * Elements that make up the popup.
             */
            this.popupElement = document.getElementById("popup");
            this.popupContentElement = document.getElementById("popup-content");
            this.popupCloserElement = document.getElementById("popup-closer");

            /**
             * Create an overlay to anchor the popup to the map.
             */
            this.overlay = new ol.Overlay({
                element: this.popupElement,
                autoPan: true,
                autoPanAnimation: {
                    duration: 200
                }
            });

            this.onPopupCloserClick = function () {
                this.overlay.setPosition(undefined);
            }
            this.popupCloserElement.addEventListener("click", () => this.onPopupCloserClick());

            this.map = gnMapsManager.createMap(gnMapsManager.SEARCH_MAP);

            this.onMapClick = function () {
                this.overlay.setPosition(undefined);
            }
            this.map.on("click", () => this.onMapClick());

            this.onMoveStart = function () {
                this.previousZoom = this.map.getView().getZoom();
            }
            this.map.on("movestart", () => this.onMoveStart());

            this.onMoveEnd = function (event) {
                this.currentZoom = this.map.getView().getZoom();
                // Check if the zoom level has decreased
                if (this.currentZoom != this.previousZoom) {
                    // Perform the desired action on map zoom-out
                    this.overlay.setPosition(undefined);
                }
            }
            this.map.on("moveend", () => this.onMoveEnd());

            this.onMarkerHover = function (feature, event) {
                var props = feature.getProperties();
                var metaData_uuid = props.resource.uuid;
                const coordinate = event.coordinate;
                const resource_type = props.resource.resourceType[0];
                const tooltip = $translate.instant(resource_type);
                this.popupContentElement.innerHTML = `
                    <table>
                        <tr>
                            <td class="popup-icon fa gn-icon-${props.resource.resourceType[0]}" title="${tooltip}"></td>
                            <td class="popup-title">${props.resource.resourceTitle}</td>
                        </tr>
                    </table>
                    <code class="metadata-ref">
                        <a 
                            href="catalog.search#/metadata/${metaData_uuid}" 
                            target="_blank"
                        >
                            View Record
                        </a>
                    </code>
                `;
                this.overlay.setPosition(coordinate);
            };   

            this.map.addLayer(this.bboxLayer);

            // MapSearch Marker Layers
            this.initMarkerLayer = function (config) {
                this.markerSource = new ol.source.Vector();
                this.markerStyle = new ol.style.Style({
                    image: new ol.style.Icon({
                        src: "../../catalog/views/default/images/marker.png",

                        // Anchor on bottom-center of the image
                        // (the 'tip' of the marker)
                        anchorOrigin: "bottom-left",
                        anchor: [0.5, 0],

                        scale: 0.75,
                        color: config.markers.color
                    })
                });

                this.clusterSource = new ol.source.Cluster({
                    distance: config.clusters.distance,
                    source: this.markerSource
                });

                this.clusterStyle = [
                    new ol.style.Style({
                        image: new ol.style.Circle({
                            radius: config.clusters.icon.outerRadius,
                            fill: new ol.style.Fill({
                                color: config.clusters.icon.outerColor
                            })
                        })
                    }),
                    new ol.style.Style({
                        image: new ol.style.Circle({
                            radius: config.clusters.icon.innerRadius,
                            fill: new ol.style.Fill({
                                color: config.clusters.icon.innerColor
                            })
                        }),
                        text: new ol.style.Text({
                            text: "",
                            fill: new ol.style.Fill({
                                color: config.clusters.icon.textColor
                            })
                        })
                    })
                ];

                this.markerLayerStyleFn = feature => {
                    if (feature.get("features").length > 1) {
                        var size = feature.get("features").length;
                        this.clusterStyle[1].getText().setText(size.toString());
                        return this.clusterStyle;
                    } else {
                        return this.markerStyle;
                    }
                };

                this.markerLayer = new ol.layer.Vector({
                    source: this.clusterSource,
                    style: feature => this.markerLayerStyleFn(feature)
                });
            };

            this.onMapPointerMove = (event) => {
                if(!this.markerLayer) {
                    return;
                }
                
                this.markerLayer.getFeatures(event.pixel).then((features) => {
                    var hoverFeature = features[0];
                    var hoverMarkerFeature =
                      hoverFeature && hoverFeature.get("features");
                    var checkMarker =
                      hoverMarkerFeature && hoverMarkerFeature[0].getProperties();
      
                    if (hoverFeature !== this.hoveredFeature) {
                      this.hoveredFeature = hoverFeature;
                      // Change the cursor style to indicate that the cluster or marker is clickable.
                      this.map.getTargetElement().style.cursor =
                        (hoverFeature && hoverFeature.get("features").length > 1) ||
                        (checkMarker && checkMarker.type === "marker")
                          ? "pointer"
                          : "";
                    }
                });
            };
            this.map.on("pointermove", (event) => this.onMapPointerMove(event));
        }
    ]);

})();