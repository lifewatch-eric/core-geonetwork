(function () {
  goog.provide("lfw_mapsearch_controller");

  goog.require("lfw_markersmap_directive");
  goog.require("lfw_map_search_settings");
  goog.require("lfw_markersmap_service");
  goog.require("lfw_filters_configuration_service");
  goog.require("lfw_facet_directive");

  var module = angular.module("lfw_mapsearch_controller", [
    "lfw_markersmap_directive",
    "lfw_map_search_settings",
    "lfw_markersmap_service",
    "lfw_filters_configuration_service",
    "lfw_facet_directive"
  ]);

  module.controller("LfwMapSearchController", [
    "$scope",
    "$http",
    "gnSearchSettings",
    "mapSearchSettings",
    "gnSearchLocation",
    "markersMapService",
    "gnGlobalSettings",
    "gnESFacet",
    "$location",
    function (
      $scope,
      $http,
      gnSearchSettings,
      MapSearchSettings,
      gnSearchLocation,
      MarkersMap,
      gnGlobalSettings,
      gnESFacet,
      $location
    ) {

      const baseSearchParams = {
        from: 1,
        to: 50,
        isTemplate: "n",
        languageStrategy: "searchInAllLanguages",
        sortBy: "relevance",
        sortOrder: ""
      };

      const templateQuery = {
        query_string: {
          query: "+isTemplate:n"
        }
      };

      const defaultPolygonCoordinates = [
        [-180, 90],
        [180, 90],
        [180, -90],
        [-180, -90],
        [-180, 90]
      ];

      $scope.aggregations = [];

      $scope.dropdownsConfig = {};
      try {
        if($location.path().indexOf("/preview") != -1) {
          // Custom preview configuration from configurator
          $scope.dropdownsConfig = gnESFacet.cleanConfigurationObject(
            gnGlobalSettings.gnCfg.lfw_search.previews.map
          );
          // Disable any mouse events on the preview page, except the filters
          for(const element of document.getElementsByTagName("body")) {
            element.style.pointerEvents = "none";
          }
          for(const element of document.getElementsByClassName("map-search-field")) {
            element.style.pointerEvents = "auto";
          }
        } else {
          // Custom configuration from configurator
          $scope.dropdownsConfig = gnESFacet.cleanConfigurationObject(
            gnGlobalSettings.gnCfg.lfw_search.views.map
          );
        }
      } catch(_) {
        // Default GeoNetwork facets configuration
        $scope.dropdownsConfig = gnGlobalSettings.gnCfg.mods.search.facetConfig;
      }

      // Add size to dropdownsConfig
      for(const filterKey in $scope.dropdownsConfig) {
        const filter = $scope.dropdownsConfig[filterKey];
        if(!filter.aggs) {
          continue;
        }

        for(const aggKey in filter.aggs) {
          const agg = filter.aggs[aggKey];
          if(agg.terms) {
            agg.terms['size'] = 1000;
          }
        }
      }

      // Formatter used to parse GeoJSON data from ES records
      $scope.geoJSONFormatter = new ol.format.GeoJSON({
        dataProjection: "EPSG:4326",
        featureProjection: "EPSG:3857"
      });

      const getAggregationByKey = function(key) {
        if(!$scope.aggregations) {
          return null;
        }

        for(const agg of $scope.aggregations) {
          if(agg.key == key) {
            return agg;
          }
        }
        
        return null;
      }

      const getAggregationItemByValue = function(agg, value) {
        if(!agg || !agg.items) {
          return null;
        }

        for(const item of agg.items) {
          if(item.value == value) {
            return item;
          }
        }
        
        return null;
      }
      
      function getESQueryForAppliedFilter(filterKey) {
        const filterValue = $scope.currentFilters[filterKey];
        if(!filterValue) {
          return null;
        }

        const aggregation = getAggregationByKey(filterKey);
        if(!aggregation) {
          return null; 
        }

        const aggregationItem = getAggregationItemByValue(aggregation, filterValue);
        if(!aggregationItem) {
          return;
        }

        const query = aggregationItem.valueQuery
          ? aggregationItem.valueQuery
          : `${aggregationItem.path[0]}:"${aggregationItem.path[1]}"`;

        return {
          query_string: {
            query: query
          }
        };
      }

      $scope.loadFilters = function() {
        const geoFilter = {
          geo_shape: {
            geom: {
              shape: {
                type: "polygon",
                coordinates: [defaultPolygonCoordinates]
              },
              relation: "within"
            }
          }
        };

        const endpoint = "../api/search/records/_search";
        const reqBody = {
          aggregations: $scope.dropdownsConfig,
          query: {
            bool: {
              must: [
                templateQuery,
                geoFilter
              ]
            }
          },
          from: 0,
          size: 0
        };

        for(key in $scope.currentFilters) {
          const query_string = getESQueryForAppliedFilter(key);

          if(query_string) {
            reqBody.query.bool.must.push(query_string);
          }
        }

        $http.post(endpoint, reqBody).then(function (r) {
          requestAggs = r.config.data.aggregations;
          responseAggs = r.data.aggregations;
          configurationId = 'map';
          $scope.aggregations = gnESFacet.createFacetModel(
            requestAggs, responseAggs, undefined, undefined, configurationId
          );
        });
      }

      // Dropdown filters values
      $scope.currentFilters = {};
      $scope.previousZoom;
      $scope.currentZoom;
      $scope.searching = false;
      //defaultDropdowns = gnGlobalSettings.gnCfg.mods.search.facetConfig;
      $scope.searchObj.configId = $scope.searchObj.configId || "search";
      $scope.searchParams={}
      var init = function () {
        // The map must be created immediatly, then we can wait for the
        // configuration to load and setup the rest

        MapSearchSettings.getConfig().then((config) => {
          $scope.searchMap = gnSearchSettings.searchMap;
          // MapSearch Marker Layers
          MarkersMap.initMarkerLayer(config);
          // Mini Map Marker Layers
          initMiniMapMarkerLayer(config);

          $scope.searchMap.addLayer($scope.MiniMapMarkerLayer);

          MarkersMap.map.addLayer(MarkersMap.markerLayer);

          MarkersMap.map.addOverlay(MarkersMap.overlay);
          // Listen for 'searchFinished' event and update/redraw markers
          // on map after a new search
          $scope.$on("searchFinished", function (_event, data) {
            $scope.searching = true;
            $scope.searchResults = data.searchResults;
            addSearchResultsToMap();

            // Due to the asynchronous nature of this initialization and the
            // search controller initialization, it is possible that the 
            // search controller makes the last search. This would result in
            // incongruous results on the map page.
            //
            // Detect if we are in the map search view and the search event 
            // did not contain a geometry filter (i.e. it was not made by this
            // controller). In this case, trigger a new search to get the
            // correct map view results.
            if(gnSearchLocation.isMap() && !data.searchParams.geometry) {
              $scope.loadFilters();
              triggerSearch();
            }
            
          });

          MarkersMap.map.on("click", function (event) {
            MarkersMap.markerLayer.getFeatures(event.pixel).then((features) => {
              if (features.length > 0) {
                $scope.clusterMembers = features[0].get("features");

                if ($scope.clusterMembers.length > 1) {
                  // Calculate the extent of the cluster members.
                  const extent = ol.extent.createEmpty();
                  $scope.clusterMembers.forEach((feature) =>
                    ol.extent.extend(extent, feature.getGeometry().getExtent())
                  );
                  const view = MarkersMap.map.getView();
                  // Zoom to the extent of the cluster members.
                  view.fit(extent, {
                    duration: 500,
                    padding: [50, 50, 50, 50]
                  });
                } else {
                  if ($scope.clusterMembers[0].values_.type == "marker") {
                    MarkersMap.onMarkerHover($scope.clusterMembers[0], event);
                  }
                }
              }
            });
          });

           // Mini Map functionality
          $scope.searchMap.on("pointermove", (event) => {
            $scope.MiniMapMarkerLayer.getFeatures(event.pixel).then(
              (features) => {
                var hoverFeature = features[0];
                var hoverMarkerFeature =
                  hoverFeature && hoverFeature.get("features");
                var checkMarker =
                  hoverMarkerFeature && hoverMarkerFeature[0].getProperties();

                if (hoverFeature !== $scope.hoveredFeature) {
                  $scope.hoveredFeature = hoverFeature;
                  /*
                Change the cursor style to indicate that the cluster or marker is clickable.
                use this if want to show cursor on marker on miniMap
                (checkMarker && checkMarker.type === "marker") 
                */
                  $scope.searchMap.getTargetElement().style.cursor =
                    hoverFeature && hoverFeature.get("features").length > 1
                      ? "pointer"
                      : "";
                }
              }
            );
          });

          $scope.searchMap.on("click", function (event) {
            $scope.MiniMapMarkerLayer.getFeatures(event.pixel).then(
              (features) => {
                if (features.length > 0) {
                  $scope.clusterMembers = features[0].get("features");
                  if ($scope.clusterMembers.length > 1) {
                    // Calculate the extent of the cluster members.
                    const extent = ol.extent.createEmpty();
                    $scope.clusterMembers.forEach((feature) =>
                      ol.extent.extend(
                        extent,
                        feature.getGeometry().getExtent()
                      )
                    );
                    const view = $scope.searchMap.getView();
                    const resolution = $scope.searchMap
                      .getView()
                      .getResolution();
                    // Zoom to the extent of the cluster members.
                    view.fit(extent, {
                      duration: 500,
                      padding: [50, 50, 50, 50]
                    });
                  }
                  // uncomment below lines to show pop-up on mini map
                  // else {
                  //   if ($scope.clusterMembers[0].values_.type == "marker") {
                  //     MarkersMap.onMarkerHover($scope.clusterMembers[0], event);
                  //   }
                  // }
                }
              }
            );
          });
          //------- Mini Map functionality end here-------

          // After inizialization, trigger a new empty search
          // only if the current page is the map search page
          if (gnSearchLocation.isMap()) {
            $scope.loadFilters();
            triggerSearch();
          }
        });
      };

      // Mini Map Marker Layers
      var initMiniMapMarkerLayer = function (config) {
        $scope.miniMapMarkerSource = new ol.source.Vector();

        $scope.miniClusterSource = new ol.source.Cluster({
          distance: config.clusters.distance,
          source: $scope.miniMapMarkerSource});

        $scope.MiniMapMarkerLayer = new ol.layer.Vector({
          source: $scope.miniClusterSource,
          style: function (feature) {
            if (feature.get("features").length > 1) {
              var size = feature.get("features").length;
              MarkersMap.clusterStyle[1].getText().setText(size.toString());
              return MarkersMap.clusterStyle;
            } else {
              return MarkersMap.markerStyle;
            }
          }
        });
      };

      var addSearchResultsToMap = function () {
        MarkersMap.bboxSource.clear();
        MarkersMap.markerSource.clear();
        $scope.miniMapMarkerSource.clear();
        MarkersMap.overlay.setPosition(undefined);
        angular.forEach($scope.searchResults.records, function (md) {
          if (!md.geom) {
            return;
          }

          angular.forEach(md.geom, function (geom) {
            addRecordGeometryToMap(geom, md);
          });
        });
      };

      var addRecordGeometryToMap = function (geom, md) {
        var feature = $scope.geoJSONFormatter.readFeature(geom);
        feature.setProperties({
          type: "bbox",
          resource: md
        });

        var centroid = ol.extent.getCenter(feature.getGeometry().getExtent());
        var centroidFeature = new ol.Feature({
          geometry: new ol.geom.Point(centroid)});
        centroidFeature.setProperties({
          type: "marker",
          resource: md
        });

        // MarkersMap.bboxSource.addFeature(feature);
        MarkersMap.markerSource.addFeature(centroidFeature);

        $scope.miniMapMarkerSource.addFeature(centroidFeature);
      };
      
      $scope.onResourceTypeChanged = function () {
        $scope.loadFilters();

        triggerSearch();
      };

      const triggerSearch = function() {
        $scope.searchParams = angular.copy($scope.searchObj.params);
        $scope.searchParams['must'] = [
          templateQuery
        ];

        for(key in $scope.currentFilters) {
          const value = $scope.currentFilters[key];
          if(!value) {
            continue;
          }

          const agg = getAggregationByKey(key);
          if(!agg) {
            continue;
          }

          const item = getAggregationItemByValue(agg, value);
          if(!item) {
            continue;
          }

          $scope.searchParams.must.push({
            query_string: {
              query: item.valueQuery ?? `${item.path[0]}:"${item.path[1]}"`
            }
          });
        }

        $scope.searchParams['geometry'] = $scope.searchObj.params.geometry
          ? $scope.searchObj.params.geometry
          : 'POLYGON((-180 90,180 90,180 -90,-180 -90,-180 90))';

        $scope.$broadcast("resetSearch", $scope.searchParams, true);
      }

      // Detect when the location changesfrom another view to the map search view.
      // This controller is initialized even when the actual map view is not
      // displayed, so when switching to the map view the search needs to be
      // rerun to get map-only results.
      $scope.$on("$locationChangeSuccess", function (_event, _url=null, oldurl=null) {
        const previousLocationWasMap = oldurl && oldurl.contains(gnSearchLocation.MAP);
        if (!previousLocationWasMap && gnSearchLocation.isMap()) {
          $scope.loadFilters();
          triggerSearch();
        }
      });

      init();
    }
  ]);
})();