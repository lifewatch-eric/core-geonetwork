(function() {
	goog.provide("lfw_filter_mapping");

    goog.require("lfw_filters_mapping_service");
    goog.require("lfw_metadata_service");
    goog.require("lfw_filters_configuration_service");

	var module = angular.module("lfw_filter_mapping", [
        "lfw_filters_mapping_service",
        "lfw_metadata_service",
        "lfw_filters_configuration_service"
    ]);

    const VALIDATION_OUTCOMES = {
        VALID: 0,
        MAPPING_VALIDATION_ERROR: 1,
        ES_VALIDATION_ERROR: 2
    };

    module.constant('VALIDATION_OUTCOMES', VALIDATION_OUTCOMES);

	module.factory('FilterMapping', [
        '$http',
        'LfwFiltersMappingService',
        'LfwMetadataService',
        function($http, mappingService, metadataService) {
            class FilterMapping {
                resourceType = "";
                templateUuid = "";
                path = "";
                validationPromise = null;
                validationResult = null;

                constructor(resourceType, templateUuid, path) {
                    this.resourceType = resourceType;
                    this.templateUuid = templateUuid;
                    this.path = path;

                    if(!this.validationPromise) {
                        this.validationPromise = this.validate();
                    }
                }

                toJSON() {
                    return {
                        path: this.path
                    };
                }

                // Performs a simple ES query to check that this specific
                // aggregation does not result in an ES error
                validate() {
                    return new Promise(async (resolve, _reject) => {
                        this.validationResult = null;

                        // Some generic key and label are sufficient for this
                        // validation test
                        const facetKey = 'key';
                        const facetLabel = 'label';

                        const facet = await this.getFacet(facetKey, facetLabel);

                        if(!facet) {
                            this.validationResult = VALIDATION_OUTCOMES.MAPPING_VALIDATION_ERROR;
                            console.debug("Filter validation failed", {
                                resourceType: this.resourceType,
                                templateUuid: this.templateUuid,
                                path: this.path,
                                reason: this.validationResult
                            });
                            resolve(false);
                            return;
                        }

                        // Generate aggs config for the ES query
                        const aggs = {};
                        aggs[facetKey] = facet;

                        const templateQuery = {
                            query_string: {
                                query: "+isTemplate:n"
                            }
                        };

                        var endpoint = "../api/search/records/_search";
                        var reqBody = {
                            aggregations: aggs,
                            query: {
                                bool: {
                                    must: [ templateQuery ]
                                }
                            },
                            from: 0,
                            size: 0
                        };

                        // Make the query to ES, if it fails the validation fails
                        try {
                            await $http.post(endpoint, reqBody);
                        } catch (e) {
                            this.validationResult = VALIDATION_OUTCOMES.ES_VALIDATION_ERROR;
                            console.debug("Filter validation failed", {
                                resourceType: this.resourceType,
                                templateUuid: this.templateUuid,
                                path: this.path,
                                reason: this.validationResult
                            });
                            resolve(false);
                            return;
                        }

                        this.validationResult = VALIDATION_OUTCOMES.VALID;
                        resolve(true);
                    });
                }

                async getFacet(filterKey, label) {
                    const jsonPath = await this.getJSONPath();

                    // Couldn't generate jsonPath for this template path
                    if(!jsonPath) {
                        console.debug("Error while generating filter facet", {
                            reasonMsg: "Could not get JSON path"
                        });
                        return null;
                    }

                    // The custom geonetwork configuration seems not to accept
                    // object keys that contain the '.' (dot) character.
                    // These values seem to be deleted when loaded at runtime.
                    // Replace here the dot with a pipe and switch back when
                    // generating the facet.
                    const facet = {
                        filter: {
                            bool: {
                                must: [
                                    { term: { ["resourceType"]: this.resourceType }},
                                    { term: { ["duplicatedFromUuid|keyword"]: this.templateUuid }}
                                ]
                            }
                        },
                        aggs: {
                            [filterKey]: {
                                terms: {
                                    field: jsonPath,
                                    exclude: ""
                                },
                                meta: {
                                    field: jsonPath,
                                    lfw_configurator: {
                                        key: filterKey,
                                        label: label
                                    }
                                }
                            }
                        }
                    };

                    return facet ?? null;
                }

                async getJSONPath() {
                    let templates = {};
                    try {
                        templates = await metadataService.loadTemplatesMap();
                    } catch(e) {
                        console.error("Error while loading templates", {e});
                    }

                    const template = templates[this.templateUuid];
                    const docStandard = template ? template.documentStandard : null;

                    let jsonPath = null;
                    try {
                        jsonPath = await mappingService.templatePathToJsonPath(
                            docStandard, this.templateUuid, this.path
                        );
                    } catch(e) {}


                    return jsonPath;
                }
            }

            return FilterMapping;
        }
    ]);
})();
