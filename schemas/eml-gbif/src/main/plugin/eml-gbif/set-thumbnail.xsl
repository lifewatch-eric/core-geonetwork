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

<xsl:stylesheet xmlns:stmml="http://www.xml-cml.org/schema/stmml-1.2"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:eml="https://eml.ecoinformatics.org/eml-2.2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

  <xsl:template match="/eml:eml/additionalMetadata/metadata/gbif">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="dateStamp"/>
      <xsl:apply-templates select="hierarchyLevel"/>
      <xsl:apply-templates select="citation"/>
      <xsl:apply-templates select="bibliography"/>
      <xsl:apply-templates select="physical"/>
      <resourceLogoUrl><xsl:value-of select="/root/env/file"/></resourceLogoUrl>
      <xsl:apply-templates select="collection"/>
      <xsl:apply-templates select="formationPeriod"/>
      <xsl:apply-templates select="specimenPreservationMethod"/>
      <xsl:apply-templates select="livingTimePeriod"/>
      <xsl:apply-templates select="jgtiCuratorialUnit"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
