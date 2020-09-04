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

<!--
Stylesheet used to update metadata adding a reference to a parent record.
-->
<xsl:stylesheet xmlns:stmml="http://www.xml-cml.org/schema/stmml-1.2"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:eml="https://eml.ecoinformatics.org/eml-2.2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="2.0">

  <xsl:param name="url" />
  <xsl:param name="updateKey" />

  <xsl:template match="/eml:eml/dataset">

    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:copy-of
        select="alternateIdentifier|title|creator|metadataProvider|associatedParty|pubDate|language|abstract|keywordSet|additionalInfo|intellectualRights"/>

       <xsl:for-each select="distribution">
        <xsl:choose>
          <xsl:when test="starts-with($updateKey, concat(., 'WWW:'))">
            <xsl:copy>
              <xsl:value-of select="$url"/>
            </xsl:copy>
          </xsl:when>
          <xsl:otherwise>
            <xsl:copy-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <!-- Add a new one if not in update mode
       and URL not already here. -->
      <xsl:if test="$updateKey = '' and not(distribution/online/url[text() = $url])">
        <distribution scope="document">
         <online>
            <url function="download"><xsl:value-of select="$url"/></url>
         </online>
      </distribution>
      </xsl:if>

      <xsl:copy-of
        select="coverage|purpose|contact|methods|project|dataTable"/>

    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>
