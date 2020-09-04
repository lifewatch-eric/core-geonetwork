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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:eml="https://eml.ecoinformatics.org/eml-2.2.0"
                xmlns:cov="https://eml.ecoinformatics.org/coverage-2.2.0"
                xmlns:gn="http://www.fao.org/geonetwork" xmlns:xs="http://www.w3.org/2001/XMLSchema"
                exclude-result-prefixes="xs" version="2.0">

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- dublin-core brief and superBrief formatting -->
  <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
  <xsl:template mode="superBrief" match="eml:eml">
    <id>
      <xsl:value-of select="gn:info/id"/>
    </id>
    <uuid>
      <xsl:value-of select="gn:info/uuid"/>
    </uuid>
    <xsl:if test="eml:title">
      <title>
        <xsl:value-of select="eml:title"/>
      </title>
    </xsl:if>
    <xsl:if test="eml:abstract">
      <abstract>
        <xsl:value-of select="eml:abstract"/>
      </abstract>
    </xsl:if>
  </xsl:template>

  <xsl:template name="eml-gbifBrief">
    <metadata>
      <xsl:if test="eml:title">
        <title>
          <xsl:value-of select="eml:title"/>
        </title>
      </xsl:if>
      <xsl:if test="eml:abstract">
        <abstract>
          <xsl:value-of select="eml:abstract"/>
        </abstract>
      </xsl:if>

      <xsl:for-each select="eml:keyword[text()]">
        <keyword>
          <xsl:value-of select="."/>
        </keyword>
      </xsl:for-each>
      <!--
      <xsl:for-each select="dc:identifier[text()]">
        <link type="url">
          <xsl:value-of select="."/>
        </link>
      </xsl:for-each>
      -->
      <!-- FIXME
      <image>IMAGE</image>
      -->
      <!-- TODO : ows:BoundingBox -->
      <xsl:variable name="coverage" select="cov:geographicCoverage/cov:boundingCoordinates[1]"/>
      <xsl:if test="$coverage">
        <xsl:variable name="west" select="$coverage/cov:westBoundingCoordinate/text()"/>
        <xsl:variable name="east" select="$coverage/cov:eastBoundingCoordinate/text()"/>
        <xsl:variable name="north" select="$coverage/cov:northBoundingCoordinate/text()"/>
        <xsl:variable name="south" select="$coverage/cov:southBoundingCoordinate/text()"/>
        <geoBox>
          <westBL>
            <xsl:value-of select="$west"/>
          </westBL>
          <eastBL>
            <xsl:value-of select="$east"/>
          </eastBL>
          <southBL>
            <xsl:value-of select="$south"/>
          </southBL>
          <northBL>
            <xsl:value-of select="$north"/>
          </northBL>
        </geoBox>
      </xsl:if>

      <xsl:copy-of select="gn:*"/>
    </metadata>
  </xsl:template>
</xsl:stylesheet>
