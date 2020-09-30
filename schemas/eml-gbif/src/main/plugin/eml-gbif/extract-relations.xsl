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
                version="2.0"
                exclude-result-prefixes="#all">

  <xsl:template mode="relation" match="metadata[eml:eml]" priority="99">
    <xsl:variable name="mainLanguage" select="$lang" />

    <xsl:if test="count(eml:eml/dataset/distribution[@scope='document']/online[url[@function='download']!='']) > 0">
      <onlines>
        <xsl:for-each select="eml:eml/dataset/distribution[@scope='document']/online[url[@function='download']!='']">
          <item>
            <xsl:variable name="url" select="url"/>
            <id>
              <xsl:value-of select="$url"/>
            </id>
            <title>
              <xsl:value-of select="$url"/>
            </title>
            <url>
              <value lang="{$mainLanguage}">
                <xsl:value-of select="$url"/>
              </value>
            </url>
            <function>
            </function>
            <applicationProfile>
            </applicationProfile>
            <description>
            </description>
            <protocol>
            </protocol>
            <type>onlinesrc</type>
          </item>
        </xsl:for-each>
      </onlines>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
