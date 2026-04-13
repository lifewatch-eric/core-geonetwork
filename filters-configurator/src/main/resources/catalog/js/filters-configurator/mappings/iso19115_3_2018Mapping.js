(function () {
    goog.provide("lfw_iso19115_3_2018_mapping");
  
    var module = angular.module("lfw_iso19115_3_2018_mapping", []);
  
    const iso19115_3_2018Mapping = {
      "mdb:MD_Metadata": {
        "mdb:metadataIdentifier": {
          "mcc:MD_Identifier": {
            "mcc:code": {
              "gco:CharacterString": {
                "@jsonPath": "metadataIdentifier"
              }
            },
            "mcc:codeSpace": {
              "gco:CharacterString": {
                "@jsonPath": null
              }
            }
          }
        },
        "mdb:defaultLocale": {
          "lan:PT_Locale": {
            "lan:language": {
              "lan:LanguageCode": {
                "@jsonPath": "mainlanguage"
              }
            },
            "lan:characterEncoding": {
              "lan:MD_CharacterSetCode": {
                "@jsonPath": "cl_characterSet.key"
              }
            }
          }
        },
        "mdb:metadataScope": {
          "mdb:MD_MetadataScope": {
            "mdb:resourceScope": {
              "mcc:MD_ScopeCode": {
                "@jsonPath": "cl_resourceScope.key"
              }
            },
            "mdb:name": {
              "gco:CharacterString": {
                "@jsonPath": "resourceTypeNameObject.default"
              }
            }
          }
        },
        "mdb:contact": {
          "cit:CI_Responsibility": {
            "cit:role": {
              "cit:CI_RoleCode": {
                "@jsonPath": "contact.role"
              }
            },
            "cit:party": {
              "cit:CI_Organisation": {
                "cit:name": {
                  "gco:CharacterString": {
                    "@jsonPath": "contact.organization"        
                  },
                  "lan:PT_FreeText": {
                    "lan:textGroup": {
                      "lan:LocalisedCharacterString": {
                        "@jsonPath": "contact.organization"  
                      }
                    }
                  }
                },
                "cit:contactInfo": {
                  "cit:CI_Contact": {
                    "cit:address": {
                      "cit:CI_Address": {
                        "cit:electronicMailAddress": {
                          "@jsonPath": "contact.email"
                        }
                      }
                    }
                  }
                },
                "cit:individual": {
                  "cit:CI_Individual": {
                    "cit:name": {
                      "gco:CharacterString": {
                        "@jsonPath": null
                      }
                    },
                    "cit:positionName": {
                      "gco:CharacterString": {
                        "@jsonPath": null
                      }
                    }
                  }
                }
              }
            }
          }
        },
        "mdb:dateInfo":
          {
            "cit:CI_Date": {
              "cit:date": {
                "gco:DateTime": {
                  "@jsonPath": "createDate"
                }
              },
              "cit:dateType": {
                "cit:CI_DateTypeCode": {
                  "@jsonPath": null
                }
              }
            }
          },
        "mdb:metadataStandard": {
          "cit:CI_Citation": {
            "cit:title": {
              "gco:CharacterString": {
                "@jsonPath": "standardNameObject.default"
              },
              "lan:PT_FreeText": {
                "lan:textGroup": {
                  "lan:LocalisedCharacterString": {
                    "@jsonPath": "standardNameObject.langeng"
                  }
                }
              }
            }
          }
        },
        "mdb:metadataLinkage": {
          "cit:CI_OnlineResource": {
            "cit:linkage": {
              "@jsonPath": null
            },
            "cit:function": {
              "cit:CI_OnLineFunctionCode": {
                "@jsonPath": "cl_function.key"
              }
            }
          }
        },
        "mdb:contentInfo": {
          "mrc:MD_FeatureCatalogue": {
            "mrc:featureCatalogue": {
              "gfc:FC_FeatureCatalogue": {
                "cat:name": {
                  "gco:CharacterString": {
                    "@jsonPath": "resourceTitleObject.default"
                  }
                },
                "gfc:producer": {
                  "@jsonPath": null
                },
                "gfc:featureType": {
                  "gfc:FC_FeatureType": {
                    "gfc:typeName": {
                      "@jsonPath": "featureTypes.typeName"
                    },
                    "gfc:isAbstract": {
                      "gco:Boolean": {
                        "@jsonPath": "featureTypes.isAbstract"
                      }
                    },
                    "gfc:carrierOfCharacteristics": {
                      "gfc:FC_FeatureAttribute": {
                        "gfc:memberName": {
                          "@jsonPath": "featureTypes.attributeTable.name"
                        },
                        "gfc:definition": {
                          "gco:CharacterString": {
                            "@jsonPath": "featureTypes.attributeTable.definition"
                          }
                        },
                        "gfc:cardinality": {
                          "gco:CharacterString": {
                            "@jsonPath": null
                          }
                        },
                        "gfc:listedValue": {
                          "gfc:FC_ListedValue": {
                            "gfc:label": {
                              "gco:CharacterString": {
                                "@jsonPath": "featureTypes.attributeTable.values.label"
                              }
                            },
                            "gfc:code": {
                              "gco:CharacterString": {
                                "@jsonPath": "featureTypes.attributeTable.values.code"
                              }
                            }
                          }
                        }
                      }
                    },
                    "gfc:featureCatalogue": {
                      "@jsonPath": null
                    }
                  }
                }
              }
            }
          }
        },
        "mdb:otherLocale":
        {
          "lan:PT_Locale": {
            "lan:language": {
              "lan:LanguageCode": {
                "@jsonPath": "otherLanguage"
              }
            },
            "lan:characterEncoding": {
              "lan:MD_CharacterSetCode": {
                "@jsonPath": "cl_characterSet.key"
              }
            }
          }
        },
        "mdb:metadataLinkage": {
          "cit:CI_OnlineResource": {
            "cit:linkage": {
              "gco:CharacterString": {
                "@jsonPath": null
              }
            },
            "cit:function": {
              "cit:CI_OnLineFunctionCode": {
                "@jsonPath": "cl_function.key"
              }
            }
          }
        },
        "mdb:referenceSystemInfo": {
          "mrs:MD_ReferenceSystem": {
            "mrs:referenceSystemIdentifier": {
              "mcc:MD_Identifier": {
                "mcc:code": {
                  "gco:CharacterString": {
                    "@jsonPath": "crsDetails.code"
                  }
                }
              }
            }
          }
        },
        "mdb:identificationInfo": {
          "mri:MD_DataIdentification": {
            "mri:citation": {
              "cit:CI_Citation": {
                "cit:title": {
                  "gco:CharacterString": {
                    "@jsonPath": "resourceTitleObject.default"
                  },
                  "lan:PT_FreeText": {
                    "lan:textGroup":
                      {
                        "lan:LocalisedCharacterString": {
                          "@jsonPath": "resourceTitleObject.default"
                        }
                      }
                  }
                },
                "cit:date": {
                  "cit:CI_Date": {
                    "cit:date": {
                      "gco:Date": {
                        "@jsonPath": null
                      }
                    },
                    "cit:dateType": {
                      "cit:CI_DateTypeCode": {
                        "@jsonPath": "resourceDate.type "  
                      }
                    }
                  }
                },
                "cit:edition": {
                  "gco:CharacterString": {
                    "@jsonPath": "resourceEdition"
                  }
                },
                "cit:presentationForm": {
                  "cit:CI_PresentationFormCode": {
                    "@jsonPath": "cl_presentationForm.key"
                  }
                }
              }
            },
            "mri:abstract": {
              "gco:CharacterString": {
                "@jsonPath": "resourceAbstractObject.default"
              },
              "lan:PT_FreeText": {
                "lan:textGroup": {
                  "lan:LocalisedCharacterString": {
                    "@jsonPath": "resourceAbstractObject.langeng"
                  }
                }
              }
            },
            "mri:credit": {
              "gco:CharacterString": {
                "@jsonPath": "resourceCreditObject"
              }
            },
            "mri:purpose": {
              "gco:CharacterString": {
                "@jsonPath": "purposeObject.default"
              },
              "lan:PT_FreeText": {
                "lan:textGroup": {
                  "lan:LocalisedCharacterString": {
                    "@jsonPath": "purposeObject.langeng"
                  }
                }
              }
            },
            "mri:status": {
              "mcc:MD_ProgressCode": {
                "@jsonPath": "cl_status.key"
              }
            },
            "mri:pointOfContact": {
              "cit:CI_Responsibility": {
                "cit:role": {
                  "cit:CI_RoleCode": {
                    "@jsonPath": "contactForResource.role"
                  }
                },
                "cit:party": {
                  "cit:CI_Organisation": {
                    "cit:name": {
                      "gco:CharacterString": {
                        "@jsonPath": "contactForResource.organisation"
                      },
                      "lan:PT_FreeText": {
                        "lan:textGroup": {
                          "lan:LocalisedCharacterString": {
                            "@jsonPath": "contactForResource.organisation"
                          }
                        }
                      }
                    },
                    "cit:contactInfo": {
                      "cit:CI_Contact": {
                        "cit:address": {
                          "cit:CI_Address": {
                            "cit:electronicMailAddress": {
                              "gco:CharacterString": {
                                "@jsonPath": "contactForResource.email"
                              }
                            }
                          }
                        }
                      }
                    },
                    "cit:individual": {
                      "cit:CI_Individual": {
                        "cit:name": {
                          "gco:CharacterString": {
                            "@jsonPath": null
                          }
                        },
                        "cit:positionName": {
                          "gco:CharacterString": {
                            "@jsonPath": null
                          }
                        }
                      }
                    }
                  }
                }
              }
            },
            "mri:spatialRepresentationType": {
              "mcc:MD_SpatialRepresentationTypeCode": {
                "@jsonPath": "cl_spatialRepresentationType.key"
              }
            },
            "mri:spatialResolution": {
              "mri:MD_Resolution": {
                "mri:equivalentScale": {
                  "mri:MD_RepresentativeFraction": {
                    "mri:denominator": {
                      "gco:Integer": {
                        "@jsonPath": "resolutionScaleDenominator.key"
                      }
                    }
                  }
                }
              }
            },
            "mri:topicCategory":
              {
                "mri:MD_TopicCategoryCode": {
                  "@jsonPath": "cl_topic.key"
                }
              },
            "mri:extent": {
                "gex:EX_Extent": {
                  "gex:geographicElement": {
                    "gex:EX_GeographicBoundingBox": {
                      "gex:westBoundLongitude": {
                        "gco:Decimal": {
                          "@jsonPath": null
                        }
                      },
                      "gex:eastBoundLongitude": {
                        "gco:Decimal": {
                          "@jsonPath": null
                        }
                      },
                      "gex:southBoundLatitude": {
                        "gco:Decimal": {
                          "@jsonPath": null
                        }
                      },
                      "gex:northBoundLatitude": {
                        "gco:Decimal": {
                          "@jsonPath": null
                        }
                      }
                    }
                  },
                
                  "gex:temporalElement": {
                    "gex:EX_TemporalExtent": {
                      "gex:extent": {
                        "gml:TimePeriod": {
                          "gml:beginPosition": {
                            "@jsonPath": "resourceTemporalExtentDetails.start.date"
                          },
                          "gml:endPosition": {
                            "@jsonPath": "resourceTemporalExtentDetails.end.date"
                          }
                        }
                      }
                    }
                  },
  
                  "gex:verticalElement": {
                    "gex:EX_VerticalExtent": {
                      "gex:minimumValue": {
                        "@jsonPath": null
                      },
                      "gex:maximumValue": {
                        "@jsonPath": null
                      },
                      "gex:verticalCRS": {
                        "@jsonPath": null
                      }
                    }
                  }
                }
              },
            "mri:resourceMaintenance": {
              "mmi:MD_MaintenanceInformation": {
                "mmi:maintenanceAndUpdateFrequency": {
                  "mmi:MD_MaintenanceFrequencyCode": {
                    "@jsonPath": "cl_maintenanceAndUpdateFrequency.key"
                  }
                }
              }
            },
            "mri:descriptiveKeywords": 
              {
                "mri:MD_Keywords": {
                  "mri:keyword": {
                    "gco:CharacterString": {
                      "@jsonPath": "tag.default"
                    },
                    "lan:PT_FreeText": {
                      "lan:textGroup": {
                        "lan:LocalisedCharacterString": {
                          "@jsonPath": "tag.langeng"
                        }
                      }
                    }
                  },
                  "mri:type": {
                    "mri:MD_KeywordTypeCode": {
                      "@jsonPath": "cl_type.key"
                    }
                  },
                  "mri:thesaurusName": {
                    "cit:CI_Citation": {
                      "cit:title": {
                        "gcx:Anchor": {
                          "@jsonPath": "th_regions.title"
                        }
                      },
                      "cit:date": {
                        "cit:CI_Date": {
                          "cit:date": {
                            "gco:Date": {
                              "@jsonPath": null
                            }
                          },
                          "cit:dateType": {
                            "cit:CI_DateTypeCode": {
                              "@jsonPath": null
                            }
                          }
                        }
                      },
                      "cit:identifier": {
                        "mcc:MD_Identifier": {
                          "mcc:code": {
                            "gcx:Anchor": {
                              "@jsonPath": "allKeywords.th_regions.id"
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
            "srv:serviceType": {
              "gco:ScopedName": {
                "@jsonPath": "serviceType"
              }
            },
            "srv:accessProperties": {
              "mrd:MD_StandardOrderProcess": {
                "mrd:fees": {
                  "gco:CharacterString": {
                    "@jsonPath": null
                  }
                }
              }
            },
            "srv:couplingType": {
              "@jsonPath": null
            },
            "mri:resourceConstraints": {
              "mco:MD_LegalConstraints": {
                "mco:accessConstraints": {
                  "mco:MD_RestrictionCode": {
                    "@jsonPath": "cl_accessConstraints.key"
                  }
                },
                "mco:useConstraints": {
                  "mco:MD_RestrictionCode": {
                    "@jsonPath": "cl_useConstraints.key"
                  }
                },
                "mco:otherConstraints": {
                  "gco:CharacterString": {
                    "@jsonPath": "MD_LegalConstraintsOtherConstraintsObject.default"
                  },
                  "lan:PT_FreeText": {
                    "lan:textGroup": {
                      "lan:LocalisedCharacterString": {
                        "@jsonPath": "MD_LegalConstraintsOtherConstraintsObject.langeng"
                      }
                    }
                  }
                }
              }
            },
            "mri:defaultLocale": {
              "lan:PT_Locale": {
                "lan:language": {
                  "lan:LanguageCode": {
                    "@jsonPath": "mainLanguage"
                  }
                }
              },
              "lan:characterEncoding": {
                "lan:MD_CharacterSetCode": {
                  "@jsonPath": "cl_characterSet.key"
                }
              }
            },
            "mri:supplementalInformation": {
              "gco:CharacterString": {
                "@jsonPath": "supplementalInformationObject.default"
              },
              "lan:PT_FreeText": {
                "lan:textGroup": {
                  "lan:LocalisedCharacterString": {
                    "@jsonPath": "supplementalInformationObject.langeng"
                  }
                }
              }
            }
          }
        },
        "mdb:distributionInfo": {
          "mrd:MD_Distribution": {
            "mrd:distributionFormat":
              {
                "mrd:MD_Format": {
                  "mrd:formatSpecificationCitation": {
                    "cit:CI_Citation": {
                      "cit:title": {
                        "gco:CharacterString": {
                          "@jsonPath": null
                        }
                      },
                      "cit:alternateTitle": {
                        "@jsonPath": null
                      },
                      "cit:date": {
                        "@jsonPath": null
                      },
                      "cit:edition": {
                        "gco:CharacterString": {
                          "@jsonPath": null
                        }
                      },
                      "cit:identifier": {
                        "mcc:MD_Identifier": {
                          "mcc:code": {
                            "gco:CharacterString": {
                              "@jsonPath": null
                            }
                          }
                        }
                      }
                    }
                  }
                }
              },
            "mrd:transferOptions": {
              "mrd:MD_DigitalTransferOptions": {
                "mrd:onLine":
                  {
                    "cit:CI_OnlineResource": {
                      "cit:linkage": {
                        "gco:CharacterString": {
                          "@jsonPath": "link.url"   
                        }
                      },
                      "cit:protocol": {
                        "gco:CharacterString": {
                          "@jsonPath": "link.protocol"
                        }
                      },
                      "cit:name": {
                        "gcx:MimeFileType": {
                          "@jsonPath": "link.name"
                        },
                        "gco:CharacterString": {
                          "@jsonPath": "link.name"      
                        }
                      },
                      "cit:description": {
                        "gco:CharacterString": {
                          "@jsonPath": "link.description"
                        }
                      }
                    }
                  }
              }
            }
          }
        },
        "mdb:resourceLineage": {
          "mrl:LI_Lineage": {
            "mrl:statement": {
              "gco:CharacterString": {
                "@jsonPath": "lineageObject.default"
              },
              "lan:PT_FreeText": {
                "lan:textGroup": {
                  "lan:LocalisedCharacterString": {
                    "@jsonPath": "lineageObject.langeng"
                  }
                }
              }
            },
            "mrl:scope": {
              "mcc:MD_Scope": {
                "mcc:level": {
                  "mcc:MD_ScopeCode": {
                    "@jsonPath": "cl_level.key"
                  }
                }
              }
            }
          }
        }
      }
    };
  
    module.constant('iso19115_3_2018Mapping', iso19115_3_2018Mapping);
  })();