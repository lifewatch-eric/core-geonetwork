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

package org.fao.geonet.schema.emlgbif;

import com.google.common.collect.ImmutableMap;
import com.google.common.collect.ImmutableSet;
import org.apache.commons.lang.StringUtils;
import org.fao.geonet.kernel.schema.AssociatedResource;
import org.fao.geonet.kernel.schema.AssociatedResourcesSchemaPlugin;
import org.fao.geonet.kernel.schema.LinkAwareSchemaPlugin;
import org.fao.geonet.kernel.schema.LinkPatternStreamer.ILinkBuilder;
import org.fao.geonet.kernel.schema.LinkPatternStreamer.RawLinkPatternStreamer;
import org.fao.geonet.utils.Xml;
import org.jdom.Element;
import org.jdom.Namespace;
import org.jdom.filter.ElementFilter;
import java.util.HashSet;
import java.util.Map;
import java.util.Set;

//import org.fao.geonet.schema.iso19139.ISO19139Namespaces.XLINK;

public class EmlGbifSchemaPlugin
    extends org.fao.geonet.kernel.schema.SchemaPlugin
    implements AssociatedResourcesSchemaPlugin, LinkAwareSchemaPlugin {
        
    public static final String IDENTIFIER = "eml-gbif";

    private static ImmutableSet<Namespace> allNamespaces;
    private static Map<String, Namespace> allTypenames;

    static {
        allNamespaces = ImmutableSet.<Namespace>builder()
            .add(EmlGbifNamespaces.EML)
            .add(EmlGbifNamespaces.DC)
            .add(EmlGbifNamespaces.DCT)
            .build();

        allTypenames = ImmutableMap.<String, Namespace>builder()
            .put("csw:Record", Namespace.getNamespace("csw", "http://www.opengis.net/cat/csw/2.0.2"))
            .put("dcat", Namespace.getNamespace("dcat", "http://www.w3.org/ns/dcat#"))
            .build();
    }

    public EmlGbifSchemaPlugin() {
        super(IDENTIFIER, allNamespaces);
    }


    /**
     * Always return null. Not implemented for dublin core records.
     */
    public Set<AssociatedResource> getAssociatedResourcesUUIDs(Element metadata) {
        return null;
    }

    @Override
    public Set<String> getAssociatedParentUUIDs(Element metadata) {
        return new HashSet<>();
    }

    public Set<String> getAssociatedDatasetUUIDs(Element metadata) {
        return null;
    }

    

    public Set<String> getAssociatedFeatureCatalogueUUIDs(Element metadata) {
        return null;
    }

    
    public Set<String> getAssociatedSourceUUIDs(Element metadata) {
        return null;
    }

    @Override
    public Map<String, Namespace> getCswTypeNames() {
        return allTypenames;
    }
        
    
    //Lifewatch
    @Override
    public Set<AssociatedResource> getAssociatedSources(Element metadata) {
        Set<AssociatedResource> associatedResources = new HashSet<AssociatedResource>(); //collectAssociatedResources(metadata, "*//gmd:source");
        return associatedResources;
    }

    @Override
    public Set<AssociatedResource> getAssociatedFeatureCatalogues(Element metadata) {
        Set<AssociatedResource> associatedResources = new HashSet<AssociatedResource>();
        //collectAssociatedResources(metadata, "*//gmd:featureCatalogueCitation[@uuidref]");
        return associatedResources;
    }
        
    @Override
    public Set<AssociatedResource> getAssociatedDatasets(Element metadata) {
        Set<AssociatedResource> associatedResources = new HashSet<AssociatedResource>();
        //collectAssociatedResources(metadata, "*//srv:operatesOn");
        return associatedResources;
    }
        
    @Override
    public Set<AssociatedResource> getAssociatedParents(Element metadata) {
        Set<AssociatedResource> associatedResources = new HashSet<>();

        Element parentIdentifier = metadata.getChild("parentIdentifier", EmlGbifNamespaces.EML);
        if (parentIdentifier != null) {
            Element characterString = parentIdentifier.getChild("CharacterString", EmlGbifNamespaces.EML);
            if (characterString != null) {
                associatedResources.add(new AssociatedResource(characterString.getText(), "", ""));
            }
            Element anchor = parentIdentifier.getChild("Anchor", EmlGbifNamespaces.EML);
            if (anchor != null) {
                associatedResources.add(elementAsAssociatedResource(anchor));
            }
        }
        // Parent relation is also frequently encoded using
        // aggregation. See parentAssociatedResourceType in ISO19115-3
        return associatedResources;
    }
        
    private AssociatedResource elementAsAssociatedResource(Element ref) {
        String sibUuid = ref.getAttributeValue("uuidref");
        if (StringUtils.isEmpty(sibUuid)) {
            sibUuid = ref.getTextNormalize();
        }
        String title = ref.getAttributeValue("title", EmlGbifNamespaces.XLINK, "");
        String url = ref.getAttributeValue("href", EmlGbifNamespaces.XLINK, "");
        return new AssociatedResource(sibUuid, "", "", url, title);
    }
    
    @Override
	public <L, M> RawLinkPatternStreamer<L, M> createLinkStreamer(ILinkBuilder<L, M> linkbuilder,
			String excludePattern) {
        RawLinkPatternStreamer patternStreamer = new RawLinkPatternStreamer(linkbuilder, excludePattern);
        patternStreamer.setNamespaces(EmlGbifSchemaPlugin.allNamespaces.asList());
        // TODO: Add xlink:href ?
        patternStreamer.setRawTextXPath(".//*[name() = 'url' or name() = 'dct:references' or @schemaProfileConfigurator_dataType = 'Link']");
        return patternStreamer;
	}
        
}
