(function() {
	goog.provide("lfw_filters_configuration_service");

	var module = angular.module("lfw_filters_configuration_service", []);

	module.service('LfwFiltersConfigurationService', [
        '$http',
        function($http){
            this.getUIConfiguration = function(uiIdentifier) {
                return new Promise((resolve, reject) => {
                    // Get the current UI configuration

                    $http.get(`../api/ui/${uiIdentifier}`).then(function (res) {
                        // If the ui configuration was not found, just
                        // return an empty configuration
                        if(res.status == 404) {
                            resolve({});
                            return;
                        }

                        if(res.status != 200) {
                            reject(res);
                            return;
                        }

                        var config = {};
                        try {
                            config = JSON.parse(res.data.configuration);
                        } catch(e) {
                            // Unable to parse UI configuration as JSON
                            reject({ message: "Unable to parse JSON" });
                            return;
                        }
                        if(config == null){
                            config = {}
                        }

                        resolve(config);
                    }).catch(err => {
                        if(err.status == 404) {
                            resolve({});
                            return;
                        }
                        reject({
                            err: err,
                            message: `Error while loading UI configuration (${err.status} - ${err.statusText})` 
                        })
                    });
                });	
            }

            this._setUIConfiguration = function(uiIdentifier, config, create) {
                return new Promise((resolve, reject) => {
                    const url = create
                        ? `../api/ui/`
                        : `../api/ui/${uiIdentifier}`;
                    
                    $http.put(url, {
                            id: uiIdentifier,
                            configuration: JSON.stringify(config)
                        }, {
                            responseType: "text"
                        }
                    ).then( function(res) {
                        if(res.status != 204) {
                            reject(null);
                            return;
                        }

                        // Update was OK
                        resolve(null);
                    });
                });
            }

            this.updateUIConfiguration = function(uiIdentifier, config) {
                return new Promise((resolve, reject) => {
                    this._setUIConfiguration(uiIdentifier, config, false).then(_ => {
                        resolve(null);
                    }).catch(err => {
                        this._setUIConfiguration(uiIdentifier, config, true).then(_ => {
                            resolve(null);
                        }).catch(err => {
                            reject(err);
                        });
                    });
                });
            }

            this.emptyConfiguration = function() {
                return {
                    filters: {},
                    sorting: {
                        facets: [],
                        map: []
                    },
                    nextFilterIndex: 0
                };
            }

            this.configuration = this.emptyConfiguration();

            this.generateViewConfig = async function(frontendId) {                
                // Generate the frontend configuration object
                var frontendConfig = {};

                var viewFacetIndex = 0;

                // Iterate over all the filters selected for this specific view
                for(const key of this.configuration.sorting[frontendId]) {
                    const filter = this.configuration.filters[key];
                    if(!filter) {
                        console.error("Invalid filter id: ", key);
                        continue;
                    }

                    // Each filter can generate multiple facets (one for each
                    // mapping). Keep an index for the facets generated
                    var filterFacetIndex = 0;

                    // Iterate over all mappings of this filter
                    for(const resourceType in filter.mappings) {
                        for(const templateId in filter.mappings[resourceType]) {

                            const sorting_prefix = viewFacetIndex.toString().padStart(4, '0');
                            viewFacetIndex += 1;

                            // Generate a unique id for this facet (just for
                            // the uniqueness of the keys in the configuration)
                            // not used at frontend.
                            const facetKey = `${sorting_prefix}_${filter.key}_${filterFacetIndex}`;
                            filterFacetIndex = filterFacetIndex + 1;

                            const mapping = filter.mappings[resourceType][templateId];

                            const facet = await mapping.getFacet(
                                filter.key,
                                filter.label
                            );

                            if(!facet) {
                                continue;
                            }

                            frontendConfig[facetKey] = facet;
                        }
                    }				
                }

                return frontendConfig;
            }

        }
    ]);
})();