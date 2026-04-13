(function () {
    goog.provide("lfw_dublin_core_mapping");
  
    var module = angular.module("lfw_dublin_core_mapping", []);
  
    const dublinCoreMapping = {
      "simpledc": {
        "dc:title": {
            "@jsonPath": "resourceTitleObject.default.keyword"     
        },
        "dc:creator": {
            "@jsonPath": null
        },
        "dc:subject": {
            "@jsonPath": "tag.default"
        },
        "dc:description": {
            "@jsonPath": "resourceAbstract"
        },
        "dc:publisher": {
            "@jsonPath": null
        },
        "dc:contributor": {
          "@jsonPath": "related"      
      },
        "dc:date": {
          "@jsonPath": null
      },      
        "dc:type": {
            "@jsonPath": "resourceType"      
        },
        "dc:format": {
            "@jsonPath": "format"
        },
        "dc:language": {
            "@jsonPath": "resourceLanguage"
        },
        "dc:relation": {
          "@jsonPath": "link.url"
      },
        "dc:coverage": {
            "@jsonPath": null
        },
        "dc:rights": {
            "@jsonPath": null
        },
        "dct:created": {
            "@jsonPath": null
        },
        "dct:dateSubmitted": {
          "@jsonPath": null
        },
        "dct:references": {
          "@jsonPath": "link.url"
        },
        "dct:modified": {
          "@jsonPath": "revisionDateForResource"
        },
        "dc:identifier": {
          "@jsonPath": "metadataIdentifier"
      }
      }
    };
  
    module.constant('dublinCoreMapping', dublinCoreMapping);
  })();