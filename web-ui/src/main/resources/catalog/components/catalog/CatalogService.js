/*
 * Copyright (C) 2001-2016 Food and Agriculture Organization of the
 * United Nations (FAO-UN), United Nations World Food Programme (WFP)
 * and United Nations Environment Programme (UNEP)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or (at
 * your option) any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
 * General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
 *
 * Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
 * Rome - Italy. email: geonetwork@osgeo.org
 */

(function() {
  goog.provide('gn_catalog_service');

  goog.require('gn_urlutils_service');

  var module = angular.module('gn_catalog_service', [
    'gn_urlutils_service'
  ]);

  /**
   * @ngdoc service
   * @kind function
   * @name gnMetadataManager
   * @requires $http
   * @requires $location
   * @requires $timeout
   * @requires gnUrlUtils
   *
   * @description
   * The `gnMetadataManager` service provides main operations to manage
   * metadatas such as create, import, copy or delete.
   * Other operations like save are provided by another service `gnEditor`.
   */
  module.factory('gnMetadataManager', [
    '$http',
    '$location',
    '$timeout',
    'gnUrlUtils',
    'Metadata',
    function($http, $location, $timeout, gnUrlUtils, Metadata) {
      return {
        //TODO: rewrite calls with gnHttp

        /**
           * @ngdoc method
           * @name gnMetadataManager#remove
           * @methodOf gnMetadataManager
           *
           * @description
           * Delete a metadata from catalog
           *
           * @param {string} id Internal id of the metadata
           * @return {HttpPromise} Future object
           */
        remove: function(id) {
          return $http.delete('../api/records/' + id);
        },

        /**
         * @ngdoc method
         * @name gnMetadataManager#validate
         * @methodOf gnMetadataManager
         *
         * @description
         * Validate a metadata from catalog
         *
         * @param {string} id Internal id of the metadata
         * @return {HttpPromise} Future object
         */
        validate: function(id) {
          return $http.put('../api/records/' + id + '/validate/internal');
        },

        /**
         * @ngdoc method
         * @name gnMetadataManager#validateDirectoryEntry
         * @methodOf gnMetadataManager
         *
         * @description
         * Validate a directory entry (shared object) from catalog
         *
         * @param {string} id Internal id of the directory entry
         * @param {bool} newState true is validated, false is rejected
         * @return {HttpPromise} Future object
         */
        validateDirectoryEntry: function(id, newState) {
          var param = '?isvalid=' + (newState ? 'true' : 'false');
          return $http.put('../api/records/' + id + '/validate/internal' + param);
        },

        /**
           * @ngdoc method
           * @name gnMetadataManager#copy
           * @methodOf gnMetadataManager
           *
           * @description
           * Create a copy of a metadata. The copy will belong to the same group
           * of the original metadata and will be of the same type (isTemplate,
           * isChild, fullPrivileges).
           *
           * @param {string} id Internal id of the metadata to be copied.
           * @param {string} groupId Internal id of the group of the metadata
           * @param {boolean} withFullPrivileges privileges to assign.
           * @param {boolean|string} isTemplate type of the metadata (bool is
           *  for TEMPLATE, other values are SUB_TEMPLATE and
           *  TEMPLATE_OF_SUB_TEMPLATE)
           * @param {boolean} isChild is child of a parent metadata
           * @param {string} metadataUuid , the uuid of the metadata to create
           *                 (when metadata uuid is set to manual)
           * @param {boolean} hasCategoryOfSource copy categories from source
           * @return {HttpPromise} Future object
           */
        copy: function(id, groupId, withFullPrivileges,
            isTemplate, isChild, metadataUuid, hasCategoryOfSource) {
          // new md type determination
          var mdType;
          switch (isTemplate) {
            case 'TEMPLATE_OF_SUB_TEMPLATE':
              mdType = 'TEMPLATE_OF_SUB_TEMPLATE';
              break;

            case 'SUB_TEMPLATE':
              mdType = 'SUB_TEMPLATE';
              break;

            case 'TEMPLATE':
            case true:
              mdType = 'TEMPLATE';
              break;

            default: mdType = 'METADATA';
          }

          var url = gnUrlUtils.toKeyValue({
            metadataType: mdType,
            sourceUuid: id,
            isChildOfSource: isChild ? 'true' : 'false',
            group: groupId,
            isVisibleByAllGroupMembers: withFullPrivileges ? 'true' : 'false',
            targetUuid: metadataUuid || '',
            hasCategoryOfSource: hasCategoryOfSource ? 'true' : 'false'
          });
          return $http.put('../api/records/duplicate?' + url, {
            headers: {
              'Accept': 'application/json'
            }
          });
        },

        /**
         * @ngdoc method
         * @name gnMetadataManager#importFromXml
         * @methodOf gnMetadataManager
         *
         * @description
         * Import records from a xml string.
         *
         * @param {Object} data Params to send to md.insert service
         * @return {HttpPromise} Future object
         */
        importFromXml: function(urlParams, xml) {
          return $http.put('../api/records?' + urlParams, xml, {
            headers: {
              'Content-Type': 'application/xml'
            }
          });
        },

        /**
           * @ngdoc method
           * @name gnMetadataManager#create
           * @methodOf gnMetadataManager
           *
           * @description
           * Create a new metadata as a copy of an existing template.
           * Will forward to `copy` method.
           *
           * @param {string} id Internal id of the metadata to be copied.
           * @param {string} groupId Internal id of the group of the metadata
           * @param {boolean} withFullPrivileges privileges to assign.
           * @param {boolean} isTemplate type of the metadata
           * @param {boolean} isChild is child of a parent metadata
           * @param {string} tab is the metadata editor tab to open
           * @param {string} metadataUuid , the uuid of the metadata to create
           *                 (when metadata uuid is set to manual)
           * @param {boolean} hasCategoryOfSource copy categories from source
           * @return {HttpPromise} Future object
           */
        create: function(id, groupId, withFullPrivileges,
            isTemplate, isChild, tab, metadataUuid, hasCategoryOfSource) {

          return this.copy(id, groupId, withFullPrivileges,
              isTemplate, isChild, metadataUuid, hasCategoryOfSource)
              .success(function(id) {
                var path = '/metadata/' + id;
                if (tab) {
                  path += '/tab/' + tab;
                }
                $location.path(path)
                .search('justcreated')
                .search('redirectUrl', 'catalog.edit');
              });
        },

        /**
         * @ngdoc method
         * @name gnMetadataManager#getMdObjByUuid
         * @methodOf gnMetadataManager
         *
         * @description
         * Get the metadata js object from catalog. Trigger a search and
         * return a promise.
         * @param {string} uuid of the metadata
         * @param {string} isTemplate optional isTemplate value (s, t...)
         * @return {HttpPromise} of the $http get
         */
        getMdObjByUuid: function(uuid, isTemplate) {
          return $http.get('qi?_uuid=' + uuid + '' +
              '&fast=index&_content_type=json&buildSummary=false' +
              (isTemplate !== undefined ? '&isTemplate=' + isTemplate : '')).
              then(function(resp) {
                return new Metadata(resp.data.metadata);
              });
        },

        /**
         * @ngdoc method
         * @name gnMetadataManager#getMdObjById
         * @methodOf gnMetadataManager
         *
         * @description
         * Get the metadata js object from catalog. Trigger a search and
         * return a promise.
         * @param {string} id of the metadata
         * @param {string} isTemplate optional isTemplate value (s, t...)
         * @return {HttpPromise} of the $http get
         */
        getMdObjById: function(id, isTemplate) {
          return $http.get('q?_id=' + id + '' +
              '&fast=index&_content_type=json&buildSummary=false' +
              (isTemplate !== undefined ? '&_isTemplate=' + isTemplate : '')).
              then(function(resp) {
                return new Metadata(resp.data.metadata);
              });
        },

        /**
         * @ngdoc method
         * @name gnMetadataManager#updateMdObj
         * @methodOf gnMetadataManager
         *
         * @description
         * Update the metadata object
         *
         * @param {object} md to reload
         * @return {HttpPromise} of the $http get
         */
        updateMdObj: function(md) {
          return this.getMdObjByUuid(md.getUuid()).then(
              function(md_) {
                angular.extend(md, md_);
                return md;
              }
          );
        }
      };
    }
  ]);

  /**
   * @ngdoc service
   * @kind Object
   * @name gnHttpServices
   *
   * @description
   * The `gnHttpServices` service provides KVP for all geonetwork
   * services used in the UI.
   */

  module.value('gnHttpServices', {
    mdGetPDFSelection: 'pdf.selection.search', // TODO: CHANGE
    mdGetRDF: 'rdf.metadata.get',
    mdGetMEF: 'mef.export', // Deprecated service
    mdGetXML19139: 'xml_iso19139',
    csv: 'csv.search',

    publish: 'md.publish',
    unpublish: 'md.unpublish',

    processAll: 'md.processing.batch',
    processReport: 'md.processing.batch.report',
    processXml: 'xml.metadata.processing',

    suggest: 'suggest',

    search: 'q',
    internalSearch: 'qi',
    subtemplate: 'subtemplate',
    lang: 'lang?_content_type=json&',
    removeThumbnail: 'md.thumbnail.remove?_content_type=json&',
    removeOnlinesrc: 'resource.del.and.detach', // TODO: CHANGE
    suggest: 'suggest',
    facetConfig: 'search/facet/config',
    selectionLayers: 'selection.layers',

    featureindexproxy: '../../index/features',
    indexproxy: '../../index/records'
  });


  /**
   * @ngdoc service
   * @kind function
   * @name gnHttp
   * @requires $http
   * @requires gnHttpServices
   * @requires $location
   * @requires gnUrlUtils

   * @description
   * The `gnHttp` service extends `$http` service
   * for geonetwork usage. It is based on `gnHttpServices` to
   * get service url.
   */
  module.provider('gnHttp', function() {

    this.$get = ['$http', 'gnHttpServices' , '$location', 'gnUrlUtils',
      function($http, gnHttpServices, $location, gnUrlUtils) {

        var originUrl = this.originUrl = gnUrlUtils.urlResolve(
            window.location.href, true);

        var defaults = this.defaults = {
          host: originUrl.host,
          pathname: originUrl.pathname,
          protocol: originUrl.protocol
        };

        var urlSplit = originUrl.pathname.split('/');
        if (urlSplit.lenght < 3) {
          //TODO manage error
        }
        else {
          angular.extend(defaults, {
            webapp: urlSplit[1],
            srv: urlSplit[2],
            lang: urlSplit[3]
          });
        }
        return {

          /**
           * @ngdoc method
           * @name gnHttp#callService
           * @methodOf gnHttp
           *
           * @description
           * Calls a geonetwork service with given parameters
           * and an httpConfig
           * (that will be handled by `$http#get` method).
           *
           * @param {string} serviceKey key of the service to
           * get the url from `gnHttpServices`
           * @param {Object} params to add to the request
           * @param {Object} httpConfig see httpConfig of
           * $http#get method
           * @return {HttpPromise} Future object
           */
          callService: function(serviceKey, params, httpConfig) {

            var config = {
              url: gnHttpServices[serviceKey] || serviceKey,
              params: params,
              method: 'GET'
            };
            angular.extend(config, httpConfig);
            return $http(config);
          },

          /**
           * Return service url for a given key
           * @param {string} serviceKey
           * @return {*}
           */
          getService: function(serviceKey) {
            return gnHttpServices[serviceKey];
          }
        };
      }];
  });

  /**
   * @ngdoc service
   * @kind Object
   * @name gnConfig
   *
   * @description
   * The `gnConfig` service provides KVP for all geonetwork
   * configuration settings that can be managed
   * in administration UI.
   * The `key` Object contains shortcut to full settings path.
   * The value are set in the `gnConfig` object.
   *
   * @example
     <code>
      {
        key: {
          isXLinkEnabled: 'system.xlinkResolver.enable',
          isSelfRegisterEnabled: 'system.userSelfRegistration.enable',
          isFeedbackEnabled: 'system.userFeedback.enable',
          isInspireEnabled: 'system.inspireValidation.enable',
          isRatingUserFeedbackEnabled: 'system.localratinguserfeedback.enable',
          isSearchStatEnabled: 'system.searchStats.enable',
          isHideWithHelEnabled: 'system.hidewithheldelements.enable'
        },
        isXLinkEnabled: true,
        system.server.host: 'localhost'

      }
     </code>
   */
  module.value('gnConfig', {
    key: {
      isXLinkEnabled: 'system.xlinkResolver.enable',
      isXLinkLocal: 'system.xlinkResolver.localXlinkEnable',
      isSelfRegisterEnabled: 'system.userSelfRegistration.enable',
      isFeedbackEnabled: 'system.userFeedback.enable',
      isInspireEnabled: 'system.inspire.enable',
      isRatingUserFeedbackEnabled: 'system.localrating.enable',
      isSearchStatEnabled: 'system.searchStats.enable',
      isHideWithHelEnabled: 'system.hidewithheldelements.enable'
    },
    'map.is3DModeAllowed': window.location.search.indexOf('with3d') !== -1
  });

  /**
   * @ngdoc service
   * @kind function
   * @name gnConfigService
   * @requires $q
   * @requires gnHttp
   * @requires gnConfig
   *
   * @description
   * Load the catalog config and push it to gnConfig.
   */
  module.factory('gnConfigService', [
    '$http', '$q',
    'gnConfig',
    function($http, $q, gnConfig) {
      var defer = $q.defer();
      var loadPromise = defer.promise;
      return {

        /**
         * @ngdoc method
         * @name gnConfigService#load
         * @methodOf gnConfigService
         *
         * @description
         * Get catalog configuration. The config is cached.
         * Boolean value are parsed to boolean.
         *
         * @return {HttpPromise} Future object
         */
        load: function() {
          return $http.get('../api/site/settings', {cache: true})
              .then(function(response) {
                angular.extend(gnConfig, response.data);
                // Replace / by . in settings name
                angular.forEach(gnConfig, function(value, key) {
                  if (key.indexOf('/') !== -1) {
                    gnConfig[key.replace(/\//g, '.')] = value;
                    delete gnConfig[key];
                  }
                });
                // Override parameter if set in URL
                if (window.location.search.indexOf('with3d') !== -1) {
                  gnConfig['map.is3DModeAllowed'] = true;
                }
                defer.resolve(gnConfig);
              }, function() {
                defer.reject();
              });
        },
        loadPromise: loadPromise,

        /**
         * @ngdoc method
         * @name gnConfigService#getServiceURL
         * @methodOf gnConfigService
         *
         * @description
         * Get service URL from configuration settings.
         * It is used by `gnHttp`service.
         *
         * @return {String} service url.
         */
        getServiceURL: function(useDefaultNode) {
          var port = '';
          if (gnConfig['system.server.protocol'] === 'http' &&
             gnConfig['system.server.port'] &&
             gnConfig['system.server.port'] != null &&
             gnConfig['system.server.port'] != 80) {

            port = ':' + gnConfig['system.server.port'];

          } else if (gnConfig['system.server.protocol'] === 'https' &&
             gnConfig['system.server.securePort'] &&
             gnConfig['system.server.securePort'] != null &&
             gnConfig['system.server.securePort'] != 443) {

            port = ':' + gnConfig['system.server.securePort'];

          }

          var node = (!useDefaultNode?
            gnConfig.env.node:gnConfig.env.defaultNode);

          var url = gnConfig['system.server.protocol'] + '://' +
              gnConfig['system.server.host'] + port +
              gnConfig.env.baseURL + '/' +
              node + '/';
          return url;
        }
      };
    }]);

  /**
   * @ngdoc service
   * @kind function
   * @name Metadata
   *
   * @description
   * The `Metadata` service is a metadata wrapper from the jeeves
   * json output of the search service. It also provides some functions
   * on the metadata.
   */
  module.factory('Metadata', function() {
    function Metadata(k) {
      $.extend(true, this, k);
      var listOfArrayFields = ['topicCat', 'category', 'keyword',
        'securityConstraints', 'resourceConstraints', 'legalConstraints',
        'denominator', 'resolution', 'geoDesc', 'geoBox', 'inspirethemewithac',
        'status', 'status_text', 'crs', 'identifier', 'responsibleParty',
        'mdLanguage', 'datasetLang', 'type', 'link', 'crsDetails',
        'creationDate', 'publicationDate', 'revisionDate', 'spatialRepresentationType_text', 'creator_dataset','metadataProvider_dataset','contact_dataset','associatedParty_dataset',
        'coordinationTeam_vre','containServices_vre','containOperations_service','taxonomicClassification_taxonomicCoverage_coverage_dataset','personnelProject_dataset',
        'methodStep_dataset','datatable_dataset','sampling_methods_dataset','author_vre','maintainer_vre','keyword_keywordSet_dataset',
        'author_service','maintainer_service','keywords_service','tags_service','relatedServices_service','requiredServices_service',
        'otherLanguage_service', 'publicationsAboutThisVRE_vre'];
      var listOfJsonFields = ['keywordGroup', 'crsDetails'];
      // See below; probably not necessary
      var record = this;
      this.linksCache = [];
      $.each(listOfArrayFields, function(idx) {
        var field = listOfArrayFields[idx];
        if (angular.isDefined(record[field]) &&
            !angular.isArray(record[field])) {
          record[field] = [record[field]];
        }
      });
      // Note: this step does not seem to be necessary; TODO: remove or refactor
      $.each(listOfJsonFields, function(idx) {
        var fieldName = listOfJsonFields[idx];
        if (angular.isDefined(record[fieldName])) {
          try {
            record[fieldName] = angular.fromJson(record[fieldName]);
            var field = record[fieldName];

            // Combine all document keywordGroup fields
            // in one object. Applies to multilingual records
            // which may have multiple values after combining
            // documents from all index
            // fixme: not sure how to precess this, take first array as main
            // object or take last arrays when they appear (what is done here)
            if (fieldName === 'keywordGroup' && angular.isArray(field)) {
              var thesaurusList = {};
              for (var i = 0; i < field.length; i++) {
                var thesauri = field[i];
                $.each(thesauri, function(key) {
                  if (!thesaurusList[key] && thesauri[key].length)
                    thesaurusList[key] = thesauri[key];
                });
              }
              record[fieldName] = thesaurusList;
            }
          } catch (e) {}
        }
      }.bind(this));

      // Create a structure that reflects the transferOption/onlinesrc tree
      var links = [];
      angular.forEach(this.link, function(link) {
        var linkInfo = formatLink(link);
        var idx = linkInfo.group - 1;
        if (!links[idx]) {
          links[idx] = [linkInfo];
        }
        else if (angular.isArray(links[idx])) {
          links[idx].push(linkInfo);
        }
      });
      this.linksTree = links;
    };

    function formatLink(sLink) {
      var linkInfos = sLink.split('|');
      return {
        name: linkInfos[0],
        title: linkInfos[0],
        url: linkInfos[2],
        desc: linkInfos[1],
        protocol: linkInfos[3],
        contentType: linkInfos[4],
        group: linkInfos[5] ? parseInt(linkInfos[5]) : undefined,
        applicationProfile: linkInfos[6]
      };
    }
    function parseLink(sLink) {

    };

    Metadata.prototype = {
      getUuid: function() {
        return this['geonet:info'].uuid;
      },
      getId: function() {
        return this['geonet:info'].id;
      },
      getTitle: function() {
        return this.title || this.defaultTitle;
      },
      isPublished: function() {
        return this['geonet:info'].isPublishedToAll === 'true';
      },
      isValid: function() {
        return this.valid === '1';
      },
      hasValidation: function() {
        return (this.valid > -1);
      },
      isOwned: function() {
        return this['geonet:info'].owner === 'true';
      },
      getOwnerId: function() {
        return this['geonet:info'].ownerId;
      },
      getGroupOwner: function() {
        return this['geonet:info'].owner;
      },
      getSchema: function() {
        return this['geonet:info'].schema;
      },
      publish: function() {
        this['geonet:info'].isPublishedToAll = this.isPublished() ?
            'false' : 'true';
      },

      getLinks: function() {
        return this.link;
      },
      getLinkGroup: function(layer) {
        var links = this.getLinksByType('OGC');
        for (var i = 0; i < links.length; ++i) {
          var link = links[i];
          if (link.name == layer.getSource().getParams().LAYERS) {
            return link.group;
          }
        }
      },
      /**
       * Get all links of the metadata of the given types.
       * The types are strings in arguments.
       * You can give the exact matching with # ('#OG:WMS') or just find an
       * occurence for the match ('OGC').
       * You can passe several types to find ('OGC','WFS', '#getCapabilities')
       *
       * If the first argument is a number, you do the search within the link
       * group (search only onlinesrc in the given transferOptions).
       *
       * @return {*} an Array of links
       */
      getLinksByType: function() {
        var ret = [];

        var types = Array.prototype.splice.call(arguments, 0);
        var groupId;

        var key = types.join('|');
        if (angular.isNumber(types[0])) {
          groupId = types[0];
          types.splice(0, 1);
        }
        if (this.linksCache[key] && !groupId) {
          return this.linksCache[key];
        }
        angular.forEach(this.link, function(link) {
          var linkInfo = formatLink(link);
          if (types.length > 0) {
            types.forEach(function(type) {
              if (type.substr(0, 1) == '#') {
                if (linkInfo.protocol == type.substr(1, type.length - 1) &&
                    (!groupId || groupId == linkInfo.group)) {
                  ret.push(linkInfo);
                }
              }
              else {
                if (linkInfo.protocol.toLowerCase().indexOf(
                    type.toLowerCase()) >= 0 &&
                    (!groupId || groupId == linkInfo.group)) {
                  ret.push(linkInfo);
                }
              }
            });
          } else {
            ret.push(linkInfo);
          }
        });
        this.linksCache[key] = ret;
        return ret;
      },
      getThumbnails: function() {
        var images = {list: []};
        if (angular.isArray(this.image)) {
          for (var i = 0; i < this.image.length; i++) {
            var s = this.image[i].split('|');
            var insertFn = 'push';
            if (s[0] === 'thumbnail') {
              images.small = s[1];
              var insertFn = 'unshift';
            } else if (s[0] === 'overview') {
              images.big = s[1];
            }

            //Is it a draft?
            if( s[1].indexOf("/api/records/") >= 0
                &&  s[1].indexOf("/api/records/")<  s[1].indexOf("/attachments/")) {
              s[1] += "?approved=" + (this.draft != 'y');
            }


            images.list[insertFn]({url: s[1], label: s[2]});
          }
        } else if (angular.isDefined(this.image)){
          var s = this.image.split('|');
          images.list.push({url: s[1], label: s[2]});
        }
        return images;
      },
      /**
       * Return an object containing metadata contacts
       * as an array and resource contacts as array
       *
       * @return {{metadata: Array, resource: Array}}
       */
      getAllContacts: function() {
        if (angular.isUndefined(this.allContacts) &&
            angular.isDefined(this.responsibleParty)) {
          this.allContacts = {metadata: [], resource: []};
          for (var i = 0; i < this.responsibleParty.length; i++) {
            var s = this.responsibleParty[i].split('|');
            var contact = {
              role: s[0] || '',
              org: s[2] || '',
              logo: s[3] || '',
              email: s[4] || '',
              name: s[5] || '',
              position: s[6] || '',
              address: s[7] || '',
              phone: s[8] || '',
              website: s[11] || ''
            };
            if (s[1] === 'resource') {
              this.allContacts.resource.push(contact);
            } else if (s[1] === 'metadata') {
              this.allContacts.metadata.push(contact);
            }
          }
        }
        return this.allContacts;
      },
      // LifeWatch Coordination Teams - VRE      
      getAllCoordinationTeams_vre: function() {    	  
        if (angular.isUndefined(this.allCoordinationTeams_vre) &&
        	angular.isDefined(this.coordinationTeam_vre)) {
        	this.allCoordinationTeams_vre =	{metadata: []};
            for (var i = 0; i < this.coordinationTeam_vre.length; i++) {
        	  var s = this.coordinationTeam_vre[i].split('|');
      	  	  var coordinationTeam = {
      	  			contactPoint_vre: s[0] || '',
      	  			address_vre: s[1] || '',
      	  			e_mail_vre: s[2] || ''      	  			
      	  	  };
                this.allCoordinationTeams_vre.metadata.push(coordinationTeam);
            }
        }
        return this.allCoordinationTeams_vre;
      },   
      // LifeWatch Contain Services - VRE         
      getAllContainServices_vre: function() {    	  
        if (angular.isUndefined(this.allContainServices_vre) &&
        	angular.isDefined(this.containServices_vre)) {
        	this.allContainServices_vre =	{metadata: []};
            for (var i = 0; i < this.containServices_vre.length; i++) {
        	  var s = this.containServices_vre[i].split('|');
      	  	  var containServices = {
      	  			serviceName_vre: s[0] || '',
      	  			serviceDescription_vre: s[1] || '',
      	  			serviceReference_vre: s[2] || ''      	  			
      	  	  };
                this.allContainServices_vre.metadata.push(containServices);
            }
        }
        return this.allContainServices_vre;
      },
      /** LifeWatch Publications - VRE
       * Return an object containing metadata Publications
       * as an array and resource tag as array
       *
       * @return {{metadata: Array}}
       */
      getAllPublications_vre: function() {    	  
        if (angular.isUndefined(this.allPublications_vre) &&
        	angular.isDefined(this.publicationsAboutThisVRE_vre)) {
        	this.allPublications_vre =	{metadata: []};                    	
            for (var i = 0; i < this.publicationsAboutThisVRE_vre.length; i++) {
                var s = this.publicationsAboutThisVRE_vre[i].split('--');                    
                var publication = {
                		publicationsAboutThisVRE_vre: s[0] || ''                   
                };                  
                this.allPublications_vre.metadata.push(publication);
            }
        }
        return this.allPublications_vre;
      },
      /** LifeWatch Authors - VRE
       * Return an object containing metadata Authors
       * as an array and resource author as array
       *
       * @return {{metadata: Array}}
       */
      getAllAuthors_vre: function() {    	  
        if (angular.isUndefined(this.allAuthors_vre) &&
        	angular.isDefined(this.author_vre)) {
        	this.allAuthors_vre = {metadata: []};                    	
            for (var i = 0; i < this.author_vre.length; i++) {
                var s = this.author_vre[i].split('--');                    
                var author = {
                    author_vre: s[0] || ''                   
                };                  
                this.allAuthors_vre.metadata.push(author);
            }
        }
        return this.allAuthors_vre;
      }, 
        
      /** LifeWatch Maintainers - VRE
       * Return an object containing metadata Maintainers
       * as an array and resource maintainer as array
       *
       * @return {{metadata: Array}}
       */
      getAllMaintainers_vre: function() {    	  
        if (angular.isUndefined(this.allMaintainers_vre) &&
        	angular.isDefined(this.maintainer_vre)) {
        	this.allMaintainers_vre = {metadata: []};                    	
            for (var i = 0; i < this.maintainer_vre.length; i++) {
                var s = this.maintainer_vre[i].split('--');                    
                var maintainer = {
                    maintainer_vre: s[0] || ''                   
                };                  
                this.allMaintainers_vre.metadata.push(maintainer);
            }
        }
        return this.allMaintainers_vre;
      },
      /** LifeWatch ContainOperations - Service
       * Return an object containing metadata ContainOperations
       * as an array and resource containOperation as array
       *
       * @return {{metadata: Array}}
       */     
      getAllContainOperations_service: function() {    	  
        if (angular.isUndefined(this.allContainOperations_service) &&
        	angular.isDefined(this.containOperations_service)) {
        	this.allContainOperations_service =	{metadata: []};
            for (var i = 0; i < this.containOperations_service.length; i++) {
        	  var s = this.containOperations_service[i].split('|');
      	  	  var containOperations = {
      	          operationName_service: s[0] || '',
                  webSite_service: s[1] || '',
                  protocol_service: s[2] || '',
                  descriptionOperation_service: s[3] || '',
                  function_service: s[4] || ''
      	  	  };
                this.allContainOperations_service.metadata.push(containOperations);
            }
        }
        return this.allContainOperations_service;
      },  
      /** LifeWatch Authors - Service
       * Return an object containing metadata Authors
       * as an array and resource author as array
       *
       * @return {{metadata: Array}}
       */
      getAllAuthors_service: function() {    	  
        if (angular.isUndefined(this.allAuthors_service) &&
        	angular.isDefined(this.author_service)) {
        	this.allAuthors_service =	{metadata: []};                    	
            for (var i = 0; i < this.author_service.length; i++) {
                var s = this.author_service[i].split('--');
                var author = {
                    author_service: s[0] || ''                   
                };                  
                this.allAuthors_service.metadata.push(author);
            }
        }
        return this.allAuthors_service;
      },
      /** LifeWatch Maintainers - Service
       * Return an object containing metadata Maintainers
       * as an array and resource maintainer as array
       *
       * @return {{metadata: Array}}
       */
      getAllMaintainers_service: function() {    	  
        if (angular.isUndefined(this.allMaintainers_service) &&
        	angular.isDefined(this.maintainer_service)) {
        	this.allMaintainers_service =	{metadata: []};                    	
            for (var i = 0; i < this.maintainer_service.length; i++) {
                var s = this.maintainer_service[i].split('--');                    
                var maintainer = {
                    maintainer_service: s[0] || ''                   
                };                  
                this.allMaintainers_service.metadata.push(maintainer);
            }
        }
        return this.allMaintainers_service;
      },    
      /** LifeWatch Keywords - Service
       * Return an object containing metadata Keywords
       * as an array and resource keyword as array
       *
       * @return {{metadata: Array}}
       */
      getAllKeywords_service: function() {    	  
        if (angular.isUndefined(this.allKeywords_service) &&
        	angular.isDefined(this.keywords_service)) {
        	this.allKeywords_service =	{metadata: []};                    	
            for (var i = 0; i < this.keywords_service.length; i++) {
                var s = this.keywords_service[i].split('--');                    
                var keyword = {
                    keyword_service: s[0] || ''                   
                };                  
                this.allKeywords_service.metadata.push(keyword);
            }
        }
        return this.allKeywords_service;
      }, 
     /** LifeWatch Tags - Service
       * Return an object containing metadata Tags
       * as an array and resource tag as array
       *
       * @return {{metadata: Array}}
       */
      getAllTags_service: function() {    	  
          if (angular.isUndefined(this.allTags_service) &&
          	angular.isDefined(this.tags_service)) {
          	this.allTags_service =	{metadata: []};                    	
              for (var i = 0; i < this.tags_service.length; i++) {
                  var s = this.tags_service[i].split('--');                    
                  var tag = {
                      tag_service: s[0] || ''                   
                  };                  
                  this.allTags_service.metadata.push(tag);
              }
          }
          return this.allTags_service;
        },
      /** LifeWatch OtherLanguage - Service
       * Return an object containing metadata OtherLanguage
       * as an array and resource tag as array
       *
       * @return {{metadata: Array}}
       */
      getAllOtherLanguages_service: function() {    	  
        if (angular.isUndefined(this.allOtherLanguages_service) &&
        	angular.isDefined(this.otherLanguage_service)) {
        	this.allOtherLanguages_service =	{metadata: []};  
            for (var i = 0; i < this.otherLanguage_service.length; i++) {
                var s = this.otherLanguage_service[i].split('--');                    
                var otherLanguage = {
                		otherLanguage_service: s[0] || ''                   
                };                  
                this.allOtherLanguages_service.metadata.push(otherLanguage);
            }
        }
        return this.allOtherLanguages_service;
      },
      /** LifeWatch RelatedServices - Service
       * Return an object containing metadata RelatedServices
       * as an array and relatedServices as array
       *
       * @return {{metadata: Array}}
       */
      getAllRelatedServices_service: function() {    	  
        if (angular.isUndefined(this.allRelatedServices_service) &&
        	angular.isDefined(this.relatedServices_service)) {
        	this.allRelatedServices_service =	{metadata: []};                    	
            for (var i = 0; i < this.relatedServices_service.length; i++) {
                var s = this.relatedServices_service[i].split('--');                    
                var relatedServices = {
                    relatedServices_service: s[0] || ''                   
                };                  
                this.allRelatedServices_service.metadata.push(relatedServices);
            }
        }
        return this.allRelatedServices_service;
      },      
    /** LifeWatch RequiredServices - Service
       * Return an object containing metadata RequiredServices
       * as an array and requiredServices as array
       *
       * @return {{metadata: Array}}
       */
      getAllRequiredServices_service: function() {    	  
        if (angular.isUndefined(this.allRequiredServices_service) &&
        	angular.isDefined(this.requiredServices_service)) {
        	this.allRequiredServices_service =	{metadata: []};                    	
            for (var i = 0; i < this.requiredServices_service.length; i++) {
                var s = this.requiredServices_service[i].split('--');                    
                var requiredServices = {
                    requiredServices_service: s[0] || ''                   
                };                  
                this.allRequiredServices_service.metadata.push(requiredServices);
            }
        }
        return this.allRequiredServices_service;
      },
      /** LifeWatch Keywords - Dataset
       * Return an object containing metadata Keyword
       * as an array and resource keywords as array
       *
       * @return {{metadata: Array}}
       */
      getAllKeywords_dataset: function() {   
        if (angular.isUndefined(this.allKeywords_dataset) &&
        	angular.isDefined(this.keyword_keywordSet_dataset)) {
        	this.allKeywords_dataset =	{metadata: []};
            for (var j = 0; j < this.keyword_keywordSet_dataset.length; j++) { 
            	var keyword_attr = this.keyword_keywordSet_dataset[j].split('--');
                var list_of_keyword = {
                		keyword_keywordSet_dataset: keyword_attr[0] || ''   
                };     
                this.allKeywords_dataset.metadata.push(list_of_keyword);
            } 
        }
        return this.allKeywords_dataset;
      }, 
       /** LifeWatch Creator - Dataset
       * Return an object containing metadata Creator
       * as an array and resource creators as array
       *
       * @return {{metadata: Array}}
       */
      getAllCreators_dataset: function() {
    	  
        if (angular.isUndefined(this.allCreators_dataset) &&
        	angular.isDefined(this.creator_dataset)) {
        	this.allCreators_dataset =	{metadata: []};
          for (var i = 0; i < this.creator_dataset.length; i++) {
        	  var s = this.creator_dataset[i].split('|');
      	  	var creator = {
      	  			id_creator_dataset: s[0] || '',
      	  			givenName_individualName_creator_dataset: s[1] || '',
      	  			surName_individualName_creator_dataset: s[2] || '',
      	  			organizationName_creator_dataset: s[3] || '',
      	  			electronicMailAddress_creator_dataset: s[4] || '',
      	  			userId_creator_dataset: s[5] || '',
      	  			references_creator_dataset: s[6] || ''
      	  	};
            this.allCreators_dataset.metadata.push(creator);
          }
        }
        return this.allCreators_dataset;
      },
      /** LifeWatch MetadataProvider - Dataset
       * Return an object containing metadata Creator
       * as an array and resource creators as array
       *
       * @return {{metadata: Array}}
       */
      getAllMetadataProviders_dataset: function() {
    	  
        if (angular.isUndefined(this.allMetadataProviders_dataset) &&
        	angular.isDefined(this.metadataProvider_dataset)) {
        	this.allMetadataProviders_dataset =	{metadata: []};
          for (var i = 0; i < this.metadataProvider_dataset.length; i++) {
        	  var s = this.metadataProvider_dataset[i].split('|');
      	  	var metadataProvider = {
      	  			id_metadataProvider_dataset: s[0] || '',
      	  			system_metadataProvider_dataset: s[1] || '',
      	  			scope_metadataProvider_dataset: s[2] || '',
      	  			givenName_individualName_metadataProvider_dataset: s[3] || '',
      	  			surName_individualName_metadataProvider_dataset: s[4] || '',
      	  			organizationName_metadataProvider_dataset: s[5] || '',
      	  			electronicMailAddress_metadataProvider_dataset: s[6] || '',
      	  			references_metadataProvider_dataset: s[7] || ''
      	  	};
            this.allMetadataProviders_dataset.metadata.push(metadataProvider);
          }
        }
        return this.allMetadataProviders_dataset;
      },
      /** LifeWatch Contact - Dataset
       * Return an object containing metadata Creator
       * as an array and resource creators as array
       *
       * @return {{metadata: Array}}
       */
      getAllContacts_dataset: function() {
    	  
        if (angular.isUndefined(this.allContacts_dataset) &&
        	angular.isDefined(this.contact_dataset)) {
        	this.allContacts_dataset =	{metadata: []};
          for (var i = 0; i < this.contact_dataset.length; i++) {
        	  var s = this.contact_dataset[i].split('|');
      	  	var contact = {
      	  			id_contact_dataset: s[0] || '',
      	  			system_contact_dataset: s[1] || '',
      	  			scope_contact_dataset: s[2] || '',
      	  			givenName_individualName_contact_dataset: s[3] || '',
      	  			surName_individualName_contact_dataset: s[4] || '',
      	  			organizationName_contact_dataset: s[5] || '',
      	  			electronicMailAddress_contact_dataset: s[6] || '',
      	  			references_contact_dataset: s[7] || ''
      	  	};
            this.allContacts_dataset.metadata.push(contact);
          }
        }
        return this.allContacts_dataset;
      },   
      /** LifeWatch AssociatedParty - Dataset
       * Return an object containing metadata Creator
       * as an array and resource creators as array
       *
       * @return {{metadata: Array}}
       */
      getAllAssociatedParties_dataset: function() {
    	  
        if (angular.isUndefined(this.allAssociatedParties_dataset) &&
        	angular.isDefined(this.associatedParty_dataset)) {
        	this.allAssociatedParties_dataset =	{metadata: []};
          for (var i = 0; i < this.associatedParty_dataset.length; i++) {
        	  var s = this.associatedParty_dataset[i].split('|');
      	  	var associatedParty = {
      	  			id_associatedParty_dataset: s[0] || '',
      	  			system_associatedParty_dataset: s[1] || '',
      	  			scope_associatedParty_dataset: s[2] || '',
      	  			givenName_individualName_associatedParty_dataset: s[3] || '',
      	  			surName_individualName_associatedParty_dataset: s[4] || '',
      	  			organizationName_associatedParty_dataset: s[5] || '',
      	  			electronicMailAddress_associatedParty_dataset: s[6] || ''
      	  	};
            this.allAssociatedParties_dataset.metadata.push(associatedParty);
          }
        }
        return this.allAssociatedParties_dataset;
      },
      /** LifeWatch TaxonomicCoverage - Dataset
       * Return an object containing metadata Creator
       * as an array and resource creators as array
       *
       * @return {{metadata: Array}}
       */
      getAllTaxonomicCoverages_dataset: function() {
    	  
        if (angular.isUndefined(this.allTaxonomicCoverages_dataset) &&
        	angular.isDefined(this.taxonomicClassification_taxonomicCoverage_coverage_dataset)) {
        	this.allTaxonomicCoverages_dataset =	{metadata: []};
          for (var i = 0; i < this.taxonomicClassification_taxonomicCoverage_coverage_dataset.length; i++) {
        	  var s = this.taxonomicClassification_taxonomicCoverage_coverage_dataset[i].split('|');
      	  	var taxonomicClassification_taxonomicCoverage_coverage = {
      	  			taxonID_taxonomicClassification_taxonomicCoverage_coverage_dataset: s[0] || '',
      	  			taxonRankName_taxonomicClassification_taxonomicCoverage_coverage_dataset: s[1] || '',
      	  			taxonRankValue_taxonomicClassification_taxonomicCoverage_coverage_dataset: s[2] || '',
      	  			commonName_taxonomicClassification_taxonomicCoverage_coverage_dataset: s[3] || ''
      	  	};
            this.allTaxonomicCoverages_dataset.metadata.push(taxonomicClassification_taxonomicCoverage_coverage);
          }
        }
        return this.allTaxonomicCoverages_dataset;
      },
      /** LifeWatch ProjectPersonnel - Dataset
       * Return an object containing metadata ProjectPersonnel
       * as an array and resource projectPersonnel as array
       *
       * @return {{metadata: Array}}
       */
      getAllProjectPersonnel_dataset: function() {    	  
        if (angular.isUndefined(this.allProjectPersonnel_dataset) &&
        	angular.isDefined(this.personnelProject_dataset)) {
        	this.allProjectPersonnel_dataset =	{metadata: []};
            for (var i = 0; i < this.personnelProject_dataset.length; i++) {
        	  var s = this.personnelProject_dataset[i].split('|');
      	  	  var personnelProject = {
      	          individualName_personnel_project_dataset: s[0] || '',
                  positionName_personnel_project_dataset: s[1] || '',
                  name_organization_personnel_project_dataset: s[2] || ''
      	  	  };
                this.allProjectPersonnel_dataset.metadata.push(personnelProject);
            }
        }
        return this.allProjectPersonnel_dataset;
      }, 
      /** LifeWatch MethodStep - Dataset
       * Return an object containing metadata MethodStep
       * as an array and resource methodStep as array
       *
       * @return {{metadata: Array}}
       */
      getAllMethodSteps_dataset: function() {    	  
        if (angular.isUndefined(this.allMethodSteps_dataset) &&
        	angular.isDefined(this.methodStep_dataset)) {
        	this.allMethodSteps_dataset =	{metadata: []};
                    	
            for (var i = 0; i < this.methodStep_dataset.length; i++) {
                var s = this.methodStep_dataset[i].split('|');              
                var para = s[0];
                var bibtex = s[1];
                var instrument = s[2];
                var sw = s[3];
                var instr_attr = instrument.split('--');  
                var arrayInstr  = new Array();
                for (var j = 0; j < instr_attr.length-1; j++) {       
                    var list_of_instr = {
                    		instrumentation_methodStep_methods_dataset: instr_attr[j] || ''   
                    }     
                    arrayInstr.push(list_of_instr);
                }
                var sw_attr = sw.split('^');  
                var arrayInterno  = new Array();
                for (var j = 0; j < sw_attr.length-1; j++) {  
                    var sw_internal_att = sw_attr[j].split('--');
                    for (var k = 0; k < sw_internal_att.length; k++) {             
                         var list_of_sw = {
                            title_software_methodStep_methods_dataset: sw_internal_att[0] || '',
                            references_software_methodStep_methods_dataset: sw_internal_att[1] || ''
                         } 
                    }     
                    arrayInterno.push(list_of_sw);
                }
                var methodStep = {
                    para_description_methodStep_methods_dataset: para || '',
                    bibtex_citation_methodStep_methods_dataset: bibtex || '',
                    instrumentation_methodStep_methods_dataset: arrayInstr || '',
                    software_methodStep_methods_dataset: arrayInterno || ''
                };                  
                this.allMethodSteps_dataset.metadata.push(methodStep);
            }
        }
        return this.allMethodSteps_dataset;
      }, 
      /** LifeWatch Samplings - Dataset
       * Return an object containing metadata Samplings
       * as an array and resource samplings as array
       *
       * @return {{metadata: Array}}
       */
      getAllSamplings_dataset: function() {   
        if (angular.isUndefined(this.allSamplings_dataset) &&
        	angular.isDefined(this.sampling_methods_dataset)) {
        	this.allSamplings_dataset =	{metadata: []};
            for (var j = 0; j < this.sampling_methods_dataset.length; j++) { 
            	var sampling_attr = this.sampling_methods_dataset[j].split('--');
                var list_of_sampling = {
                	para_samplingDescription_sampling_methods_dataset: sampling_attr[0] || ''   
                };     
                this.allSamplings_dataset.metadata.push(list_of_sampling);
            } 
        }
        return this.allSamplings_dataset;
      }, 
      /** LifeWatch Datatable - Dataset
       * Return an object containing metadata Datatable
       * as an array and resource datatable as array
       *
       * @return {{metadata: Array}}
       */
      getAllDatatables_dataset: function() {    	  
        if (angular.isUndefined(this.allDatatables_dataset) &&
        	angular.isDefined(this.datatable_dataset)) {
        	this.allDatatables_dataset =	{metadata: []};              	
            for (var i = 0; i < this.datatable_dataset.length; i++) {
                var s = this.datatable_dataset[i].split('|');              
                var entityName = s[0];
                var formatName = s[1];
                var attributeList = s[2];            
                var attributeList_attr = attributeList.split('^');  
                var arrayInterno  = new Array();
                for (var j = 0; j < attributeList_attr.length-1; j++) {  
                    var attributeList_internal_att = attributeList_attr[j].split('--');
                    //alert(attributeList_attr);
                    for (var k = 0; k < attributeList_internal_att.length; k++) {    
                    	var arrayInterno2  = new Array(); 
                    	var attributeAnnotation = attributeList_internal_att[5].split('°°');
                    	for (var x = 0; x < attributeAnnotation.length-1; x++) {  
                            var attributeList_internal_annotation = attributeAnnotation[x].split('##');
                            var list_of_annotation = {
                            	propertyURI_attributeAnnotation_attributeList_datatable_dataset: attributeList_internal_annotation[0] || '',
                                valueURI_attributeAnnotation_attributeList_datatable_dataset: attributeList_internal_annotation[1] || ''
                            };
                            arrayInterno2.push(list_of_annotation); 	
                        }
                    	var list_of_aL = {
                        	attributeName_attributeList_datatable_dataset: attributeList_internal_att[0] || '',
                        	attributeLabel_attributeList_datatable_dataset: attributeList_internal_att[1] || '',
                        	attributeDefinition_attributeList_datatable_dataset: attributeList_internal_att[2] || '',
                        	standardUnit_unit_ratio_measurementScale_attributeList_datatable_dataset: attributeList_internal_att[3] || '',
                        	code_missingValueCode_attributeList_datatable_dataset: attributeList_internal_att[4] || '',
                        	attributeAnnotation_attributeList_datatable_dataset: arrayInterno2 || ''
                         };
                    }     
                    arrayInterno.push(list_of_aL);
                }
                var dataTable = {
                	entityName_datatable_dataset: entityName || '',
                    formatName_externallyDefinedFormat_dataFormat_physical_datatable_dataset: formatName || '',
                    attributeList_datatable_dataset: arrayInterno || ''
                };                  
                this.allDatatables_dataset.metadata.push(dataTable);
            }
        }
        return this.allDatatables_dataset;
      }, 
      /**
       * Deprecated. Use getAllContacts instead
       */
      getContacts: function() {
        var ret = {};
        if (angular.isArray(this.responsibleParty)) {
          for (var i = 0; i < this.responsibleParty.length; i++) {
            var s = this.responsibleParty[i].split('|');
            if (s[1] === 'resource') {
              ret.resource = s[2];
            } else if (s[1] === 'metadata') {
              ret.metadata = s[2];
            }
          }
        }
        return ret;
      },
      getBoxAsPolygon: function(i) {
        // Polygon((4.6810%2045.9170,5.0670%2045.9170,5.0670%2045.5500,4.6810%2045.5500,4.6810%2045.9170))
        var bboxes = [];
        if (this.geoBox[i]) {
          var coords = this.geoBox[i].split('|');
          return 'Polygon((' +
              coords[0] + ' ' +
              coords[1] + ',' +
              coords[2] + ' ' +
              coords[1] + ',' +
              coords[2] + ' ' +
              coords[3] + ',' +
              coords[0] + ' ' +
              coords[3] + ',' +
              coords[0] + ' ' +
              coords[1] + '))';
        } else {
          return null;
        }
      },
      getOwnername: function() {
        if (this.userinfo) {
          var userinfo = this.userinfo.split('|');
          try {
            if (userinfo[2] !== userinfo[1]) {
              return userinfo[2] + ' ' + userinfo[1];
            } else {
              return userinfo[1];
            }
          } catch (e) {
            return '';
          }
        } else {
          return '';
        }
      },
      isWorkflowEnabled: function() {
        var st = this.mdStatus;
        var res = st &&
            //Status is unknown
            (!isNaN(st) && st != '0');

        //What if it is an array: gmd:MD_ProgressCode
        if (!res && Array.isArray(st)) {
          angular.forEach(st, function(s) {
            if (!isNaN(s) && s != '0') {
              res = true;
            }
          });
        }
        return res;
      }
    };
    return Metadata;
  });


})();
