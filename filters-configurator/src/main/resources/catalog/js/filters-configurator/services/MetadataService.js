(function () {
	goog.provide("lfw_metadata_service");

	var module = angular.module("lfw_metadata_service", []);

	module.service('LfwMetadataService', [
		'$http',
		'$filter',
		function ($http, $filter) {
			this.searchUrl = "../api/search/records/_search";

			// Cache xml records
			this.recordXmls = {};

			this.templates = [];

			this.loadResourceTypes = function () {
				const aggregations = {
					resourceType: {
						terms: {
							field: "resourceType",
							exclude: ["map/static", "theme", "place"]
						}
					}
				};

				const templateQuery = {
					query_string: {
						query: "+isTemplate:y +isPublishedToAll:true"
					}
				}

				const options = {
					aggregations: aggregations,
					query: {
						bool: {
							must: templateQuery
						}
					},
					from: 0,
					size: 1000
				};

				return new Promise((resolve, reject) => {
					$http.post(this.searchUrl, options).then(r => {
						try {
							const aggs = r.data.aggregations.resourceType;

							if (!aggs) {
								reject(null);
								return;
							}

							const types = aggs.buckets.map(bucket => ({
								key: bucket.key,
								label: $filter("facetTranslator")(bucket.key, 'resourceType')
							}));

							resolve(types);
						} catch (e) {
							reject(e);
						}
					}).catch(e => {
						reject(e);
					});
				});
			}

			this._loadTemplates = function() {
				const templateQuery = {
					query_string: {
						query: `+isTemplate:y +isPublishedToAll:true`
					}
				}

				const options = {
					query: {
						bool: {
							must: templateQuery
						}
					},
					_source: [
						'uuid',
						'resourceTitleObject',
						'documentStandard',
						'resourceType'
					],
					from: 0,
					size: 1000
				};

				return new Promise((resolve, reject) => {
					$http.post(this.searchUrl, options).then(r => {
						try {
							this.templates = r.data.hits.hits.map(item => ({
								uuid: item._source.uuid,
								label: item._source.resourceTitleObject ? item._source.resourceTitleObject.default : "",
								documentStandard: item._source.documentStandard,
								resourceType: item._source.resourceType ?? []
							}));

							resolve(this.templates);
						} catch (e) {
							reject(e);
						}
					}).catch(e => {
						reject(e);
					});
				});
			}

			this.loadTemplatesList = function (resourceType = null) {
				return new Promise((resolve, reject) => {
					if(this.templates.length > 0) {
						resolve(this.templates.filter(t => {
							return resourceType == null | t.resourceType.includes(resourceType)
						}));
						return;
					}

					this._loadTemplates().then(_ => {
						resolve(this.templates.filter(t => {
							return resourceType == null | t.resourceType.includes(resourceType)
						}));
					}).catch(e => {
						reject(e);
					});
				});
			}

			this.loadTemplatesMap = function (resourceType = null) {
				return new Promise((resolve, reject) => {
					this.loadTemplatesList(resourceType).then(r => {
						let templates = {};
						for (const template of r) {
							templates[template.uuid] = template;
						}

						resolve(templates);
					}).catch(e => {
						reject(e);
					});
				});
			}

			// Gets a metadata record in xml format using the default
			// GeoNetwork API
			this.loadMdRecordXml = function (uuid) {
				// Check if there is a cached result
				if (this.recordXmls[uuid]) {
					return new Promise(resolve => resolve(this.recordXmls[uuid]));
				}

				const url = "../api/records/" + uuid + "/formatters/xml?withConfiguratorAttributes=true";
				const options = {
					headers: {
						"Accept": "application/xml"
					}
				};

				return new Promise(async (resolve, reject) => {
					$http.get(url, options).then(r => {
						if (r.status != 200) {
							reject(null);
							return;
						}

						try {
							// Parse the xml string
							xmlDoc = new DOMParser().parseFromString(r.data, "text/xml");

							// Cache this result
							this.recordXmls[uuid] = xmlDoc;

							resolve(xmlDoc);
						} catch (e) {
							reject(e);
						}
					}).catch(e => {
						reject({
							e: e,
							message: `Error while loading template record (${e.status} - ${e.statusText})`
						});
					});
				});
			}
		}
	]);
})();