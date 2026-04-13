(function () {
	goog.provide("lfw_markersmap_directive");

	goog.require("lfw_markersmap_service");

	var module = angular.module("lfw_markersmap_directive", [
		"lfw_markersmap_service"
	]);

	module.directive('markersMap', [
		"markersMapService",
		function (MarkersMap) {
			return {
				restrict: 'E',
				templateUrl: '../../catalog/views/default/templates/markersMap.html',
				link: function (scope, element, attrs) {
					scope.map = MarkersMap.map;
				}
			};
		}
	]);

})();