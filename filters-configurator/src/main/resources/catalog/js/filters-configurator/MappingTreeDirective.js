(function () {
	goog.provide("lfw_mapping_tree_directive");

	goog.require("lfw_metadata_service");

	var module = angular.module("lfw_mapping_tree_directive", [
		"lfw_metadata_service"
	]);

	module.directive('mappingTree', [
		"LfwMetadataService",
		function (metadataService) {
			return {
				restrict: 'E',
				templateUrl: '../../catalog/templates/admin/settings/mapping-tree.html',
				scope: {
					types: "=",
					templates: "=",
					addMapping: "&"
				},
				link: function (scope, element, attrs) {
					scope.selectedType = null;
					scope.selectedTemplate = null;

					scope.loading = false;

					scope.treeController = {};
					scope.treeData = [];

					const xmlToTreeNodeData = function (xml, parentPath = "") {
						const node = {
							label: xml.tagName,
							children: [],
							path: parentPath + "/" + xml.tagName
						};

						for (let i = 0; i < xml.children.length; i++) {
							node.children.push(
								xmlToTreeNodeData(xml.children.item(i), node.path)
							);
						}

						return node;
					};

					scope.$on("resetType", function (event, args) {
						scope.selectedType = null;
						scope.onTypeSelected();
					});

					scope.onTypeSelected = function () {
						scope.selectedTemplate = null;
						scope.onTemplateSelected();
					};

					scope.onTemplateSelected = function () {
						scope.treeData = [];
						if (!scope.selectedTemplate) {
							return;
						}

						const uuid = scope.selectedTemplate.uuid;

						scope.loading = true;

						metadataService.loadMdRecordXml(uuid)
							.then((xmlDoc) => {
								scope.treeData = [
									xmlToTreeNodeData(xmlDoc.documentElement)
								];
								scope.loading = false;
							})
							.catch((err) => {
								console.error(err);
								scope.loading = false;
							});
					};

					scope.onAdd = function () {
						if (!scope.canAdd()) {
							return;
						}

						const element = scope.treeController.get_selected_branch();

						// If no element is selected in the tree, do nothing
						if (!element) {
							return;
						}

						scope.addMapping({
							type: scope.selectedType.key,
							template: scope.selectedTemplate.uuid,
							path: element.path
						});
					};

					scope.canAdd = function () {
						try {
							const element = scope.treeController.get_selected_branch();
							return element && element.children.length == 0;
						} catch (_) {
							return false;
						}
					};

				}
			};
		}
	]);
})();