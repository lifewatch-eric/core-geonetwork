(function() {
	goog.provide("lfw_filters_mapping_table");

	goog.require("lfw_filter_mapping");

	var module = angular.module("lfw_filters_mapping_table", [
		"lfw_filter_mapping"
	]);

	module.directive('filtersMappingTable', [
		"VALIDATION_OUTCOMES",
		function(
			VALIDATION_OUTCOMES,
		) {
			return {
				restrict: 'E',
				templateUrl: '../../catalog/templates/admin/settings/filters-mapping-table.html',
				scope: {
					mappings: '=',
					templates: "="
				},
				link: function(scope, element, attrs) {

					scope.VALIDATION_OUTCOMES = VALIDATION_OUTCOMES;

					scope.onMappingDelete = function(resource, uuid) {
						if(confirm("Selected field will be deleted. Are you sure?")){
							delete scope.mappings[resource][uuid];
						}
					}
				}
			}
		}
	]);
})();