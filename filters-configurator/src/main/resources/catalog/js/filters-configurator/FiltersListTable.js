(function() {
	goog.provide("lfw_filters_list_table");

	var module = angular.module("lfw_filters_list_table", []);

	module.directive('filtersListTable', [
		function() {
			return {
				restrict: 'E',
				templateUrl: '../../catalog/templates/admin/settings/filters-list-table.html',
				scope: {
					config: '=',
					frontendId: '=',

					// If true, shows enabled filters, otherwise shows
					// disabled filters for this frontend type
					enabled: '=',

					editFilter: '&',
					selectedFilter: "="
				},
				link: function(scope, element, attrs) {


					scope.onFilterEdit = function(key) {
						scope.editFilter({key:key});
					}

					scope.onFilterDelete = function(key) {
						if (confirm("Selected filter will be deleted from Facet and Map lists. Are you sure?")) {						
							// Selects the filter to be deleted given its key
							if (!key || !scope.config.filters[key]) {
								// Invalid or null key, do nothing
								return;
							}

							for(let frontendId of ['facets', 'map']) {
								const sorting = scope.config.sorting[frontendId];
								const index = sorting.indexOf(key);

								if(index != -1) {
									sorting.splice(index, 1);
								}
							}

							if(scope.selectedFilter && scope.selectedFilter.key == key) {
								scope.editFilter({ key: null });
							}

							delete scope.config.filters[key];
						}
					}

					scope.sortUp = function(key) {
						const sorting = scope.config.sorting[scope.frontendId];
						const currentIndex = sorting.indexOf(key);
						if(currentIndex < 1) {
							return;
						}

						sorting.splice(
							currentIndex - 1,
							2,
							sorting[currentIndex],
							sorting[currentIndex - 1]
						);
					}

					scope.sortDown = function(key) {
						const sorting = scope.config.sorting[scope.frontendId];
						const currentIndex = sorting.indexOf(key);
						if(currentIndex > sorting.length - 2) {
							return;
						}

						sorting.splice(
							currentIndex,
							2,
							sorting[currentIndex + 1],
							sorting[currentIndex]
						);
					}

					scope.enabledFilters = function() {
						const filters = [];
						for(let key of scope.config.sorting[scope.frontendId]) {
							const filter = scope.config.filters[key];
							if(filter && filter.showIn[scope.frontendId]) {
								filters.push(filter);
							}
						}

						return filters;
					}

					scope.disabledFilters = function() {
						const filters = [];
						for(let key in scope.config.filters) {
							const filter = scope.config.filters[key];
							if(filter && !filter.showIn[scope.frontendId]) {
								filters.push(filter);
							}
						}

						return filters;
					}

					scope.sortedFilters = function() {
						return scope.enabled
							? scope.enabledFilters()
							: scope.disabledFilters();
					}
				}
			};
		}
	]);
})();