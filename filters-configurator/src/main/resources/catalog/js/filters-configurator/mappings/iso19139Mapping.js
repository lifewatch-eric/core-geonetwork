(function () {
  goog.provide("lfw_iso19139_mapping");

  var module = angular.module("lfw_iso19139_mapping", []);

  const iso19139Mapping = {
    "gmd:MD_Metadata": {
      "gmd:fileIdentifier": {
        "gco:CharacterString": {
          "@jsonPath": "metadataIdentifier"
        }
      },
      "gmd:language": {
        "gco:CharacterString": {
          "@jsonPath": "mainLanguage"
        },
        "gmd:LanguageCode": {
          "@jsonPath": "mainLanguage"
        }
      },
      "gmd:parentIdentifier": {
        "gco:CharacterString": {
          "@jsonPath": null
        }
      },
      "gmd:hierarchyLevel": {
        "gmd:MD_ScopeCode": {
          "@jsonPath": "cl_hierarchyLevel.key"
        }
      },
      "gmd:hierarchyLevelName": {
        "gco:CharacterString": {
          "@jsonPath": "resourceTypeNameObject.default"
        }
      },
      "gmd:contact": {
        "gmd:CI_ResponsibleParty": {
          "gmd:organisationName": {
            "gco:CharacterString": {
              "@jsonPath": "contact.organisation"
            }
          },
          "gmd:role": {
            "gmd:CI_RoleCode": {
              "@jsonPath": "contact.role"
            }
          }
        }
      },
      "gmd:dateStamp": {
        "gco:Date": {
          "@jsonPath": null
        }
      },
      "gmd:metadataStandardName": {
        "gco:CharacterString": {
          "@jsonPath": "standardNameObject.default"
        }
      },
      "gmd:metadataStandardVersion": {
        "gco:CharacterString": {
          "@jsonPath": "standardVersionObject.default.keyword"
        }
      },
      "gmd:identificationInfo": {
        "srv:SV_ServiceIdentification": {
          "gmd:citation": {
            "gmd:CI_Citation": {
              "gmd:title": {
                "gco:CharacterString": {
                  "@jsonPath": "resourceTitleObject.default.keyword"
                }
              },
              "gmd:date": {
                "gmd:CI_Date": {
                  "gmd:date": {
                    "gco:Date": {
                      "@jsonPath": null
                    }
                  },
                  "gmd:dateType": {
                    "gmd:CI_DateTypeCode": {
                      "@jsonPath": "resourceDate.type"
                    }
                  }
                }
              },
              "gmd:citedResponsibleParty": {
                "gmd:CI_ResponsibleParty": {
                  "gmd:individualName": {
                    "gco:CharacterString": {
                      "@jsonPath": null
                    }
                  },
                  "gmd:organisationName": {
                    "gco:CharacterString": {
                      "@jsonPath": null
                    }
                  },
                  "gmd:contactInfo": {
                    "gmd:CI_Contact": {
                      "gmd:phone": {
                        "gmd:CI_Telephone": {
                          "gmd:voice": {
                            "gco:CharacterString": {
                              "@jsonPath": "contact.phone"
                            }
                          }
                        }
                      },
                      "gmd:address": {
                        "gmd:CI_Address": {
                          "gmd:electronicMailAddress": {
                            "gco:CharacterString": {
                              "@jsonPath": "contact.address"
                            }
                          }
                        }
                      },
                      "gmd:onlineResource": {
                        "gmd:CI_OnlineResource": {
                          "gmd:linkage": {
                            "gmd:URL": {
                              "@jsonPath": null
                            }
                          },
                          "gmd:description": {
                            "gco:CharacterString": {
                              "@jsonPath": null
                            }
                          }
                        }
                      }
                    }
                  },
                  "gmd:role": {
                    "gmd:CI_RoleCode": {
                      "@jsonPath": null
                    }
                  }
                }
              }
            }
          },
          "gmd:abstract": {
            "gco:CharacterString": {
              "@jsonPath": "resourceAbstractObject.default.keyword"
            }
          },
          "srv:serviceType": {
            "gco:LocalName": {
              "@jsonPath": "serviceType"
            }
          },
          "srv:extent": {
            "gmd:EX_Extent": {
              "gmd:geographicElement": {
                "gmd:EX_GeographicBoundingBox": {
                  "gmd:westBoundLongitude": {
                    "gco:Decimal": {
                      "@jsonPath": null
                    }
                  },
                  "gmd:eastBoundLongitude": {
                    "gco:Decimal": {
                      "@jsonPath": null
                    }
                  },
                  "gmd:southBoundLatitude": {
                    "gco:Decimal": {
                      "@jsonPath": null
                    }
                  },
                  "gmd:northBoundLatitude": {
                    "gco:Decimal": {
                      "@jsonPath": null
                    }
                  }
                }
              }
            }
          },
          "srv:couplingType": {
            "@jsonPath": null
          },
          "srv:containsOperations": {
            "srv:SV_OperationMetadata": {
              "srv:operationName": {
                "gco:CharacterString": {
                  "@jsonPath": null
                }
              },
              "srv:DCP": {
                "@jsonPath": null
              },
              "srv:connectPoint": {
                "gmd:CI_OnlineResource": {
                  "gmd:linkage": {
                    "gmd:URL": {
                      "@jsonPath": null
                    }
                  },
                  "gmd:protocol": {
                    "gco:CharacterString": {
                      "@jsonPath": null
                    }
                  },
                  "gmd:description": {
                    "gco:CharacterString": {
                      "@jsonPath": null
                    }
                  },
                  "gmd:function": {
                    "gmd:CI_OnLineFunctionCode": {
                      "@jsonPath": "cl_function.key"
                    }
                  }
                }
              }
            }
          }
        },
        "gmd:MD_DataIdentification": {
          "gmd:citation": {
            "gmd:CI_Citation": {
              "gmd:title": {
                "gco:CharacterString": {
                  "@jsonPath": "resourceTitleObject.default.keyword"
                }
              },
              "gmd:date": {
                "gmd:CI_Date": {
                  "gmd:date": {
                    "gco:Date": {
                      "@jsonPath": "publicationDateForResource"
                    }
                  },
                  "gmd:dateType": {
                    "gmd:CI_DateTypeCode": {
                      "@jsonPath": "resourceDate.type"
                    }
                  }
                }
              }
            }
          },
          "gmd:abstract": {
            "gco:CharacterString": {
              "@jsonPath": "resourceAbstractObject.default.keyword"
            }
          },
          "gmd:resourceMaintenance": {
            "gco:CharacterString": {
              "@jsonPath": "standardVersion.default.keyword"
            }
          },
          "gmd:status": {
            "gmd:MD_ProgressCode": {
              "@jsonPath": "cl_status.key"
            },
            "gmd:MD_ProgressCodeSite": {
              "@jsonPath": "cl_status.key"
            }
          },
          "gmd:pointOfContact": {
            "gmd:CI_ResponsibleParty": {
              "gmd:individualName": {
                "gco:CharacterString": {
                  "@jsonPath": "contactForResource.individual.keyword"
                }
              },
              "gmd:organisationName": {
                "gco:CharacterString": {
                  "@jsonPath": "contactForResource.organisation.keyword"
                }
              },
              "gmd:positionName": {
                "gco:CharacterString": {
                  "@jsonPath": "contactForResource.position.keyword"
                }
              },
              "gmd:contactInfo": {
                "gmd:CI_Contact": {
                  "gmd:address": {
                    "gmd:CI_Address": {
                      "gmd:electronicMailAddress": {
                        "gco:CharacterString": {
                          "@jsonPath": "contactForResource.email.keyword"
                        }
                      }
                    }
                  }
                }
              },
              "gmd:role": {
                "gmd:CI_RoleCode": {
                  "@jsonPath": "contactForResource.role.keyword"
                }
              }
            }
          },
          "graphicOverview": {
            "MD_BrowseGraphic": {
              "fileName": {
                "CharacterString": {
                  "@jsonPath": "overview.url"
                }
              }
            }
          },
          "gmd:descriptiveKeywords": {
            "gmd:MD_Keywords": {
              "gmd:keyword": {
                "gco:CharacterString": {
                  "@jsonPath": "tag.default"
                }
              }
            }
          },
          "gmd:resourceConstraints": {
            "gmd:MD_LegalConstraints": {
              "gmd:accessConstraints": {
                "gmd:MD_RestrictionCode": {
                  "@jsonPath": "cl_accessConstraints.key"
                }
              },
              "gmd:useLimitation": {
                "gco:CharacterString": {
                  "@jsonPath": "MD_LegalConstraintsUseLimitationObject.default.keyword"
                }
              },
              "gmd:otherConstraints": {
                "gco:CharacterString": {
                  "@jsonPath": null
                }
              }
            }
          },
          "gmd:extent": {
            "gmd:EX_Extent": {
              "gmd:description": {
                "gco:CharacterString": {
                  "@jsonPath": "extentDescriptionObject.default.keyword"
                }
              },
              "gmd:geographicElement": {
                "gmd:EX_GeographicBoundingBox": {
                  "gmd:westBoundLongitude": {
                    "gco:Decimal": {
                      "@jsonPath": "geomMapping.cords[0][0]"
                    }
                  },
                  "gmd:eastBoundLongitude": {
                    "gco:Decimal": {
                      "@jsonPath": "geomMapping.cords[1][0]"
                    }
                  },
                  "gmd:southBoundLatitude": {
                    "gco:Decimal": {
                      "@jsonPath": "geomMapping.cords[0][1]"
                    }
                  },
                  "gmd:northBoundLatitude": {
                    "gco:Decimal": {
                      "@jsonPath": "geomMapping.cords[2][1]"
                    }
                  }
                }
              }
            }
          }
        }
      },
      "gmd:vre": {
        "gmd:LW_VRE": {
          "gmd:containServices_vre": {
            "gmd:LW_ContainServices": {
              "gmd:serviceName_vre": {
                "gco:CharacterString": {
                  "@jsonPath": null
                }
              },
              "gmd:serviceDescription_vre": {
                "gco:CharacterString": {
                  "@jsonPath": null
                }
              },
              "gmd:serviceReference_vre": {
                "gco:CharacterString": {
                  "@jsonPath": null
                }
              }
            }
          },
          "gmd:vreOtherInformation_vre": {
            "gmd:LW_VREOtherInformation": {
              "gmd:publicationsAboutThisVRE_vre": {
                "gco:CharacterString": {
                  "@jsonPath": "publicationsAboutThisVRE_vre"
                }
              }
            }
          }
        }
      },
      "gmd:workflow": {
        "gmd:LW_Workflow": {
          "gmd:containServices_workflow": {
            "gmd:LW_WorkflowContainServices": {  //verificare struttura
              "gmd:serviceName_workflow": {
                "gco:CharacterString": {
                  "@jsonPath": null
                }
              },
              "gmd:serviceDescription_workflow": {
                "gco:CharacterString": {
                  "@jsonPath": null
                }
              },
              "gmd:serviceReference_workflow": {
                "gco:CharacterString": {
                  "@jsonPath": null
                }
              }
            }
          },
          "gmd:workflowOtherInformation_workflow": {
            "gmd:LW_workflowOtherInformation": {
              "gmd:workflowHelpdesk_workflow": {
                "gco:CharacterString": {
                  "@jsonPath": "workflowHelpdesk_workflow"
                }
              },
              "gmd:workflowTraining_workflow": {
                "gco:CharacterString": {
                  "@jsonPath": "workflowTraining_workflow"
                }
              }
            }
          }
        }
      },
      "gmd:distributionInfo": {
        "gmd:MD_Distribution": {
          "gmd:transferOptions": {
            "gmd:MD_DigitalTransferOptions": {
              "gmd:onLine": {
                "gmd:CI_OnlineResource": {
                  "gmd:linkage": {
                    "gmd:URL": {
                      "@jsonPath": "linkUrl"
                    }
                  },
                  "gmd:protocol": {
                    "gco:CharacterString": {
                      "@jsonPath": "linkProtocol"
                    }
                  },
                  "gmd:applicationProfile": {
                    "gco:CharacterString": {
                      "@jsonPath": "link.applicationProfile"
                    }
                  },
                  "gmd:name": {
                    "gco:CharacterString": {
                      "@jsonPath": "link.name"
                    }
                  },
                  "gmd:description": {
                    "gco:CharacterString": {
                      "@jsonPath": "link.description"
                    }
                  },
                  "gmd:function": {
                    "gmd:CI_OnLineFunctionCode": {
                      "@jsonPath": "link.function"
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  };

  module.constant('iso19139Mapping', iso19139Mapping);
})();