(function () {
  goog.provide("lfw_emlgbif_mapping");

  var module = angular.module("lfw_emlgbif_mapping", []);

  module.constant('emlgbifMapping', {
    "eml:eml": {
      "dataset": {
        "alternateIdentifier": {
          "@jsonPath": "metadataIdentifier"
        },
        "title": {
          "@jsonPath": "resourceTitleObject.default.keyword"
        },
        "shortname": {
          "@jsonPath": null
        },
        "distribution": {
          "online": {
            "onlineDescription": {
              "@jsonPath": "onlineDistribution.onlineDescription"
            },
            "url": {
              "@jsonPath": "onlineDistribution.url"
            },
            "language": {
              "@jsonPath": "onlineDistribution.language"
            }
          }
        },
        "status": {
          "@jsonPath": null
        },
        "keywordSet": {
          "keyword": {
            "@jsonPath": "keywordSets.keywords.keyword"
          },
          "keywordThesaurus": {
            "@jsonPath": "keywordSets.keywordThesaurus"
          }
        },
        "creator": {
          "organizationName": {
            "@jsonPath": "creators.organizationName"
          },
          "individualName": {
            "givenName": {
              "@jsonPath": "creators.individualNameGivenName"
            },
            "surName": {
              "@jsonPath": "creators.individualNameSurName"
            }
          },
          "positionName": {
            "@jsonPath": "creators.positionName"
          },
          "electronicMailAddress": {
            "@jsonPath": "creators.electronicMailAddress"
          },
          "userId": {
            "@jsonPath": "creators.userId.keyword"
          }
        },
        "metadataProvider": {
          "organizationName": {
            "@jsonPath": "metadataProvider.organizationName"
          },
          "individualName": {
            "givenName": {
              "@jsonPath": "metadataProvider.individualNameGivenName"
            },
            "surName": {
              "@jsonPath": "metadataProvider.individualNameSurName"
            }
          },
          "positionName": {
            "@jsonPath": "metadataProvider.positionName"
          },
          "electronicMailAddress": {
            "@jsonPath": "metadataProvider.electronicMailAddress"
          },
          "userId": {
            "@jsonPath": "metadataProvider.userId.keyword"
          }
        },
        "pubDate": {
          "@jsonPath": "publicationDateForResource"
        },
        "language": {
          "@jsonPath": "resourceLanguage"
        },
        "abstract": {
          "para": {
            "@jsonPath": "resourceAbstractObject.default"
          }
        },
        "intellectualRights": {
          "para": {
            "@jsonPath": "intellectualRights_dataset"
          }
        },
        "licensed": {
          "licenseName": {
            "@jsonPath": "licenseName_licensed_dataset"
          },
          "url": {
            "@jsonPath": "url_licensed_dataset"
          },
          "acknowledgements": {
            "@jsonPath":"acknowledgements_licensed_dataset"
          }
          },
        "acknowledgements": {
          "instrument": {
            "@jsonPath": null
          }
        },
        "coverage": {
          "geographicCoverage": {
            "geographicDescription": {
              "@jsonPath": "geographicCoverage.geographicDescription.keyword"
            },
            "boundingCoordinates": {
              "westBoundingCoordinate": {
                "@jsonPath": "geom.cords[0][0]"
              },
              "eastBoundingCoordinate": {
                "@jsonPath": "geom.cords[1][0]"
              },
              "northBoundingCoordinate": {
                "@jsonPath": "geom.cords[0][1]"
              },
              "southBoundingCoordinate": {
                "@jsonPath": "geom.cords[2][1]"
              },
              "boundingAltitudes": {
                "altitudeMinimum": {
                  "@jsonPath": null
                },
                "altitudeMaximum": {
                  "@jsonPath": null
                },
                "altitudeUnits": {
                  "@jsonPath": null
                }
              }
            }
          },
          "temporalCoverage": {
            "rangeOfDates": {
              "beginDate": {
                "calendarDate": {
                  "@jsonPath": null
                }
              },
              "endDate": {
                "calendarDate": {
                  "@jsonPath": null
                }
              }
            }
          },
          "taxonomicCoverage": {
            "taxonomicClassification": {
              "taxonRankName": {
                "@jsonPath": "taxonomicCoverages.taxonomicClassification.taxonRankName"
              },
              "taxonRankValue": {
                "@jsonPath": "taxonomicCoverages.taxonomicClassification.taxonRankValue"
              },
              "commonName": {
                "@jsonPath": null
              },
              "taxonId": {
                "@jsonPath": null
              }
            }
          }
        },
        "contact": {
          "organizationName": {
            "@jsonPath": "contacts.organizationName"
          },
          "individualName": {
            "givenName": {
              "@jsonPath": "contacts.individualNameGivenName.keyword"
            },
            "surName": {
              "@jsonPath": "contacts.individualNameSurName.keyword"
            },
            "electronicMailAddress": {
              "@jsonPath": null
            }
          },
          "positionName": {
            "@jsonPath": "contacts.positionName.keyword"
          },
          "electronicMailAddress": {
            "@jsonPath": "contacts.electronicMailAddress.keyword"
          },
          "userId": {
            "@jsonPath": "contacts.userId.keyword"
          }
        },
        "methods": {
          "methodStep": {
            "description": {
              "para": {
                "@jsonPath": "methods.methodSteps.description"
              }
            },
            "citation": {
              "@jsonPath": "methods.methodSteps.citation"
            },
            "instrumentation": {
              "para": {
                "@jsonPath": "methods.methodSteps.instrumentation"
              }
            },
            "software": {
              "title": {
                "@jsonPath": "methods.methodSteps.softwares.title"
              },
              "version": {
                "@jsonPath": "methods.methodSteps.softwares.version"
              }
            }
          },
          "sampling": {
            "samplingDescription": {
              "para": {
                "@jsonPath": "methods.samplings.samplingDescription"
              }
            }
          }
        },
        "project": {
          "title": {
            "@jsonPath": "project.title"
          },
          "abstract": {
            "@jsonPath": "project.abstract"
          },
          "personnel": {
            "organizationName": {
              "@jsonPath": "project.personnel.organizationName"
            },
            "individualName": {
              "givenName": {
                "@jsonPath": "project.personnel.individualNameGivenName"
              },
              "surName": {
                "@jsonPath": "project.personnel.individualNameSurName"
              }
            },
            "positionName": {
              "@jsonPath": "project.personnel.positionName"
            }
          }
        }
      }
    }
  });
})();