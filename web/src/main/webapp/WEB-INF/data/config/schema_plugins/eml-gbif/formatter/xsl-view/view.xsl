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
                xmlns:dc="http://purl.org/dc/elements/1.1/"
                xmlns:eml="https://eml.ecoinformatics.org/eml-2.2.0"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:tr="java:org.fao.geonet.api.records.formatters.SchemaLocalizations"
                xmlns:gn-fn-render="http://geonetwork-opensource.org/xsl/functions/render"
                version="2.0"
                exclude-result-prefixes="#all">
 <!-- tr is defined at  core-geonetwork/services/src/main/java/org/fao/geonet/api/records/formatters/SchemaLocalizations.java -->
  <!-- Load the editor configuration to be able
  to render the different views -->
  <xsl:variable name="configuration"
                select="document('../../layout/config-editor.xml')"/>

  <!-- Some utility -->
  <xsl:include href="../../layout/evaluate.xsl"/>

  <!-- The core formatter XSL layout based on the editor configuration -->
  <xsl:include href="sharedFormatterDir/xslt/render-layout.xsl"/>
  <!--<xsl:include href="../../../../../data/formatter/xslt/render-layout.xsl"/>-->

  <!-- Define the metadata to be loaded for this schema plugin-->
  <xsl:variable name="metadata"
                select="/root/eml:eml"/>

  <!-- Ignore some fields displayed in header or in right column -->
  <xsl:template mode="render-field"
                match="abstract|title"
                priority="2000"/>

  <!-- Specific schema rendering -->
  <xsl:template mode="getMetadataTitle" match="eml:eml">
    <xsl:value-of select="dataset/title"/>
  </xsl:template>

  <xsl:template mode="getMetadataHierarchyLevel" match="eml:eml">
    <xsl:value-of select="'dataset'"/>
  </xsl:template>

  <xsl:template mode="getMetadataAbstract" match="eml:eml">
    <xsl:message>getMetadataAbstract</xsl:message>
    <xsl:value-of select="dataset/abstract/para"/>
  </xsl:template>

  <xsl:template mode="getMetadataHeader" match="eml:eml">
    <div class="gn-abstract">
      <xsl:for-each select="dataset/abstract/para">
        <xsl:call-template name="addLineBreaksAndHyperlinks">
          <xsl:with-param name="txt" select="."/>
        </xsl:call-template>
      </xsl:for-each>
    </div>
  </xsl:template>


  <!-- Some major sections are boxed -->
  <xsl:template mode="render-field"
                match="*[name() = $configuration/editor/fieldsWithFieldset/name]">

    <div class="entry name">
      <h2>
        <xsl:value-of select="tr:nodeLabel(tr:create($schema), name(), null)"/>
        <xsl:apply-templates mode="render-value"
                             select="@*"/>
      </h2>
      <div class="target"><xsl:comment select="name()"/>
        <xsl:choose>
          <xsl:when test="count(*) > 0">
            <xsl:apply-templates mode="render-field" select="*"/>
          </xsl:when>
          <xsl:otherwise>
            No information provided.
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </div>

  </xsl:template>

  <!-- Most of the elements are ... -->
  <xsl:template mode="render-field" match="*">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <xsl:message>render-field: <xsl:value-of select="name()" /> - <xsl:value-of select="$fieldName" /></xsl:message>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:nodeLabel(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value" select="."/>
      </dd>
    </dl>
  </xsl:template>

  <xsl:template mode="render-field" match="*[para]">
    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <xsl:message>render-field: <xsl:value-of select="name()" /> - <xsl:value-of select="$fieldName" /></xsl:message>

    <dl>
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:nodeLabel(tr:create($schema), name(), null)"/>
      </dt>
      <dd>
        <xsl:apply-templates mode="render-value" select="para"/>
      </dd>
    </dl>
  </xsl:template>

  <!-- Bbox is displayed with an overview and the geom displayed on it
  and the coordinates displayed around -->
  <xsl:template mode="render-field"
                match="boundingCoordinates">

    <xsl:variable name="north" select="northBoundingCoordinate"/>
    <xsl:variable name="south" select="southBoundingCoordinate"/>
    <xsl:variable name="east" select="eastBoundingCoordinate"/>
    <xsl:variable name="west" select="westBoundingCoordinate"/>

    <xsl:copy-of select="gn-fn-render:bbox(
                                xs:double($west),
                                xs:double($south),
                                xs:double($east),
                                xs:double($north))"/>
  </xsl:template>

  <!-- A contact is displayed with its role as header -->
  <xsl:template mode="render-field"
                match="creator|metadataProvider|contact|associatedParty"
                priority="100">
    <xsl:param name="layout"
               required="no"/>
    <xsl:param name="fieldName" select="''" as="xs:string"/>


    <xsl:variable name="email">
        <xsl:apply-templates mode="render-value"
                             select="electronicMailAddress"/>
    </xsl:variable>

    <xsl:variable name="role" select="role" />

    <!-- Display name is <org name> - <individual name> (<position name>) -->
    <!-- with separator/parentheses as required -->
    <xsl:variable name="displayName">
      <xsl:if test="organizationName">
        <xsl:apply-templates mode="render-value" select="organizationName"/>
      </xsl:if>
      <xsl:if test="organizationName and individualName|positionName"> - </xsl:if>
      <xsl:if test="individualName">
        <xsl:apply-templates mode="render-value" select="individualName/givenName"/> <xsl:apply-templates mode="render-value" select="individualName/surName"/>
      </xsl:if>
      <xsl:if test="positionName">
        <xsl:choose>
          <xsl:when test="individualName">
            (<xsl:apply-templates mode="render-value" select="positionName"/>)
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="render-value" select="positionName"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$layout = 'short'">
        <dl>
          <dt>
            <xsl:value-of select="if ($fieldName)
                                  then $fieldName
                                  else tr:nodeLabel(tr:create($schema), name(), null)"/>
          </dt>
          <dd>

            <xsl:copy-of select="$displayName"/>
          </dd>
        </dl>
      </xsl:when>
      <xsl:otherwise>
        <dl>
          <dt>
            <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:nodeLabel(tr:create($schema), name(), null)"/>
          </dt>
          <dd>
            <div class="gn-contact">
              <strong>
                <xsl:comment select="'email'"/>
                <xsl:apply-templates mode="render-value"
                                     select="role"/>
              </strong>
              <address>
                <xsl:choose>
                  <xsl:when test="$email">
                    <i class="fa fa-fw fa-envelope">&#160;</i>
                    <a href="mailto:{normalize-space($email)}">
                      <xsl:copy-of select="$displayName"/><xsl:comment select="'email'"/>
                    </a>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:copy-of select="$displayName"/><xsl:comment select="'name'"/>
                  </xsl:otherwise>
                </xsl:choose>
                <br/>

                <xsl:for-each select="address">
                  <div>
                    <i class="fa fa-fw fa-map-marker"><xsl:comment select="'address'"/></i>
                    <xsl:for-each select="deliveryPoint[normalize-space(.) != '']">
                      <xsl:apply-templates mode="render-value" select="."/>,
                    </xsl:for-each>
                    <xsl:for-each select="city[normalize-space(.) != '']">
                      <xsl:apply-templates mode="render-value" select="."/>,
                    </xsl:for-each>
                    <xsl:for-each select="administrativeArea[normalize-space(.) != '']">
                      <xsl:apply-templates mode="render-value" select="."/>,
                    </xsl:for-each>
                    <xsl:for-each select="postalCode[normalize-space(.) != '']">
                      <xsl:apply-templates mode="render-value" select="."/>,
                    </xsl:for-each>
                    <xsl:for-each select="country[normalize-space(.) != '']">
                      <xsl:apply-templates mode="render-value" select="."/>
                    </xsl:for-each>
                  </div>
                </xsl:for-each>

                <xsl:for-each select="phone[@phonetype='voice' and normalize-space(.) != '']">
                  <xsl:variable name="phoneNumber">
                    <xsl:apply-templates mode="render-value" select="."/>
                  </xsl:variable>
                  <i class="fa fa-fw fa-phone"><xsl:comment select="'phone'"/></i>
                  <a href="tel:{translate($phoneNumber,' ','')}">
                    <xsl:value-of select="$phoneNumber"/>
                  </a>
                  <br/>
                </xsl:for-each>
                <xsl:for-each select="phone[@phonetype='facsimile' and normalize-space(.) != '']">
                  <xsl:variable name="phoneNumber">
                    <xsl:apply-templates mode="render-value" select="."/>
                  </xsl:variable>
                  <i class="fa fa-fw fa-fax"><xsl:comment select="'fax'"/></i>
                  <a href="tel:{translate($phoneNumber,' ','')}">
                    <xsl:value-of select="normalize-space($phoneNumber)"/>
                  </a>
                  <br/>
                </xsl:for-each>
                <xsl:for-each select="onlineUrl[normalize-space(.) != '']">
                  <xsl:variable name="web">
                    <xsl:apply-templates mode="render-value" select="."/></xsl:variable>
                  <i class="fa fa-fw fa-link"><xsl:comment select="'link'"/></i>
                  <a href="{normalize-space($web)}">
                    <xsl:value-of select="normalize-space($web)"/>
                  </a>
                </xsl:for-each>
              </address>
            </div>
          </dd>
        </dl>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <xsl:template mode="render-field"
                match="keywordSet[
                count(keyword[. != '']) > 0]"
                priority="100">

    <xsl:param name="fieldName" select="''" as="xs:string"/>

    <dl class="gn-keyword">
      <dt>
        <xsl:value-of select="if ($fieldName)
                                then $fieldName
                                else tr:nodeLabel(tr:create($schema), name(), null)"/>

        (<xsl:apply-templates mode="render-value"
                             select="keywordThesaurus"/>)
      </dt>
      <dd>
        <div>
          <ul>
            <xsl:for-each select="keyword">
              <li>
                <xsl:apply-templates mode="render-value"
                                     select="."/>
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </dd>
    </dl>
  </xsl:template>

  <!-- Traverse the tree -->
  <xsl:template mode="render-field" match="eml:eml">
    <xsl:apply-templates mode="render-field"/>
  </xsl:template>


  <!-- ########################## -->
  <!-- Render values for text ... -->
  <xsl:template mode="render-value" match="*">

    <xsl:call-template name="addLineBreaksAndHyperlinks">
      <xsl:with-param name="txt" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!-- ... URL -->
  <xsl:template mode="render-value" match="*[starts-with(., 'http')]">
    <a href="{.}">
      <xsl:value-of select="."/>
    </a>
  </xsl:template>

  <!-- ... Dates - formatting is made on the client side by the directive  -->
  <xsl:template mode="render-value"
                match="pubDate[matches(., '[0-9]{4}')]|calendarDate[matches(., '[0-9]{4}')]">
    <span data-gn-humanize-time="{.}" data-format="YYYY">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="pubDate[matches(., '[0-9]{4}-[0-9]{2}')]|calendarDate[matches(., '[0-9]{4}-[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="MMM YYYY"><xsl:comment select="name()"/>
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="pubDate[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}')]
                      |calendarDate[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}')]">
    <span data-gn-humanize-time="{.}" data-format="DD MMM YYYY"><xsl:comment select="name()"/>
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="pubDate[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}')]
                |calendarDate[matches(., '[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}')]">
    <span data-gn-humanize-time="{.}"><xsl:comment select="name()"/>
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <xsl:template mode="render-value"
                match="pubDate|calendarDate">
    <span data-gn-humanize-time="{.}"><xsl:comment select="name()"/>
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

</xsl:stylesheet>
