<?xml version="1.0" encoding="UTF-8"?>

<!--
  ~ Copyright (C) 2001-2016 Food and Agriculture Organization of the
  ~ United Nations (FAO-UN), United Nations World Food Programme (WFP)
  ~ and United Nations Environment Programme (UNEP)
  ~
  ~ This program is free software; you can redistribute it and/or modify
  ~ it under the terms of the GNU General Public License as published by
  ~ the Free Software Foundation; either version 2 of the License, or (at
  ~ your option) any later version.
  ~
  ~ This program is distributed in the hope that it will be useful, but
  ~ WITHOUT ANY WARRANTY; without even the implied warranty of
  ~ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
  ~ General Public License for more details.
  ~
  ~ You should have received a copy of the GNU General Public License
  ~ along with this program; if not, write to the Free Software
  ~ Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
  ~
  ~ Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
  ~ Rome - Italy. email: geonetwork@osgeo.org
  -->

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
                xmlns:dc ="http://purl.org/dc/elements/1.1/"
                xmlns:eml="https://eml.ecoinformatics.org/eml-2.2.0"
                xmlns:ows="http://www.opengis.net/ows"
                xmlns:geonet="http://www.fao.org/geonetwork"
                exclude-result-prefixes="eml">

  <xsl:param name="displayInfo"/>
  <xsl:param name="lang"/>

  <!-- ============================================================================= -->

  <xsl:template match="eml:eml">

    <xsl:variable name="info" select="geonet:info"/>

    <csw:Record>

      <xsl:for-each select="dataset/alternateIdentifier">
        <dc:identifier><xsl:value-of select="."/></dc:identifier>
      </xsl:for-each>

      <xsl:for-each select="additionalMetadata/metadata/gbif/dateStamp">
        <dc:date><xsl:value-of select="."/></dc:date>
      </xsl:for-each>

      <!-- DataIdentification -->
      <xsl:for-each select="dataset/title">
        <dc:title><xsl:value-of select="."/></dc:title>
      </xsl:for-each>

      <!-- bounding box -->
      <xsl:for-each select="dataset/coverage/geographicCoverage">
        <ows:BoundingBox crs="epsg::4326">
          <ows:LowerCorner>
            <xsl:value-of select="concat(boundingCoordinates/eastBoundingCoordinate, ' ', boundingCoordinates/southBoundingCoordinate)"/>
          </ows:LowerCorner>

          <ows:UpperCorner>
            <xsl:value-of select="concat(boundingCoordinates/westBoundingCoordinate, ' ', boundingCoordinates/northBoundingCoordinate)"/>
          </ows:UpperCorner>
        </ows:BoundingBox>
      </xsl:for-each>

      <!-- GeoNetwork elements added when resultType is equal to results_with_summary -->
      <xsl:if test="$displayInfo = 'true'">
        <xsl:copy-of select="$info"/>
      </xsl:if>

    </csw:Record>
  </xsl:template>

  <!-- ============================================================================= -->

  <xsl:template match="*">
    <xsl:apply-templates select="*"/>
  </xsl:template>

  <!-- ============================================================================= -->

</xsl:stylesheet>
