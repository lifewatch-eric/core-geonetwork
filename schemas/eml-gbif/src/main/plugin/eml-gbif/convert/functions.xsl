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
                xmlns:date="http://exslt.org/dates-and-times"
                xmlns:java="java:org.fao.geonet.util.XslUtil"
                xmlns:joda="java:org.fao.geonet.domain.ISODate"
                xmlns:mime="java:org.fao.geonet.util.MimeTypeFinder"
                version="2.0"
                exclude-result-prefixes="#all">

  <!-- ================================================================== -->

  <xsl:template name="fixSingle">
    <xsl:param name="value"/>

    <xsl:choose>
      <xsl:when test="string-length(string($value))=1">
        <xsl:value-of select="concat('0',$value)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ================================================================== -->

  <xsl:template name="getMimeTypeFile">
    <xsl:param name="datadir"/>
    <xsl:param name="fname"/>
    <xsl:value-of select="mime:detectMimeTypeFile($datadir,$fname)"/>
  </xsl:template>

  <!-- ==================================================================== -->

  <xsl:template name="getMimeTypeUrl">
    <xsl:param name="linkage"/>
    <xsl:value-of select="mime:detectMimeTypeUrl($linkage)"/>
  </xsl:template>

  <!-- ==================================================================== -->
  <xsl:template name="fixNonIso">
    <xsl:param name="value"/>

    <xsl:variable name="now" select="date:date-time()"/>
    <xsl:choose>
      <xsl:when
        test="$value='' or lower-case($value)='unknown' or lower-case($value)='current' or lower-case($value)='now'">
        <xsl:variable name="miy" select="date:month-in-year($now)"/>
        <xsl:variable name="month">
          <xsl:call-template name="fixSingle">
            <xsl:with-param name="value" select="$miy"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:variable name="dim" select="date:day-in-month($now)"/>
        <xsl:variable name="day">
          <xsl:call-template name="fixSingle">
            <xsl:with-param name="value" select="$dim"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:value-of select="concat(date:year($now),'-',$month,'-',$day,'T23:59:59')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$value"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- ==================================================================== -->

  <xsl:template name="newGmlTime">
    <xsl:param name="begin"/>
    <xsl:param name="end"/>


    <xsl:variable name="value1">
      <xsl:call-template name="fixNonIso">
        <xsl:with-param name="value" select="normalize-space($begin)"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="value2">
      <xsl:call-template name="fixNonIso">
        <xsl:with-param name="value" select="normalize-space($end)"/>
      </xsl:call-template>
    </xsl:variable>

    <!-- must be a full ISODateTimeFormat - so parse it and make sure it is
             returned as a long format using the joda Java Time library -->
    <xsl:variable name="output" select="joda:parseISODateTimes($value1,$value2)"/>
    <xsl:value-of select="$output"/>

  </xsl:template>
</xsl:stylesheet>
