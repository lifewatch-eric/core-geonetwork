<?xml version="1.0" encoding="UTF-8" ?>
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

<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:eml="https://eml.ecoinformatics.org/eml-2.2.0"
                xmlns:cov="https://eml.ecoinformatics.org/coverage-2.2.0"
                xmlns:res="https://eml.ecoinformatics.org/resource-2.2.0"
                xmlns:util="java:org.fao.geonet.util.XslUtil">

  <xsl:include href="../convert/functions.xsl"/>

  <!-- This file defines what parts of the metadata are indexed by Lucene
       Searches can be conducted on indexes defined here.
       The Field@name attribute defines the name of the search variable.
     If a variable has to be maintained in the user session, it needs to be
     added to the GeoNetwork constants in the Java source code.
     Please keep indexes consistent among metadata standards if they should
     work accross different metadata resources -->

  <!-- ========================================================================================= -->

  <xsl:output method="xml" version="1.0" encoding="UTF-8" indent="yes" />


  <!-- ========================================================================================= -->

  <xsl:template match="/">
    <Document locale="eng">
      <Field name="_locale" string="eng" store="true" index="true" token="false"/>
      <Field name="_docLocale" string="eng" store="true" index="true" token="false"/>


      <xsl:apply-templates select="eml:eml" mode="metadata"/>
    </Document>
  </xsl:template>

  <!-- ========================================================================================= -->

  <xsl:template match="*" mode="metadata">

    <xsl:for-each select="dataset">

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <xsl:for-each select="alternateIdentifier">
        <Field name="fileId" string="{string(.)}" store="true" index="true"/>
        <Field name="alternateIdentifier_dataset" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <xsl:variable name="aTitle" select="title[1]"/>
      <Field name="title" string="{string($aTitle)}" store="true" index="true"/>
      <Field name="_title" string="{string($aTitle)}" store="true" index="true"/>
      <Field name="_defaultTitle" string="{string($aTitle)}" store="true" index="true"/>

      <xsl:for-each select="title[position() > 1]">
        <Field name="altTitle" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <xsl:for-each select="pubDate">
        <Field name="publicationDate" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="maintenance">
        <Field name="updateFrequency" string="{maintenanceUpdateFrequency}" store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- fields used to search for metadata in paper or digital format -->

      <Field name="digital" string="true" store="true" index="true"/>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="abstract">
        <Field name="abstract" string="{normalize-space(string(.))}" store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- geographic extents -->

      <xsl:for-each select="coverage/geographicCoverage">
        <xsl:apply-templates select="boundingCoordinates" mode="latLon"/>

        <xsl:for-each select="geographicDescription">
          <Field name="geoDescCode" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>
      </xsl:for-each>

      <!-- temporal extents -->

      <xsl:for-each select="coverage/temporalCoverage">
        <xsl:for-each select="rangeOfDates">
          <xsl:variable name="times">
            <xsl:call-template name="newGmlTime">
              <xsl:with-param name="begin" select="beginDate/calendarDate"/>
              <xsl:with-param name="end" select="endDate/calendarDate"/>
            </xsl:call-template>
          </xsl:variable>

          <Field name="tempExtentBegin" string="{lower-case(substring-before($times,'|'))}" store="true" index="true"/>
          <Field name="tempExtentEnd" string="{lower-case(substring-after($times,'|'))}" store="true" index="true"/>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:for-each select="distribution">
        <xsl:variable name="tPosition" select="position()"></xsl:variable>
        <xsl:if test="connectionDefinition">
          <xsl:variable name="cnx">
          <xsl:for-each select="parameterDefinition">
              <xsl:value-of select="concat(name,'=',defaultValue,'&amp;')"/>
          </xsl:for-each>
          </xsl:variable>
          <Field name="link"
                    string="{concat(connectionDefinition/schemeName, '|',connectionDefinition/description/para,'|', $cnx, '|', connectionDefinition/@scope, '|database|', $tPosition)}"
                    store="true" index="false"/>
        </xsl:if>
        <xsl:if test="count(online/url) > 0">
          <Field name="link"
                    string="{concat('||', online/url, '|', @scope, '|', online/url/@function, '|', $tPosition)}"
                    store="true" index="false"/>
        </xsl:if>
      </xsl:for-each>

    

      <!-- taxonomic extents -->
      <!-- FIXME: Not done yet - needs to use the same structure as the MCP
           ALA -->

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:variable name="lower">abcdefghijklmnopqrstuvwxyz</xsl:variable>
      <xsl:variable name="upper">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
      <xsl:for-each select="keywordSet">
        <xsl:for-each select="keyword">
          <xsl:variable name="keywordLower" select="translate(string(.),$upper,$lower)"/>
          <Field name="keyword" string="{string(.)}" store="true" index="true"/>
          <Field name="subject" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <!-- Organization could be in associatedParty or in contact -->

      <xsl:for-each select="associatedParty[role='pointOfContact' and organizationName]">
        <Field name="orgName" string="{string(organizationName)}" store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="associatedParty[role and organizationName]">
        <Field name="responsibleParty" string="{concat(role, '|resource|', organizationName, '|')}" store="true" index="false"/>
      </xsl:for-each>




      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <!-- contact field (same as creator field) refers to resource -->
      <!--<xsl:for-each select="contact[organizationName]|creator[organizationName]">
        <Field name="orgName" string="{string(organizationName)}" store="true" index="true"/>
        <Field name="responsibleParty" string="{concat('pointOfContact|resource|', organizationName, '|')}" store="true" index="false"/>
      </xsl:for-each>-->

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <!-- creator field (same as contact field) refers to resource -->
      <xsl:for-each select="creator|contact|associatedParty"> <!-- [individualName]|contact[individualName]"> -->
        <xsl:variable name="ind">
          <xsl:apply-templates select="individualName"/>
        </xsl:variable>

        <xsl:variable name="crole">
          <xsl:choose>
            <xsl:when test="name='associatedParty'">
              <xsl:choose>
                <xsl:when test="role='PUBLISHER'">publisher</xsl:when>
                <xsl:when test="role='DISTRIBUTOR'">distributor</xsl:when>
                <xsl:when test="role='CREATOR'">creator</xsl:when>
                <xsl:when test="role='TECHNICAL_POINT_OF_CONTACT'">pointOfContact</xsl:when>
                <xsl:otherwise><xsl:text>pointOfContact</xsl:text></xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="name='creator'">creator</xsl:when>
            <xsl:when test="name='contact'">pointOfContact</xsl:when>
            <xsl:otherwise><xsl:text>pointOfContact</xsl:text></xsl:otherwise>
          </xsl:choose>
          </xsl:variable>

        <xsl:apply-templates mode="index-contact" select=".">
          <xsl:with-param name="type" select="'resource'"/>
          <xsl:with-param name="fieldPrefix" select="'responsibleParty'"/>
          <xsl:with-param name="role" select="string($crole)"/>
          <xsl:with-param name="position" select="position()"/>
        </xsl:apply-templates>
      </xsl:for-each>




      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <xsl:for-each select="associatedParty[role]">
        <Field name="responsiblePartyRole" string="{string(role)}" store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="metadataProvider"> <!-- select="metadataProvider[organizationName]"> -->
        <Field name="metadataPOC" string="{string(organizationName)}" store="true" index="true"/>
        <!--<Field name="responsibleParty" string="{concat('originator|metadata|', organizationName, '|')}" store="true" index="false"/>-->

        <xsl:apply-templates mode="index-contact"
                             select=".">
          <xsl:with-param name="type" select="'metadata'"/>
          <xsl:with-param name="fieldPrefix" select="'responsibleParty'"/>
          <xsl:with-param name="role" select="'originator'"/>
          <xsl:with-param name="position" select="position()"/>
        </xsl:apply-templates>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <!--<xsl:for-each select="metadataProvider[individualName]">
        <xsl:variable name="ind">
          <xsl:apply-templates select="individualName"/>
        </xsl:variable>

        <Field name="metadataPOC" string="{$ind}" store="true" index="true"/>
        <Field name="responsibleParty" string="{concat('originator|metadata|', $ind, '|')}" store="true" index="false"/>
      </xsl:for-each>-->

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:for-each select="language">
        <Field name="datasetLang" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <xsl:for-each select="intellectualRights">
        <Field name="conditionApplyingToAccessAndUse" string="{normalize-space(string(.))}" store="true" index="true"/>
      </xsl:for-each>

      <!-- Project - Dataset -->      
      <xsl:for-each select="project">
        <Field name="title_project_dataset" string="{string(title)}" store="true" index="true"/>      
        <Field name="abstract_project_dataset" string="{string(abstract/para)}" store="true" index="true"/>       
        <xsl:for-each select="personnel">
          <Field name="personnelProject_dataset" string="{concat(string-join(./individualName/givenName,' '), ' ', string-join(./individualName/surName,' '), '|', string-join(./positionName,personnel/role), '|', string-join(personnel/organizationName,' '))}" store="true" index="false"/>
        </xsl:for-each>
        <Field name="funding_project_dataset" string="{string(funding/para)}" store="true" index="true"/>            
      </xsl:for-each>

    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- === Other stuff from the additionalMetadata block === -->

    <xsl:if test="not(additionalMetadata/metadata/gbif)">
      <Field name="type" string="dataset" store="true" index="true"/>
    </xsl:if>

    <xsl:for-each select="additionalMetadata/metadata/gbif">

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->

      <xsl:choose>
        <xsl:when test="hierarchyLevel">
          <xsl:for-each select="hierarchyLevel">
            <Field name="type" string="{string(.)}" store="true" index="true"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <Field name="type" string="dataset" store="true" index="true"/>
        </xsl:otherwise>
      </xsl:choose>

      <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
      <xsl:for-each select="dateStamp">
        <Field name="changeDate" string="{string(.)}" store="true" index="true"/>
      </xsl:for-each>

      <xsl:for-each select="physical">
        <xsl:for-each select="dataFormat/externallyDefinedFormat/formatName">
          <Field name="format" string="{string(.)}" store="true" index="true"/>
        </xsl:for-each>

        <!-- index online protocol -->
        <xsl:if test="distribution/online/url/@function='download'">
          <Field name="protocol" string="WWW:DOWNLOAD-1.0-http--download" store="true" index="true"/>
        </xsl:if>

        <!-- FIXME: add code to calculate mimetype and add to index -->
        <!--
        <Field name="mimetype" string="{$mimetype}" store="true" index="true"/>
        -->
      </xsl:for-each>

      <xsl:for-each
        select="resourceLogoUrl">
        <Field name="image"
               string="{concat('|', ., '|')}"
               store="true" index="false"/>
      </xsl:for-each>

    </xsl:for-each>

    <!-- - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -->
    <!-- === Free text search === -->

    <Field name="any" store="false" index="true">
      <xsl:attribute name="string">
        <xsl:value-of select="normalize-space(string(.))"/>
      </xsl:attribute>
    </Field>

  </xsl:template>

  <!-- ========================================================================================= -->

  <xsl:template match="individualName">
    <xsl:value-of select="surName"/>
    <xsl:if test="givenName">
      <xsl:value-of select="concat(', ',givenName)"/>
    </xsl:if>
  </xsl:template>

  <!-- ========================================================================================= -->
  <!-- latlon coordinates indexed as numeric. -->

  <xsl:template match="*" mode="latLon">

    <xsl:if test="number(westBoundingCoordinate) and number(southBoundingCoordinate) and number(eastBoundingCoordinate) and number(northBoundingCoordinate)">
      <xsl:variable name="format" select="'##.00'"></xsl:variable>

      <Field name="westBL" string="{format-number(westBoundingCoordinate, $format)}" store="true" index="true"/>
      <Field name="southBL" string="{format-number(southBoundingCoordinate, $format)}" store="true" index="true"/>

      <Field name="eastBL" string="{format-number(eastBoundingCoordinate, $format)}" store="true" index="true"/>
      <Field name="northBL" string="{format-number(northBoundingCoordinate, $format)}" store="true" index="true"/>

      <Field name="geoBox" string="{
			concat(format-number(westBoundingCoordinate, $format), '|',
						format-number(southBoundingCoordinate, $format), '|',
						format-number(eastBoundingCoordinate, $format), '|',
						format-number(northBoundingCoordinate, $format)
						)}" store="true" index="false"/>
    </xsl:if>

  </xsl:template>

  <!-- ========================================================================================= -->

  <xsl:template mode="index-contact" match="creator|metadataProvider|contact|associatedParty">
    <xsl:param name="type"/>
    <xsl:param name="fieldPrefix"/>
    <xsl:param name="role"/>
    <xsl:param name="position" select="'0'"/>

    <xsl:variable name="orgName" select="./organizationName"/>

    <Field name="orgName" string="{string($orgName)}" store="true" index="true"/>
    <Field name="orgNameTree" string="{string($orgName)}" store="true" index="true"/>

    <xsl:variable name="roleTranslation"
                  select="util:getCodelistTranslation('gmd:CI_RoleCode', $role, 'eng')"/>

    <xsl:variable name="website" select="onlineUrl"/>
    <xsl:variable name="email"
                  select="electronicMailAddress"/>
    <xsl:variable name="phone"
                  select="phone[@phonetype='voice']"/>
    <xsl:variable name="individualName"
                  select="concat(individualName/givenName, ' ', individualName/surName)"/>
    <xsl:variable name="positionName"
                  select="positionName"/>
    <xsl:variable name="address" select="string-join(address/(
                                        deliveryPoint|postalCode|city|
                                        administrativeArea|country)/text(), ', ')"/>

    <Field name="{$fieldPrefix}"
           string="{concat($roleTranslation, '|',
                             $type,'|',
                             $orgName, '|',
                             '', '|',
                             string-join($email, ','), '|',
                             $individualName, '|',
                             $positionName, '|',
                             $address, '|',
                             string-join($phone, ','), '|',
                             '', '|',
                             $position, '|',
                             $website)}"
           store="true" index="false"/>

    <xsl:for-each select="$email">
      <Field name="{$fieldPrefix}Email" string="{string(.)}" store="true" index="true"/>
      <Field name="{$fieldPrefix}RoleAndEmail" string="{$role}|{string(.)}" store="true" index="true"/>
    </xsl:for-each>
  </xsl:template>

  <!-- ========================================================================================= -->

</xsl:stylesheet>
