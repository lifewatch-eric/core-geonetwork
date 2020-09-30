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

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                xmlns:eml="https://eml.ecoinformatics.org/eml-2.2.0">

  <!-- ================================================================= -->

  <xsl:template match="/root">
    <xsl:apply-templates select="eml:eml"/>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template match="eml:eml">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:apply-templates select="node()"/>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->

  <xsl:template match="dataset">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <alternateIdentifier>
        <xsl:value-of select="/root/env/uuid"/>
      </alternateIdentifier>
      <xsl:apply-templates select="node()[name() != 'alternateIdentifier']"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="para">
    <xsl:copy>
      <xsl:variable name="elValue" select="."/>

      <xsl:analyze-string select="$elValue"
                          regex="(\s*.*\s*)\[(.*)\](\s*)\((.*)\)(\s*.*\s*)">

        <xsl:matching-substring>
          <xsl:value-of select="regex-group(1)"/>
          <ulink url="{regex-group(4)}">
            <citetitle><xsl:value-of select="regex-group(2)"/></citetitle>
          </ulink>
          <xsl:value-of select="regex-group(5)"/>
        </xsl:matching-substring>

        <xsl:non-matching-substring>
          <xsl:value-of select="$elValue" />
        </xsl:non-matching-substring>

      </xsl:analyze-string>
    </xsl:copy>
  </xsl:template>

  <!-- ================================================================= -->
  <!-- copy everything else as is -->

  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
