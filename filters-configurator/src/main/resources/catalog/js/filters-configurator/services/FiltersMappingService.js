(function () {
    goog.provide("lfw_filters_mapping_service");

    goog.require("lfw_metadata_service");
    goog.require("lfw_mapping");

    var module = angular.module("lfw_filters_mapping_service", [
      "lfw_metadata_service",
      "lfw_mapping"
    ]);

    module.service('LfwFiltersMappingService', [
      'standardFiltersMapping',
      'LfwMetadataService',
      function (standardFiltersMapping, metadataService) {

        // Given a JSON object and a JSON Path, returns the resulting node
        // element if found, null otherwise
        this.solveJSONPath = function (jsonObj, path, defaultValue) {
            const getProp = (mem, prop) => (!mem || typeof mem !== 'object') ? undefined : mem[prop];

            const squareRE = /\[.+?\]/g;

            if (!path) return jsonObj

            const camelProps = path.split(squareRE)
            let result

            if (camelProps.length === 1) {
                result = camelProps[0].split('.').reduce((mem, a) => getProp(mem, a), jsonObj)
            } else {
                const prettyProps = path.match(squareRE)
                result = camelProps.reduce((mem, a, i) => {
                    mem = this.solveJSONPath(mem, a.replace(/^\.|\.$/g, ''))
                    if (prettyProps[i]) {
                        mem = getProp(mem, prettyProps[i].replace(/^\[|\]$/g, ''))
                    }
                    return mem
                }, jsonObj)
            }

            return result !== undefined ? result : defaultValue
        }

        // Given an XML document and an xPath, returns the resulting node
        // element if found, null otherwise
        this.solveXPath = function(xmlDoc, xPath) {
            const evaluator = new XPathEvaluator();
            const nsResolver = evaluator.createNSResolver(
                xmlDoc.documentElement
            );
            const expression = evaluator.createExpression(xPath, nsResolver);
            const result = expression.evaluate(
                xmlDoc.documentElement,
                XPathResult.FIRST_ORDERED_NODE_TYPE
            );

            if(result) {
                return result.singleNodeValue;
            }

            return null;
        }

        // Returns true if a given XML node is a custom template node,
        // false otherwise
        this.xmlNodeIsCustom = function(node) {
            if(!node) {
                return false;
            }

            for(let attrName in [
                'schemaProfileConfigurator_customTagMetadata',
                'schemaProfileConfigurator_notStandardHierarchyMetadata'
            ]) {
                attr = node.attributes.getNamedItem(attrName);
                if(attr && attr.value) {
                    return true;
                }
            }

            return false;
        }

        // Given a documentStandard(eml-gbif, iso19139, ...) and an xPath, from
        // a template XML document, converts it to a JSON Path using the standard
        // mapping.
        this.solveStandardXPathToJSONPath = function(documentStandard, xPath) {
            const mapping = standardFiltersMapping[documentStandard];
            if(!mapping) {
                // No mapping has been found for this documentStandard
                return null;
            }

            // Remove any leading '/' and convert from xPath to JSON path format
            if (xPath.substring(0,1) == "/") {
                xPath = xPath.substring(1, xPath.length);
            }
            const path = xPath.replaceAll("/",".");

            // Use the converted xPath to search inside the mapping
            const element = this.solveJSONPath(mapping, path, null);
            if(!element) {
                return null;
            }

            return element['@jsonPath'] ?? null;
        }

        // Given an XML path and a template XML document returns the
        // corresponding JSON Path in the indexed ES document (if found).
        // Otherwise returns null
        //
        // Two main cases are managed here:
        //  1 - the xPath refers to a custom node (created using the template configurator)
        //  2 - the xPath refers to a standard tag
        this.xmlPathToJsonPath = function (documentStandard, xPath, xmlDoc, textValue=true) {
            var xmlElement = this.solveXPath(xmlDoc, xPath);

            if(xmlElement) {
                let jsonPath = null;

                // Case 1a: This is a custom tag and his parent is a standard tag
                const prefix = xmlElement.attributes.getNamedItem(
                    'schemaProfileConfigurator_notStandardMetadataIndexId'
                );
                if(prefix) {
                    if(xmlElement.attributes.getNamedItem('schemaProfileConfigurator_useAsTitle') && xmlElement.attributes.getNamedItem('schemaProfileConfigurator_useAsTitle').value == 'true'){
                        jsonPath = `resourceTitleObject.default.keyword`;
                        return jsonPath;
                    }
                    else{
                        jsonPath = `filterConfig.${xmlElement.nodeName}.keyword`;
                    }
                    return jsonPath;
                }

            }

            // Case 2: This is a standard tag
            return this.solveStandardXPathToJSONPath(documentStandard, xPath);
        }
        
        this.templatePathToJsonPath = function(documentStandard, templateUuid, xPath) {
            return new Promise((resolve, _reject) => {
                metadataService.loadMdRecordXml(templateUuid).then(xmlDoc => {
                    const jsonPath = this.xmlPathToJsonPath(
                        documentStandard, xPath, xmlDoc);

                    resolve(jsonPath);
                }).catch(err => {
                    console.error("Error while loading metadata record", err);
                    resolve(null);
                });
            });
        }
    }]);
})();