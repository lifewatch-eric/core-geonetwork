(function () {
  goog.provide("lfw_mapping");

  goog.require("lfw_emlgbif_mapping");
  goog.require("lfw_iso19139_mapping");
  goog.require("lfw_dublin_core_mapping");
  goog.require("lfw_iso19115_3_2018_mapping");

  var module = angular.module("lfw_mapping", [
    "lfw_emlgbif_mapping",
    "lfw_iso19139_mapping",
    "lfw_dublin_core_mapping",
    "lfw_iso19115_3_2018_mapping"
  ]);

  module.factory('standardFiltersMapping', [
    "emlgbifMapping",
    "iso19139Mapping",
    "dublinCoreMapping",
    "iso19115_3_2018Mapping",
    (emlgbifMapping, iso19139Mapping, dublinCoreMapping, iso19115_3_2018Mapping) => ({
      'eml-gbif': emlgbifMapping,
      'iso19139': iso19139Mapping,
      'dublin-core': dublinCoreMapping,
      'iso19115-3.2018': iso19115_3_2018Mapping
    })
  ]);
})();