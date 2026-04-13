(function () {
  goog.provide("lfw_gn_filtersconfigurator_controller");

  goog.require("lfw_xml_tree_directive");
  goog.require("lfw_filters_mapping_table");
  goog.require("lfw_filters_list_table");
  goog.require("lfw_filters_configuration_service");
  goog.require("lfw_filters_mapping_service");
  goog.require("lfw_metadata_service");
  goog.require("gn_search_form_controller");
  goog.require("lfw_mapping_tree_directive");
  goog.require("lfw_filter_mapping");
  
  var module = angular.module("lfw_gn_filtersconfigurator_controller", [
    "lfw_xml_tree_directive",
    "lfw_filters_mapping_table",
    "lfw_filters_list_table",
    "lfw_filters_configuration_service",
    "lfw_filters_mapping_service",
    "lfw_metadata_service",
    "gn_search_form_controller",
    "lfw_mapping_tree_directive",
    "lfw_filter_mapping"
  ]);

  module.controller("LfwGnFiltersConfiguratorController", [
    "$scope",
    "LfwFiltersConfigurationService",
    "LfwMetadataService",
    "gnAlertService",
    "FilterMapping",
    "VALIDATION_OUTCOMES",
    function (
      $scope,
      ConfigService,
      metadataService,
      gnAlertService,
      FilterMapping,
      VALIDATION_OUTCOMES
    ) {
      // $scope.searchObj.configId = $scope.searchObj.configId || "search";
      // The current filters & sorting configuration
      $scope.configuration = ConfigService.configuration;

      $scope.loading = false;
      $scope.showFacetModal = false;
      $scope.showMapModal = false;

      // The current selected filter
      $scope.selectedFilter = null;

      $scope.mdTypes = [];
      $scope.templates = {};
      $scope.templatesList = {}; // Map of templateUuid -> templateName

      $scope.filterLabel;

      const invalidConfigSaveMsg = 
        'The current filters configuration could not be<br>\
        saved because one or more filters include an invalid field.<br>\
        Please review the configuration before saving.';
      
      const invalidConfigPreviewMsg = 
        'The current filters configuration could not be<br>\
        previewed because one or more filters include an invalid field.<br>\
        Please review the configuration to proceed with the preview.';

      const init = async function () {
        $scope.loading = true;
        
        let configuration = undefined;
        try {
          const uiConfig = await ConfigService.getUIConfiguration("srv");
          if (uiConfig["lfw_search"]) {
            configuration = uiConfig["lfw_search"]["configurator"];
          }
  
          if (!configuration || configuration == {}) {
            configuration = ConfigService.emptyConfiguration();
          }
  
          ConfigService.configuration = configuration;
          $scope.configuration = configuration;
        } catch(e) {
          console.error("Error while loading UI configuration", e);
          return;
        }

        $scope.mdTypes = [];
        try {
          $scope.mdTypes = await metadataService.loadResourceTypes();
        } catch(e) {
          console.error("Error while loading resource types", e);
        }

        $scope.templates = {};
        $scope.templatesList = {};
        try {
          const templates = await metadataService.loadTemplatesList();
          for(const template of templates) {
            $scope.templatesList[template.uuid] = template.label;
          }

          for(const type of $scope.mdTypes) {
            $scope.templates[type.key] = templates.filter(t => t.resourceType.includes(type.key));
          }
        } catch(e) {
          console.error("Error while loading metadata templates", e);
        }

        parseConfigurationFilters(configuration);

        $scope.loading = false;
      };

      const parseConfigurationFilters = function(configuration) {
        // Parse each mapping to its own object
        for(const filterKey in configuration['filters']) {
          const filter = configuration['filters'][filterKey];
          for(const resourceType in filter['mappings']) {
            for(const templateUuid in filter['mappings'][resourceType]) {
              const mapping = filter['mappings'][resourceType][templateUuid];
              const path = mapping.path;
              
              if(!path || path.length == 0) {
                continue;
              }

              filter['mappings'][resourceType][templateUuid] = new FilterMapping(
                resourceType,
                templateUuid,
                path
              );
            }
          }
        }
      }

      $scope.addMapping = function(resourceType, templateUuid, path) {
        const mappings = $scope.selectedFilter.mappings;

        // Map the new field to the current configuration
        if (!(resourceType in mappings)) {
          mappings[resourceType] = {};
        }

        mappings[resourceType][templateUuid] = new FilterMapping(
          resourceType,
          templateUuid,
          path
        );
      }

      const generateViewsConfiguration = async (uiConfig) => {        
        // Generate frontend configuration for both facets and map
        const views = {};
        for (const key in $scope.configuration.sorting) {
          views[key] = await ConfigService.generateViewConfig(key);
        }

        // Extend the views cofiguration generated by the configurator with
        // the configuration manually entered by the user
        try {
          const baseFacetConfig = uiConfig.mods.search.facetConfig ?? {};
          views.facets = angular.extend({}, baseFacetConfig, views.facets);
        } catch(_) {}

        try {
          const baseMapConfig = uiConfig.mods.search.mapFacetConfig ?? {};
          views.map = angular.extend({}, baseMapConfig, views.map);
        } catch(_) {}

        return views;
      }

      // Save current configuration to GeoNetwork DB
      $scope.saveConfiguration = async function() {
        const isValid = await validateMappings(this.configuration);
        if(!isValid) {
          gnAlertService.addAlert({
            msg: invalidConfigSaveMsg,
            type: "danger"
          });
          return false;
        }

        ConfigService.configuration = this.configuration;
        const uiIdentifier = "srv";

        // Get the current UI configuration
        let config = null;
        try {
          config = await ConfigService.getUIConfiguration(uiIdentifier);  
        } catch(e) {
          gnAlertService.addAlert({
            msg: e.data.message,
            type: "danger"
          });
          console.error("Unable to save configuration", e);
          return;
        }

        const views = await generateViewsConfiguration(config);

        // Update the current UI configuration with:
        //	- the filter configurator config
        //  - the frontend configs
        config["lfw_search"] = {
          configurator: $scope.configuration,
          views: views,
          previews: {}
        };
        
        try {
          await ConfigService.updateUIConfiguration(uiIdentifier, config);

          gnAlertService.addAlert({
            msg: "Configuration saved",
            type: "success"
          },5);
        } catch(e) {
          gnAlertService.addAlert({
            msg: "Unable to save configuration",
            type: "danger"
          });
          console.error("Unable to save configuration", e);
        }
      };

      $scope.savePreviewConfiguration = async function() {
        const isValid = await validateMappings(this.configuration);
        if(!isValid) {
          gnAlertService.addAlert({
            msg: invalidConfigPreviewMsg,
            type: "danger"
          });
          return false;
        }

        ConfigService.configuration = this.configuration;
        const uiIdentifier = "srv";

        let config = null;
        try {
          config = await ConfigService.getUIConfiguration(uiIdentifier);
        } catch(e) {
          console.error("Unable to save configuration", e);
          return false;
        }

        const previews = await generateViewsConfiguration(config);

        // Update the current UI configuration with:
        //	- the filter configurator config
        //  - the frontend configs
        if(!config["lfw_search"]) {
          config["lfw_search"] = {
            configurator: {},
            views: { facets: {}, map: {} },
            previews: { facets: {}, map: {} }
          }
        }

        config["lfw_search"].previews = previews;

        try {
          await ConfigService.updateUIConfiguration(uiIdentifier, config);
        } catch(e) {
          console.error("Unable to save configuration", e);
          return false;
        }

        return true;
      }

      // Preview facets filters configuration
      $scope.showFacetsPreview = async function() {
        if(!await $scope.savePreviewConfiguration()) {
          return;
        }

        $scope.showFacetModal = true

        $("#filter-preview-modal").modal({
          backdrop: 'static',
          keyboard: false
        });
      };

      // Preview map filters configuration
      $scope.showMapPreview = async function() {
        if(!await $scope.savePreviewConfiguration()) {
          return;
        }

        $scope.showMapModal = true

        $("#filter-preview-modal").modal({
          backdrop: 'static',
          keyboard: false
        });
      };

      // close preview
      $scope.closePreview = function() {
        $scope.showFacetModal = false;
        $scope.showMapModal = false;
      }

      // Selects the filter to be edited given its key
      $scope.selectFilter = function (key) {
        if (!key || !$scope.configuration.filters[key]) {
          // Invalid or null key, do nothing
          $scope.selectedFilter = null;
        }

        $scope.selectedFilter = $scope.configuration.filters[key];

        $scope.$broadcast("resetType");
      };

      $scope.onShowInChanged = function() {
        const filter = $scope.selectedFilter;
        if(!filter) {
          return;
        }

        for(let frontendId of ['facets', 'map']) {
          const sorting = $scope.configuration.sorting[frontendId]; 
          const index = sorting.indexOf(filter.key);

          if(filter.showIn[frontendId] && index == -1) {
            sorting.push(filter.key);
          }
          
          if(!filter.showIn[frontendId] && index != -1) {
            sorting.splice(index, 1);
          }
        }
      }
      
      // Creates a new empty filter and selects it
      $scope.createNewFilter = function () {
        // Generate the filter key and update the next index for
        // the next filter creation
        const filterKey = `lfw_filter_${$scope.configuration.nextFilterIndex}`;
        $scope.configuration.nextFilterIndex++;

        // Generate an empty filter with a placeholder label
        const filter = {
          key: filterKey,
          label: "New filter",
          showIn: {
            facets: true,
            map: true
          },
          mappings: {}
        };

        // Add the filter to the current configuration
        $scope.configuration.filters[filterKey] = filter;

        // Add the filter to both 'facets' and 'map'
        $scope.configuration.sorting["facets"].push(filterKey);
        $scope.configuration.sorting["map"].push(filterKey);

        // Select the new filter for the user to edit it
        $scope.selectFilter(filterKey);
      };

      // Checks all filter mappings configured and returns TRUE when all
      // mappings have been succesfully validated.
      // Returns FALSE if any of the mappings is not valid.
      const validateMappings = function(configuration) {
        const promises = [];

        for(const [_, filter] of Object.entries(configuration.filters)) {
          for(const resourceType in filter.mappings) {
            for(templateUuid in filter.mappings[resourceType]) {
              const mapping = filter.mappings[resourceType][templateUuid];

              if(mapping.validationResult == null) {
                promises.push(mapping.validationPromise);
                continue;
              }

              if(mapping.validationResult != VALIDATION_OUTCOMES.VALID) {
                // This mapping validation failed, the whole configuration
                // is invalid
                return new Promise(resolve => { resolve(false); });
              }
            }
          }
        }

        return new Promise(resolve =>
          Promise.all(promises).then(results =>
            resolve(results.length == 0 || results.every(result => result))
          )
        );
      }

      init().then();
    }
  ]);
})();
