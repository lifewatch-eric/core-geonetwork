(function () {
	goog.provide("lfw_map_search_settings");

	var module = angular.module("lfw_map_search_settings", []);

	module.service('mapSearchSettings', ['$http', function ($http) {
		this.defaultConfig = {
			markers: {
				color: "#0f4e8a"
			},
			clusters: {
				distance: 50,
				icon: {
					outerRadius: 18,
					outerColor: "#0f4e8a",
					innerRadius: 15,
					innerColor: "#0f4e8a",
					textColor: "#FFFFFF"
				}
			}
		};

		this.getConfig = function () {
			const config = angular.copy(this.defaultConfig);

			return new Promise((resolve, reject) => {
				// Load GeoNetwork CSS & Style configuration and replace
				// default marker colors
				$http({
					method: "GET",
					url: "../api/customstyle",
					headers: { "Content-Type": "text/plain" }
				}).then(
					function success(response) {
						const gnCssStyle = response.data;

						if (gnCssStyle.gnMapMarkerColor && gnCssStyle.gnMapMarkerColor.length) {
							config.markers.color = gnCssStyle.gnMapMarkerColor;
						}

						if (gnCssStyle.gnMapClusterColor && gnCssStyle.gnMapClusterColor.length) {
							config.clusters.icon.innerColor = gnCssStyle.gnMapClusterColor;
							config.clusters.icon.outerColor = gnCssStyle.gnMapClusterColor;
						}
						resolve(config);
					},
					function error(_) {
						resolve(config);
					}
				);
			});
		}
	}]);

})();
