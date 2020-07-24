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
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:gmd="http://www.isotc211.org/2005/gmd"
                xmlns:gmx="http://www.isotc211.org/2005/gmx"
                xmlns:gmi="http://www.isotc211.org/2005/gmi"
                xmlns:gco="http://www.isotc211.org/2005/gco"
                xmlns:srv="http://www.isotc211.org/2005/srv"
                xmlns:xlink="http://www.w3.org/1999/xlink"
                xmlns:gn-fn-index="http://geonetwork-opensource.org/xsl/functions/index"
                xmlns:index="java:org.fao.geonet.kernel.search.EsSearchManager"
                xmlns:daobs="http://daobs.org"
                xmlns:saxon="http://saxon.sf.net/"
                extension-element-prefixes="saxon"
                exclude-result-prefixes="#all"
                version="2.0">

  <xsl:import href="fn.xsl"/>
  <xsl:import href="common/inspire-constant.xsl"/>
  <xsl:import href="common/index-utils.xsl"/>

  <xsl:output method="xml" indent="yes"/>

  <xsl:output name="default-serialize-mode"
              indent="no"
              omit-xml-declaration="yes"
              encoding="utf-8"
              escape-uri-attributes="yes"/>

  <!-- Define if operatesOn type should be defined
  by analysis of protocol in all transfers options.
  -->
  <xsl:variable name="operatesOnSetByProtocol" select="false()"/>

  <!-- List of keywords to search for to flag a record as opendata.
   Do not put accents or upper case letters here as comparison will not
   take them in account. -->
  <xsl:variable name="openDataKeywords"
                select="'opendata|open data|donnees ouvertes'"/>

  <xsl:template match="/">
    <xsl:apply-templates mode="index"/>
  </xsl:template>

  <xsl:template match="gmi:MI_Metadata|gmd:MD_Metadata"
                mode="extract-uuid">
    <xsl:value-of select="gmd:fileIdentifier/gco:CharacterString"/>
  </xsl:template>


  <xsl:template mode="index-extra-fields" match="*"/>

  <xsl:template mode="index-extra-documents" match="*"/>

  <xsl:template match="gmi:MI_Metadata|gmd:MD_Metadata"
                mode="index">
    <!-- Main variables for the document

    TODO: GN does not assign UUIDs to template. Maybe it should ?
      XTTE0570: An empty sequence is not allowed as the value of variable $identifier
    -->
    <xsl:variable name="identifier" as="xs:string"
                  select="gmd:fileIdentifier/gco:CharacterString[. != '']"/>


    <xsl:variable name="mainLanguageCode" as="xs:string?"
                  select="gmd:language[1]/gmd:LanguageCode/
                        @codeListValue[normalize-space(.) != '']"/>
    <xsl:variable name="mainLanguage" as="xs:string?"
                  select="if ($mainLanguageCode) then $mainLanguageCode else
                    gmd:language[1]/gco:CharacterString[normalize-space(.) != '']"/>

    <xsl:variable name="otherLanguages" as="attribute()*"
                  select="gmd:locale/gmd:PT_Locale/
                        gmd:languageCode/gmd:LanguageCode/
                          @codeListValue[normalize-space(.) != '']"/>

    <!-- Record is dataset if no hierarchyLevel -->
    <xsl:variable name="isDataset" as="xs:boolean"
                  select="
                      count(gmd:hierarchyLevel[gmd:MD_ScopeCode/@codeListValue='dataset']) > 0 or
                      count(gmd:hierarchyLevel) = 0"/>
    <xsl:variable name="isService" as="xs:boolean"
                  select="
                      count(gmd:hierarchyLevel[gmd:MD_ScopeCode/@codeListValue='service']) > 0"/>

    <!-- Create a first document representing the main record. -->
    <doc>
      <documentType>metadata</documentType>
      <documentStandard>iso19139</documentStandard>

      <!-- Index the metadata document as XML -->
      <document>
        <!--<xsl:value-of select="saxon:serialize(., 'default-serialize-mode')"/>-->
      </document>
      <uuid>
        <xsl:value-of select="$identifier"/>
      </uuid>
      <metadataIdentifier>
        <xsl:value-of select="$identifier"/>
      </metadataIdentifier>

      <xsl:for-each select="gmd:metadataStandardName/gco:CharacterString">
        <standardName>
          <xsl:value-of select="normalize-space(.)"/>
        </standardName>
      </xsl:for-each>

      <harvestedDate>
        <xsl:value-of select="format-dateTime(current-dateTime(), $dateFormat)"/>
      </harvestedDate>


      <!-- Indexing record information -->
      <!-- # Date -->
      <!-- TODO improve date formatting maybe using Joda parser
      Select first one because some records have 2 dates !
      eg. fr-784237539-bdref20100101-0105

      Remove millisec and timezone until not supported
      eg. 2017-02-08T13:18:03.138+00:02
      -->
      <xsl:for-each select="gmd:dateStamp/*[text() != '' and position() = 1]">
        <dateStamp>
          <xsl:variable name="date"
                        select="if (name() = 'gco:Date' and string-length(.) = 4)
                                then concat(., '-01-01T00:00:00')
                                else if (name() = 'gco:Date' and string-length(.) = 7)
                                then concat(., '-01T00:00:00')
                                else if (name() = 'gco:Date' or string-length(.) = 10)
                                then concat(., 'T00:00:00')
                                else if (contains(., '.'))
                                then tokenize(., '\.')[1]
                                else ."/>

          <xsl:value-of select="translate(string(
                                   adjust-dateTime-to-timezone(
                                      xs:dateTime($date),
                                      xs:dayTimeDuration('PT0H'))
                                     ), 'Z', '')"/>
        </dateStamp>
      </xsl:for-each>

     <!-- VRE LifeWatch -->
     <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:alternateIdentifier_vre/gco:CharacterString">
        <id_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </id_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:url_vre/gco:CharacterString">
        <url_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </url_vre>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:coordinationTeam_vre/gmd:LW_CoordinationTeam/gmd:contactPoint_vre/gco:CharacterString">
        <contactPoint_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </contactPoint_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:coordinationTeam_vre/gmd:LW_CoordinationTeam/gmd:address_vre/gco:CharacterString">
        <address_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </address_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:coordinationTeam_vre/gmd:LW_CoordinationTeam/gmd:e_mail_vre/gco:CharacterString">
        <e_mail_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </e_mail_vre>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:containServices_vre/gmd:LW_ContainServices/gmd:serviceName_vre/gco:CharacterString">
        <serviceName_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceName_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:containServices_vre/gmd:LW_ContainServices/gmd:serviceDescription_vre/gco:CharacterString">
        <serviceDescription_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceDescription_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:containServices_vre/gmd:LW_ContainServices/gmd:serviceReference_vre/gco:CharacterString">
        <serviceReference_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceReference_vre>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:vreContractualInformation_vre/gmd:LW_VREContractualInformation/gmd:license_vre/gco:CharacterString">
        <license_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </license_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:vreContractualInformation_vre/gmd:LW_VREContractualInformation/gmd:usageConditions_vre/gco:CharacterString">
        <usageConditions_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </usageConditions_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:vreContractualInformation_vre/gmd:LW_VREContractualInformation/gmd:howToCiteThisVRE_vre/gco:CharacterString">
        <howToCiteThisVRE_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </howToCiteThisVRE_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:vreContractualInformation_vre/gmd:LW_VREContractualInformation/gmd:publicationsAboutThisVRE_vre/gco:CharacterString">
        <publicationsAboutThisVRE_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </publicationsAboutThisVRE_vre>
      </xsl:for-each>

     <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:vreSupportInformation_vre/gmd:LW_VRESupportInformation/gmd:vreFeedback_vre/gco:CharacterString">
        <vreFeedback_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </vreFeedback_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:vreSupportInformation_vre/gmd:LW_VRESupportInformation/gmd:vreHelpdesk_vre/gco:CharacterString">
        <vreHelpdesk_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </vreHelpdesk_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:vreSupportInformation_vre/gmd:LW_VRESupportInformation/gmd:vreOrder_vre/gco:CharacterString">
        <vreOrder_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </vreOrder_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:vreSupportInformation_vre/gmd:LW_VRESupportInformation/gmd:vreTraining_vre/gco:CharacterString">
        <vreTraining_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </vreTraining_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:vreSupportInformation_vre/gmd:LW_VRESupportInformation/gmd:vreUserManual_vre/gco:CharacterString">
        <vreUserManual_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </vreUserManual_vre>
      </xsl:for-each>

      <!-- <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:managementInfo_vre/gmd:LW_ManagementInfo/gmd:author_vre/gco:CharacterString">
        <author_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </author_vre>
      </xsl:for-each> -->
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:managementInfo_vre/gmd:LW_ManagementInfo/gmd:maintainer_vre/gco:CharacterString">
        <maintainer_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </maintainer_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:managementInfo_vre/gmd:LW_ManagementInfo/gmd:version_vre/gco:CharacterString">
        <version_vre>
          <xsl:value-of select="normalize-space(.)"/>
        </version_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:managementInfo_vre/gmd:LW_ManagementInfo/gmd:lastUpdated_vre/*[text() != '' and position() = 1]">
        <lastUpdated_vre>
           <xsl:variable name="date"
                        select="if (name() = 'gco:Date' and string-length(.) = 4)
                                then concat(., '-01-01T00:00:00')
                                else if (name() = 'gco:Date' and string-length(.) = 7)
                                then concat(., '-01T00:00:00')
                                else if (name() = 'gco:Date' or string-length(.) = 10)
                                then concat(., 'T00:00:00')
                                else if (contains(., '.'))
                                then tokenize(., '\.')[1]
                                else ."/>

          <xsl:value-of select="translate(string(
                                   adjust-dateTime-to-timezone(
                                      xs:dateTime($date),
                                      xs:dayTimeDuration('PT0H'))
                                     ), 'Z', '')"/>
        </lastUpdated_vre>
      </xsl:for-each>
      <xsl:for-each select="gmd:vre/gmd:LW_VRE/gmd:managementInfo_vre/gmd:LW_ManagementInfo/gmd:created_vre/*[text() != '' and position() = 1]">
        <created_vre>
           <xsl:variable name="date"
                        select="if (name() = 'gco:Date' and string-length(.) = 4)
                                then concat(., '-01-01T00:00:00')
                                else if (name() = 'gco:Date' and string-length(.) = 7)
                                then concat(., '-01T00:00:00')
                                else if (name() = 'gco:Date' or string-length(.) = 10)
                                then concat(., 'T00:00:00')
                                else if (contains(., '.'))
                                then tokenize(., '\.')[1]
                                else ."/>

          <xsl:value-of select="translate(string(
                                   adjust-dateTime-to-timezone(
                                      xs:dateTime($date),
                                      xs:dayTimeDuration('PT0H'))
                                     ), 'Z', '')"/>
        </created_vre>
      </xsl:for-each>
      <!--  End VRE LifeWatch -->
      
      
      <!-- Workflow LifeWatch -->
     <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:alternateIdentifier_workflow/gco:CharacterString">
        <id_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </id_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:url_workflow/gco:CharacterString">
        <url_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </url_workflow>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:coordinationTeam_workflow/gmd:LW_WorkflowCoordinationTeam/gmd:contactPoint_workflow/gco:CharacterString">
        <contactPoint_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </contactPoint_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:coordinationTeam_workflow/gmd:LW_WorkflowCoordinationTeam/gmd:address_workflow/gco:CharacterString">
        <address_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </address_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:coordinationTeam_workflow/gmd:LW_WorkflowCoordinationTeam/gmd:e_mail_workflow/gco:CharacterString">
        <e_mail_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </e_mail_workflow>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:containServices_workflow/gmd:LW_WorkflowContainServices/gmd:serviceName_workflow/gco:CharacterString">
        <serviceName_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceName_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:containServices_workflow/gmd:LW_WorkflowContainServices/gmd:serviceDescription_workflow/gco:CharacterString">
        <serviceDescription_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceDescription_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:containServices_workflow/gmd:LW_WorkflowContainServices/gmd:serviceReference_workflow/gco:CharacterString">
        <serviceReference_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceReference_workflow>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:workflowContractualInformation_workflow/gmd:LW_WorkflowContractualInformation/gmd:license_workflow/gco:CharacterString">
        <license_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </license_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:workflowContractualInformation_workflow/gmd:LW_WorkflowContractualInformation/gmd:usageConditions_workflow/gco:CharacterString">
        <usageConditions_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </usageConditions_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:workflowContractualInformation_workflow/gmd:LW_WorkflowContractualInformation/gmd:howToCiteThisWorkflow_workflow/gco:CharacterString">
        <howToCiteThisVRE_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </howToCiteThisVRE_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:workflowContractualInformation_workflow/gmd:LW_WorkflowContractualInformation/gmd:publicationsAboutThisWorkflow_workflow/gco:CharacterString">
        <publicationsAboutThisVRE_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </publicationsAboutThisVRE_workflow>
      </xsl:for-each>

     <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:workflowSupportInformation_workflow/gmd:LW_WorkflowSupportInformation/gmd:workflowFeedback_workflow/gco:CharacterString">
        <vreFeedback_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </vreFeedback_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:workflowSupportInformation_workflow/gmd:LW_WorkflowSupportInformation/gmd:workflowHelpdesk_workflow/gco:CharacterString">
        <vreHelpdesk_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </vreHelpdesk_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:workflowSupportInformation_workflow/gmd:LW_WorkflowSupportInformation/gmd:workflowOrder_workflow/gco:CharacterString">
        <vreOrder_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </vreOrder_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:workflowSupportInformation_workflow/gmd:LW_WorkflowSupportInformation/gmd:workflowTraining_workflow/gco:CharacterString">
        <vreTraining_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </vreTraining_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:workflowSupportInformation_workflow/gmd:LW_WorkflowSupportInformation/gmd:workflowUserManual_workflow/gco:CharacterString">
        <vreUserManual_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </vreUserManual_workflow>
      </xsl:for-each>

      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:managementInfo_workflow/gmd:LW_WorkflowManagementInfo/gmd:maintainer_workflow/gco:CharacterString">
        <maintainer_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </maintainer_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:managementInfo_workflow/gmd:LW_WorkflowManagementInfo/gmd:version_workflow/gco:CharacterString">
        <version_workflow>
          <xsl:value-of select="normalize-space(.)"/>
        </version_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:managementInfo_workflow/gmd:LW_WorkflowManagementInfo/gmd:lastUpdated_workflow/*[text() != '' and position() = 1]">
        <lastUpdated_workflow>
           <xsl:variable name="date"
                        select="if (name() = 'gco:Date' and string-length(.) = 4)
                                then concat(., '-01-01T00:00:00')
                                else if (name() = 'gco:Date' and string-length(.) = 7)
                                then concat(., '-01T00:00:00')
                                else if (name() = 'gco:Date' or string-length(.) = 10)
                                then concat(., 'T00:00:00')
                                else if (contains(., '.'))
                                then tokenize(., '\.')[1]
                                else ."/>

          <xsl:value-of select="translate(string(
                                   adjust-dateTime-to-timezone(
                                      xs:dateTime($date),
                                      xs:dayTimeDuration('PT0H'))
                                     ), 'Z', '')"/>
        </lastUpdated_workflow>
      </xsl:for-each>
      <xsl:for-each select="gmd:workflow/gmd:LW_Workflow/gmd:managementInfo_workflow/gmd:LW_WorkflowManagementInfo/gmd:created_workflow/*[text() != '' and position() = 1]">
        <created_workflow>
           <xsl:variable name="date"
                        select="if (name() = 'gco:Date' and string-length(.) = 4)
                                then concat(., '-01-01T00:00:00')
                                else if (name() = 'gco:Date' and string-length(.) = 7)
                                then concat(., '-01T00:00:00')
                                else if (name() = 'gco:Date' or string-length(.) = 10)
                                then concat(., 'T00:00:00')
                                else if (contains(., '.'))
                                then tokenize(., '\.')[1]
                                else ."/>

          <xsl:value-of select="translate(string(
                                   adjust-dateTime-to-timezone(
                                      xs:dateTime($date),
                                      xs:dayTimeDuration('PT0H'))
                                     ), 'Z', '')"/>
        </created_workflow>
      </xsl:for-each>
      <!--  End Workflow LifeWatch -->
      
      
      <!-- Service LifeWatch -->
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:revisionDate_service/*[text() != '' and position() = 1]">
        <revisionDate_service>
          <xsl:variable name="date"
                        select="if (name() = 'gco:Date' and string-length(.) = 4)
                                then concat(., '-01-01T00:00:00')
                                else if (name() = 'gco:Date' and string-length(.) = 7)
                                then concat(., '-01T00:00:00')
                                else if (name() = 'gco:Date' or string-length(.) = 10)
                                then concat(., 'T00:00:00')
                                else if (contains(., '.'))
                                then tokenize(., '\.')[1]
                                else ."/>

          <xsl:value-of select="translate(string(
                                   adjust-dateTime-to-timezone(
                                      xs:dateTime($date),
                                      xs:dayTimeDuration('PT0H'))
                                     ), 'Z', '')"/>
        </revisionDate_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:url_service/gco:CharacterString">
        <url_service>
          <xsl:value-of select="normalize-space(.)"/>
        </url_service>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:technicalInformation_service/gmd:LW_TechnicalInformation/gmd:contactPoint_service/gco:CharacterString">
        <contactPoint_service>
          <xsl:value-of select="normalize-space(.)"/>
        </contactPoint_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:technicalInformation_service/gmd:LW_TechnicalInformation/gmd:address_service/gco:CharacterString">
        <address_service>
          <xsl:value-of select="normalize-space(.)"/>
        </address_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:technicalInformation_service/gmd:LW_TechnicalInformation/gmd:keywords_service/gco:CharacterString">
        <keywords_service>
          <xsl:value-of select="normalize-space(.)"/>
        </keywords_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:technicalInformation_service/gmd:LW_TechnicalInformation/gmd:typeOfService_service/gco:CharacterString">
        <typeOfService_service>
          <xsl:value-of select="normalize-space(.)"/>
        </typeOfService_service>
      </xsl:for-each>
      <xsl:for-each
            select="*/gmd:service/gmd:LW_Service/gmd:technicalInformation_service/gmd:LW_TechnicalInformation/gmd:typeOfAssociation_service/gmd:LW_TypeOfAssociation_service/@codeListValue[. != '']">
            <typeOfAssociation_service>
              <xsl:value-of select="."/>
            </typeOfAssociation_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:containOperations_service/gmd:LW_ContainOperations/gmd:operationName_service/gco:CharacterString">
        <operationName_service>
          <xsl:value-of select="normalize-space(.)"/>
        </operationName_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:containOperations_service/gmd:LW_ContainOperations/gmd:webSite_service/gco:CharacterString">
        <webSite_service>
          <xsl:value-of select="normalize-space(.)"/>
        </webSite_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:containOperations_service/gmd:LW_ContainOperations/gmd:protocol_service/gco:CharacterString">
        <protocol_service>
          <xsl:value-of select="normalize-space(.)"/>
        </protocol_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:containOperations_service/gmd:LW_ContainOperations/gmd:descriptionOperation_service/gco:CharacterString">
        <descriptionOperation_service>
          <xsl:value-of select="normalize-space(.)"/>
        </descriptionOperation_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:containOperations_service/gmd:LW_ContainOperations/gmd:function_service/gco:CharacterString">
        <function_service>
          <xsl:value-of select="normalize-space(.)"/>
        </function_service>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceClassificationInformation_service/gmd:LW_ServiceClassificationInformation/gmd:pid_service/gco:CharacterString">
        <pid_service>
          <xsl:value-of select="normalize-space(.)"/>
        </pid_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceClassificationInformation_service/gmd:LW_ServiceClassificationInformation/gmd:tags_service/gco:CharacterString">
        <tags_service>
          <xsl:value-of select="normalize-space(.)"/>
        </tags_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceClassificationInformation_service/gmd:LW_ServiceClassificationInformation/gmd:relatedServices_service/gco:CharacterString">
        <relatedServices_service>
          <xsl:value-of select="normalize-space(.)"/>
        </relatedServices_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceClassificationInformation_service/gmd:LW_ServiceClassificationInformation/gmd:requiredServices_service/gco:CharacterString">
        <requiredServices_service>
          <xsl:value-of select="normalize-space(.)"/>
        </requiredServices_service>
      </xsl:for-each>
      <xsl:for-each
            select="*/gmd:service/gmd:LW_Service/gmd:serviceClassificationInformation_service/gmd:LW_ServiceClassificationInformation/gmd:topicCategory_service/gmd:LW_TopicCategory_service/@codeListValue[. != '']">
            <topicCategory_service>
              <xsl:value-of select="."/>
            </topicCategory_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceClassificationInformation_service/gmd:LW_ServiceClassificationInformation/gmd:serviceLanguage_service/gco:CharacterString">
        <serviceLanguage_service>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceLanguage_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceClassificationInformation_service/gmd:LW_ServiceClassificationInformation/gmd:charset_service/gco:CharacterString">
        <charset_service>
          <xsl:value-of select="normalize-space(.)"/>
        </charset_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceClassificationInformation_service/gmd:LW_ServiceClassificationInformation/gmd:otherLanguage_service/gco:CharacterString">
        <otherLanguage_service>
          <xsl:value-of select="normalize-space(.)"/>
        </otherLanguage_service>
      </xsl:for-each>
      <xsl:for-each
            select="*/gmd:service/gmd:LW_Service/gmd:serviceClassificationInformation_service/gmd:LW_ServiceClassificationInformation/gmd:serviceTRL_service/gmd:LW_ServiceTRL_service/@codeListValue[. != '']">
            <serviceTRL_service>
              <xsl:value-of select="."/>
            </serviceTRL_service>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceContractualInformation_service/gmd:LW_ServiceContractualInformation/gmd:serviceFunding_service/gco:CharacterString">
        <serviceFunding_service>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceFunding_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceContractualInformation_service/gmd:LW_ServiceContractualInformation/gmd:serviceLevelAgreement_service/gco:CharacterString">
        <serviceLevelAgreement_service>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceLevelAgreement_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceContractualInformation_service/gmd:LW_ServiceContractualInformation/gmd:servicePrice_service/gco:CharacterString">
        <servicePrice_service>
          <xsl:value-of select="normalize-space(.)"/>
        </servicePrice_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceContractualInformation_service/gmd:LW_ServiceContractualInformation/gmd:termsOfUse_service/gco:CharacterString">
        <termsOfUse_service>
          <xsl:value-of select="normalize-space(.)"/>
        </termsOfUse_service>
      </xsl:for-each>
      
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceSupportInformation_service/gmd:LW_ServiceSupportInformation/gmd:serviceFeedback_service/gco:CharacterString">
        <serviceFeedback_service>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceFeedback_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceSupportInformation_service/gmd:LW_ServiceSupportInformation/gmd:serviceHelpdesk_service/gco:CharacterString">
        <serviceHelpdesk_service>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceHelpdesk_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceSupportInformation_service/gmd:LW_ServiceSupportInformation/gmd:serviceOrder_service/gco:CharacterString">
        <serviceOrder_service>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceOrder_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceSupportInformation_service/gmd:LW_ServiceSupportInformation/gmd:serviceTraining_service/gco:CharacterString">
        <serviceTraining_service>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceTraining_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:serviceSupportInformation_service/gmd:LW_ServiceSupportInformation/gmd:serviceUserManual_service/gco:CharacterString">
        <serviceUserManual_service>
          <xsl:value-of select="normalize-space(.)"/>
        </serviceUserManual_service>
      </xsl:for-each>
      
      <!-- <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:managementInfo_service/gmd:LW_ManagementInfoService/gmd:author_service/gco:CharacterString">
        <author_service>
          <xsl:value-of select="normalize-space(.)"/>
        </author_service>
      </xsl:for-each> -->
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:managementInfo_service/gmd:LW_ManagementInfo/gmd:maintainer_service/gco:CharacterString">
        <maintainer_service>
          <xsl:value-of select="normalize-space(.)"/>
        </maintainer_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:managementInfo_service/gmd:LW_ManagementInfo/gmd:version_service/gco:CharacterString">
        <version_service>
          <xsl:value-of select="normalize-space(.)"/>
        </version_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:managementInfo_service/gmd:LW_ManagementInfo/gmd:lastUpdated_service/*[text() != '' and position() = 1]">
        <lastUpdated_service>
          <xsl:variable name="date"
                        select="if (name() = 'gco:Date' and string-length(.) = 4)
                                then concat(., '-01-01T00:00:00')
                                else if (name() = 'gco:Date' and string-length(.) = 7)
                                then concat(., '-01T00:00:00')
                                else if (name() = 'gco:Date' or string-length(.) = 10)
                                then concat(., 'T00:00:00')
                                else if (contains(., '.'))
                                then tokenize(., '\.')[1]
                                else ."/>

          <xsl:value-of select="translate(string(
                                   adjust-dateTime-to-timezone(
                                      xs:dateTime($date),
                                      xs:dayTimeDuration('PT0H'))
                                     ), 'Z', '')"/>
        </lastUpdated_service>
      </xsl:for-each>
      <xsl:for-each select="gmd:service/gmd:LW_Service/gmd:managementInfo_service/gmd:LW_ManagementInfo/gmd:created_service/*[text() != '' and position() = 1]">
        <created_service>
          <xsl:variable name="date"
                        select="if (name() = 'gco:Date' and string-length(.) = 4)
                                then concat(., '-01-01T00:00:00')
                                else if (name() = 'gco:Date' and string-length(.) = 7)
                                then concat(., '-01T00:00:00')
                                else if (name() = 'gco:Date' or string-length(.) = 10)
                                then concat(., 'T00:00:00')
                                else if (contains(., '.'))
                                then tokenize(., '\.')[1]
                                else ."/>

          <xsl:value-of select="translate(string(
                                   adjust-dateTime-to-timezone(
                                      xs:dateTime($date),
                                      xs:dayTimeDuration('PT0H'))
                                     ), 'Z', '')"/>
        </created_service>
      </xsl:for-each>
      <!-- End Service LifeWatch -->
      
      <!-- Dataset LifeWatch -->
      <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:alternateIdentifier_dataset/gco:CharacterString">
        <alternativeIdentifier_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </alternativeIdentifier_dataset>
      </xsl:for-each>
      <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:creator_dataset/gmd:LW_Creator_dataset/gmd:id_creator_dataset/gco:CharacterString">
        <id_creator_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </id_creator_dataset>
      </xsl:for-each>

    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:creator_dataset/gmd:LW_Creator_dataset/gmd:individualName_creator_dataset/gmd:LW_IndividualName_creator_dataset/gmd:givenName_individualName_creator_dataset/gco:CharacterString">
        <givenName_individualName_creator_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </givenName_individualName_creator_dataset>
    </xsl:for-each> 
     <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:creator_dataset/gmd:LW_Creator_dataset/gmd:individualName_creator_dataset/gmd:LW_IndividualName_creator_dataset/gmd:surName_individualName_creator_dataset/gco:CharacterString">
        <surName_individualName_creator_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </surName_individualName_creator_dataset>
    </xsl:for-each>  
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:creator_dataset/gmd:LW_Creator_dataset/gmd:organizationName_creator_dataset/gco:CharacterString">
        <organizationName_creator_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </organizationName_creator_dataset>
    </xsl:for-each>  
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:creator_dataset/gmd:LW_Creator_dataset/gmd:electronicMailAddress_creator_dataset/gco:CharacterString">
        <electronicMailAddress_creator_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </electronicMailAddress_creator_dataset>
    </xsl:for-each>    
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:creator_dataset/gmd:LW_Creator_dataset/gmd:userId_creator_dataset/gco:CharacterString">
        <userId_creator_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </userId_creator_dataset>
    </xsl:for-each> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:creator_dataset/gmd:LW_Creator_dataset/gmd:references_creator_dataset/gco:CharacterString">
        <references_creator_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </references_creator_dataset>
    </xsl:for-each> 
      
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:metadataProvider_dataset/gmd:LW_MetadataProvider_dataset/gmd:id_metadataProvider_dataset/gco:CharacterString">
        <id_metadataProvider_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </id_metadataProvider_dataset>
    </xsl:for-each>  
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:metadataProvider_dataset/gmd:LW_MetadataProvider_dataset/gmd:individualName_metadataProvider_dataset/gmd:LW_IndividualName_metadataProvider_dataset/gmd:givenName_individualName_metadataProvider_dataset/gco:CharacterString">
        <givenName_individualName_metadataProvider_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </givenName_individualName_metadataProvider_dataset>
    </xsl:for-each> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:metadataProvider_dataset/gmd:LW_MetadataProvider_dataset/gmd:individualName_metadataProvider_dataset/gmd:LW_IndividualName_metadataProvider_dataset/gmd:surName_individualName_metadataProvider_dataset/gco:CharacterString">
        <surName_individualName_metadataProvider_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </surName_individualName_metadataProvider_dataset>
    </xsl:for-each> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:metadataProvider_dataset/gmd:LW_MetadataProvider_dataset/gmd:organizationName_metadataProvider_dataset/gco:CharacterString">
        <organizationName_metadataProvider_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </organizationName_metadataProvider_dataset>
    </xsl:for-each> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:metadataProvider_dataset/gmd:LW_MetadataProvider_dataset/gmd:electronicMailAddress_metadataProvider_dataset/gco:CharacterString">
        <electronicMailAddress_metadataProvider_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </electronicMailAddress_metadataProvider_dataset>
    </xsl:for-each>
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:metadataProvider_dataset/gmd:LW_MetadataProvider_dataset/gmd:references_metadataProvider_dataset/gco:CharacterString">
        <references_metadataProvider_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </references_metadataProvider_dataset>
    </xsl:for-each>
        
        
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:metadataProvider_dataset/gmd:LW_Contact_dataset/gmd:id_contact_dataset/gco:CharacterString">
        <id_contact_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </id_contact_dataset>
    </xsl:for-each> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:contact_dataset/gmd:LW_Contact_dataset/gmd:individualName_contact_dataset/gmd:LW_IndividualName_contact_dataset/gmd:givenName_individualName_contact_dataset/gco:CharacterString">
        <givenName_individualName_contact_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </givenName_individualName_contact_dataset>
    </xsl:for-each> 
   <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:contact_dataset/gmd:LW_Contact_dataset/gmd:individualName_contact_dataset/gmd:LW_IndividualName_contact_dataset/gmd:surName_individualName_contact_dataset/gco:CharacterString">
        <surName_individualName_contact_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </surName_individualName_contact_dataset>
    </xsl:for-each> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:contact_dataset/gmd:LW_Contact_dataset/gmd:organizationName_contact_dataset/gco:CharacterString">      
        <organizationName_contact_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </organizationName_contact_dataset>
    </xsl:for-each> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:contact_dataset/gmd:LW_Contact_dataset/gmd:electronicMailAddress_contact_dataset/gco:CharacterString">
        <electronicMailAddress_contact_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </electronicMailAddress_contact_dataset>
    </xsl:for-each>
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:contact_dataset/gmd:LW_Contact_dataset/gmd:references_contact_dataset/gco:CharacterString">
        <references_contact_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </references_contact_dataset>
    </xsl:for-each>    
        
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:associatedParty_dataset/gmd:LW_AssociatedParty_dataset/gmd:id_associatedParty_dataset/gco:CharacterString">
        <id_associatedParty_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </id_associatedParty_dataset>
    </xsl:for-each>    
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:associatedParty_dataset/gmd:LW_AssociatedParty_dataset/gmd:individualName_associatedParty_dataset/gmd:LW_IndividualName_associatedParty_dataset/gmd:givenName_individualName_associatedParty_dataset/gco:CharacterString">
        <givenName_individualName_associatedParty_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </givenName_individualName_associatedParty_dataset>
    </xsl:for-each>   
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:associatedParty_dataset/gmd:LW_AssociatedParty_dataset/gmd:individualName_associatedParty_dataset/gmd:LW_IndividualName_associatedParty_dataset/gmd:surName_individualName_associatedParty_dataset/gco:CharacterString">
        <surName_individualName_associatedParty_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </surName_individualName_associatedParty_dataset>
    </xsl:for-each> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:associatedParty_dataset/gmd:LW_AssociatedParty_dataset/gmd:organizationName_associatedParty_dataset/gco:CharacterString">
        <organizationName_associatedParty_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </organizationName_associatedParty_dataset>
    </xsl:for-each> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:associatedParty_dataset/gmd:LW_AssociatedParty_dataset/gmd:electronicMailAddress_associatedParty_dataset/gco:CharacterString">
        <electronicMailAddress_associatedParty_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </electronicMailAddress_associatedParty_dataset>
    </xsl:for-each> 
    
    <!-- Description --> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:language_dataset/gco:CharacterString">
        <language_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </language_dataset>
    </xsl:for-each> 

    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:keywordSet_dataset/gmd:LW_KeywordSet_dataset/gmd:keyword_keywordSet_dataset/gco:CharacterString">
        <keyword_keywordSet_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </keyword_keywordSet_dataset>
    </xsl:for-each> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:keywordSet_dataset/gmd:LW_KeywordSet_dataset/gmd:keywordThesaurus_keywordSet_dataset/gco:CharacterString">
        <keywordThesaurus_keywordSet_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </keywordThesaurus_keywordSet_dataset>
    </xsl:for-each> 
        
    <!-- License -->
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:intellectualRights_dataset/gco:CharacterString">
        <intellectualRights_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </intellectualRights_dataset>
    </xsl:for-each>
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:licensed_dataset/gmd:LW_Licensed_dataset/gmd:licenseName_licensed_dataset/gco:CharacterString">
        <licenseName_licensed_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </licenseName_licensed_dataset>
    </xsl:for-each>
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:licensed_dataset/gmd:LW_Licensed_dataset/gmd:url_licensed_dataset/gco:CharacterString">
        <url_licensed_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </url_licensed_dataset>
    </xsl:for-each>
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:distribution_dataset/gmd:LW_Distribution_dataset/gmd:online_distribution_dataset/gmd:LW_Online_distribution_dataset/gmd:url_online_distribution_dataset/gco:CharacterString">
        <url_online_distribution_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </url_online_distribution_dataset>
    </xsl:for-each>    
        
    <!-- GeographicCoverage - Coverage - Dataset -->      
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:coverage_dataset/gmd:LW_Coverage_dataset/gmd:geographicCoverage_coverage_dataset/gmd:LW_GeographicCoverage_coverage_dataset/gmd:geographicDescription_geographicCoverage_coverage_dataset/gco:CharacterString">
        <geographicDescription_geographicCoverage_coverage_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </geographicDescription_geographicCoverage_coverage_dataset>
    </xsl:for-each>  
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:coverage_dataset/gmd:LW_Coverage_dataset/gmd:geographicCoverage_coverage_dataset/gmd:LW_GeographicCoverage_coverage_dataset/gmd:boundingCoordinates_geographicCoverage_coverage_dataset/gco:CharacterString">
        <boundingCoordinates_geographicCoverage_coverage_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </boundingCoordinates_geographicCoverage_coverage_dataset>
    </xsl:for-each>   
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:coverage_dataset/gmd:LW_Coverage_dataset/gmd:geographicCoverage_coverage_dataset/gmd:LW_GeographicCoverage_coverage_dataset/gmd:boundingCoordinates_geographicCoverage_coverage_dataset/gmd:LW_BoundingCoordinates_geographicCoverage_coverage_dataset/gmd:westBoundingCoordinates_boundingCoordinates_geographicCoverage_coverage_dataset/gco:CharacterString">
        <westBoundingCoordinates_boundingCoordinates_geographicCoverage_coverage_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </westBoundingCoordinates_boundingCoordinates_geographicCoverage_coverage_dataset>
    </xsl:for-each> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:coverage_dataset/gmd:LW_Coverage_dataset/gmd:geographicCoverage_coverage_dataset/gmd:LW_GeographicCoverage_coverage_dataset/gmd:boundingCoordinates_geographicCoverage_coverage_dataset/gmd:LW_BoundingCoordinates_geographicCoverage_coverage_dataset/gmd:eastBoundingCoordinates_boundingCoordinates_geographicCoverage_coverage_dataset/gco:CharacterString">
        <eastBoundingCoordinates_boundingCoordinates_geographicCoverage_coverage_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </eastBoundingCoordinates_boundingCoordinates_geographicCoverage_coverage_dataset>
    </xsl:for-each>     
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:coverage_dataset/gmd:LW_Coverage_dataset/gmd:geographicCoverage_coverage_dataset/gmd:LW_GeographicCoverage_coverage_dataset/gmd:boundingCoordinates_geographicCoverage_coverage_dataset/gmd:LW_BoundingCoordinates_geographicCoverage_coverage_dataset/gmd:northBoundingCoordinates_boundingCoordinates_geographicCoverage_coverage_dataset/gco:CharacterString">
        <northBoundingCoordinates_boundingCoordinates_geographicCoverage_coverage_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </northBoundingCoordinates_boundingCoordinates_geographicCoverage_coverage_dataset>
    </xsl:for-each>     
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:coverage_dataset/gmd:LW_Coverage_dataset/gmd:geographicCoverage_coverage_dataset/gmd:LW_GeographicCoverage_coverage_dataset/gmd:boundingCoordinates_geographicCoverage_coverage_dataset/gmd:LW_BoundingCoordinates_geographicCoverage_coverage_dataset/gmd:southBoundingCoordinates_boundingCoordinates_geographicCoverage_coverage_dataset/gco:CharacterString">
        <southBoundingCoordinates_boundingCoordinates_geographicCoverage_coverage_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </southBoundingCoordinates_boundingCoordinates_geographicCoverage_coverage_dataset>
    </xsl:for-each>    
        
    <!-- BeginDate - RangeOfDates - TemporalCoverage - Coverage - Dataset -->   
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:coverage_dataset/gmd:LW_Coverage_dataset/gmd:temporalCoverage_coverage_dataset/gmd:LW_TemporalCoverage_coverage_dataset/gmd:rangeOfDates_temporalCoverage_coverage_dataset/gmd:LW_RangeOfDates_temporalCoverage_coverage_dataset/gmd:beginDate_rangeOfDates_temporalCoverage_coverage_dataset/gmd:LW_BeginDate_rangeOfDates_temporalCoverage_coverage_dataset/gmd:calendarDate_beginDate_rangeOfDates_temporalCoverage_coverage_dataset/gco:Date">
        <calendarDate_beginDate_rangeOfDates_temporalCoverage_coverage_dataset>
            <xsl:variable name="date"
                        select="if (name() = 'gco:Date' and string-length(.) = 4)
                                then concat(., '-01-01T00:00:00')
                                else if (name() = 'gco:Date' and string-length(.) = 7)
                                then concat(., '-01T00:00:00')
                                else if (name() = 'gco:Date' or string-length(.) = 10)
                                then concat(., 'T00:00:00')
                                else if (contains(., '.'))
                                then tokenize(., '\.')[1]
                                else ."/>
            <xsl:value-of select="translate(string(
                                   adjust-dateTime-to-timezone(
                                      xs:dateTime($date),
                                      xs:dayTimeDuration('PT0H'))
                                     ), 'Z', '')"/>   
        </calendarDate_beginDate_rangeOfDates_temporalCoverage_coverage_dataset>
    </xsl:for-each>     
        
    <!-- EndDate - RangeOfDates - TemporalCoverage - Coverage - Dataset -->  
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:coverage_dataset/gmd:LW_Coverage_dataset/gmd:temporalCoverage_coverage_dataset/gmd:LW_TemporalCoverage_coverage_dataset/gmd:rangeOfDates_temporalCoverage_coverage_dataset/gmd:LW_RangeOfDates_temporalCoverage_coverage_dataset/gmd:endDate_rangeOfDates_temporalCoverage_coverage_dataset/gmd:LW_EndDate_rangeOfDates_temporalCoverage_coverage_dataset/gmd:calendarDate_endDate_rangeOfDates_temporalCoverage_coverage_dataset/gco:Date">
        <calendarDate_endDate_rangeOfDates_temporalCoverage_coverage_dataset>
            <xsl:variable name="date"
                        select="if (name() = 'gco:Date' and string-length(.) = 4)
                                then concat(., '-01-01T00:00:00')
                                else if (name() = 'gco:Date' and string-length(.) = 7)
                                then concat(., '-01T00:00:00')
                                else if (name() = 'gco:Date' or string-length(.) = 10)
                                then concat(., 'T00:00:00')
                                else if (contains(., '.'))
                                then tokenize(., '\.')[1]
                                else ."/>
            <xsl:value-of select="translate(string(
                                   adjust-dateTime-to-timezone(
                                      xs:dateTime($date),
                                      xs:dayTimeDuration('PT0H'))
                                     ), 'Z', '')"/>
        </calendarDate_endDate_rangeOfDates_temporalCoverage_coverage_dataset>
    </xsl:for-each>  
        
    <!-- TaxonomicClassification - TaxonomicCoverage - Coverage - Dataset -->       
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:coverage_dataset/gmd:LW_Coverage_dataset/gmd:taxonomicCoverage_coverage_dataset/gmd:LW_TaxonomicCoverage_coverage_dataset/gmd:taxonomicClassification_taxonomicCoverage_coverage_dataset/gmd:LW_TaxonomicClassification_taxonomicCoverage_coverage_dataset/gmd:taxonID_taxonomicClassification_taxonomicCoverage_coverage_dataset/gco:CharacterString">
        <taxonID_taxonomicClassification_taxonomicCoverage_coverage_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </taxonID_taxonomicClassification_taxonomicCoverage_coverage_dataset>
    </xsl:for-each>  
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:coverage_dataset/gmd:LW_Coverage_dataset/gmd:taxonomicCoverage_coverage_dataset/gmd:LW_TaxonomicCoverage_coverage_dataset/gmd:taxonomicClassification_taxonomicCoverage_coverage_dataset/gmd:LW_TaxonomicClassification_taxonomicCoverage_coverage_dataset/gmd:taxonRankName_taxonomicClassification_taxonomicCoverage_coverage_dataset/gco:CharacterString">
        <taxonRankName_taxonomicClassification_taxonomicCoverage_coverage_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </taxonRankName_taxonomicClassification_taxonomicCoverage_coverage_dataset>
    </xsl:for-each>
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:coverage_dataset/gmd:LW_Coverage_dataset/gmd:taxonomicCoverage_coverage_dataset/gmd:LW_TaxonomicCoverage_coverage_dataset/gmd:taxonomicClassification_taxonomicCoverage_coverage_dataset/gmd:LW_TaxonomicClassification_taxonomicCoverage_coverage_dataset/gmd:taxonRankValue_taxonomicClassification_taxonomicCoverage_coverage_dataset/gco:CharacterString">
        <taxonRankValue_taxonomicClassification_taxonomicCoverage_coverage_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </taxonRankValue_taxonomicClassification_taxonomicCoverage_coverage_dataset>
    </xsl:for-each> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:coverage_dataset/gmd:LW_Coverage_dataset/gmd:taxonomicCoverage_coverage_dataset/gmd:LW_TaxonomicCoverage_coverage_dataset/gmd:taxonomicClassification_taxonomicCoverage_coverage_dataset/gmd:LW_TaxonomicClassification_taxonomicCoverage_coverage_dataset/gmd:commonName_taxonomicClassification_taxonomicCoverage_coverage_dataset/gco:CharacterString">
        <commonName_taxonomicClassification_taxonomicCoverage_coverage_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </commonName_taxonomicClassification_taxonomicCoverage_coverage_dataset>
    </xsl:for-each>
        
    <!-- Description - MethodStep - Methods - Dataset -->         
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:methods_dataset/gmd:LW_Methods_dataset/gmd:methodStep_methods_dataset/gmd:LW_MethodStep_methods_dataset/gmd:description_methodStep_methods_dataset/gmd:LW_Description_methodStep_methods_dataset/gmd:para_description_methodStep_methods_dataset/gco:CharacterString">
        <para_description_methodStep_methods_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </para_description_methodStep_methods_dataset>
    </xsl:for-each> 
        
    <!-- Citation - MethodStep - Methods - Dataset -->       
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:methods_dataset/gmd:LW_Methods_dataset/gmd:methodStep_methods_dataset/gmd:LW_MethodStep_methods_dataset/gmd:citation_methodStep_methods_dataset/gmd:LW_Citation_methodStep_methods_dataset/gmd:bibtex_citation_methodStep_methods_dataset/gco:CharacterString">
        <bibtex_citation_methodStep_methods_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </bibtex_citation_methodStep_methods_dataset>
    </xsl:for-each>
        
    <!-- MethodStep - Methods - Dataset -->      
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:methods_dataset/gmd:LW_Methods_dataset/gmd:methodStep_methods_dataset/gmd:LW_MethodStep_methods_dataset/gmd:instrumentation_methodStep_methods_dataset/gco:CharacterString">
        <instrumentation_methodStep_methods_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </instrumentation_methodStep_methods_dataset>
    </xsl:for-each>    
        
    <!-- Software - MethodStep - Methods - Dataset -->      
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:methods_dataset/gmd:LW_Methods_dataset/gmd:methodStep_methods_dataset/gmd:LW_MethodStep_methods_dataset/gmd:software_methodStep_methods_dataset/gmd:LW_Software_methodStep_methods_dataset/gmd:title_software_methodStep_methods_dataset/gco:CharacterString">
        <title_software_methodStep_methods_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </title_software_methodStep_methods_dataset>
    </xsl:for-each>        
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:methods_dataset/gmd:LW_Methods_dataset/gmd:methodStep_methods_dataset/gmd:LW_MethodStep_methods_dataset/gmd:software_methodStep_methods_dataset/gmd:LW_Software_methodStep_methods_dataset/gmd:references_software_methodStep_methods_dataset/gco:CharacterString">
        <references_software_methodStep_methods_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </references_software_methodStep_methods_dataset>
    </xsl:for-each>    
    
    <!-- SamplingDescription - Sampling - Methods - Dataset -->      
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:methods_dataset/gmd:LW_Methods_dataset/gmd:sampling_methods_dataset/gmd:LW_Sampling_methods_dataset/gmd:samplingDescription_sampling_methods_dataset/gmd:LW_SamplingDescription_sampling_methods_dataset/gmd:para_samplingDescription_sampling_methods_dataset/gco:CharacterString">
        <para_samplingDescription_sampling_methods_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </para_samplingDescription_sampling_methods_dataset>
    </xsl:for-each>    
        
    <!-- Project - Dataset -->      
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:project_dataset/gmd:LW_Project_dataset/gmd:title_project_dataset/gco:CharacterString">
        <title_project_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </title_project_dataset>
    </xsl:for-each>     
        
    <!-- Personnel - Project - Dataset -->      
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:project_dataset/gmd:LW_Project_dataset/gmd:personnel_project_dataset/gmd:LW_Personnel_project_dataset/gmd:individualName_personnel_project_dataset/gco:CharacterString">
        <individualName_personnel_project_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </individualName_personnel_project_dataset>
    </xsl:for-each>    
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:project_dataset/gmd:LW_Project_dataset/gmd:personnel_project_dataset/gmd:LW_Personnel_project_dataset/gmd:positionName_personnel_project_dataset/gco:CharacterString">
        <positionName_personnel_project_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </positionName_personnel_project_dataset>
    </xsl:for-each>       
    
    <!-- Organization - Personnel - Project - Dataset -->         
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:project_dataset/gmd:LW_Project_dataset/gmd:personnel_project_dataset/gmd:LW_Personnel_project_dataset/gmd:organization_personnel_project_dataset/gmd:LW_Organization_personnel_project_dataset/gmd:name_organization_personnel_project_dataset/gco:CharacterString">
        <name_organization_personnel_project_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </name_organization_personnel_project_dataset>
    </xsl:for-each>
      
    <!-- Datatable - Dataset -->
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:datatable_dataset/gmd:LW_Datatable_dataset/gmd:entityName_datatable_dataset/gco:CharacterString">    
        <entityName_datatable_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </entityName_datatable_dataset>
    </xsl:for-each>    
    <!-- ExternallyDefinedFormat - DataFormat - Physical - Datatable - Dataset -->
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:datatable_dataset/gmd:LW_Datatable_dataset/gmd:physical_datatable_dataset/gmd:LW_Physical_datatable_dataset/gmd:dataFormat_physical_datatable_dataset/gmd:LW_DataFormat_physical_datatable_dataset/gmd:externallyDefinedFormat_dataFormat_physical_datatable_dataset/gmd:LW_ExternallyDefinedFormat_dataFormat_physical_datatable_dataset/gmd:formatName_externallyDefinedFormat_dataFormat_physical_datatable_dataset/gco:CharacterString">    
        <formatName_externallyDefinedFormat_dataFormat_physical_datatable_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </formatName_externallyDefinedFormat_dataFormat_physical_datatable_dataset>
    </xsl:for-each>    
    <!-- AttributeList - Datatable - Dataset --> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:datatable_dataset/gmd:LW_Datatable_dataset/gmd:attributeList_datatable_dataset/gmd:LW_AttributeList_datatable_dataset/gmd:attributeName_attributeList_datatable_dataset/gco:CharacterString">
        <attributeName_attributeList_datatable_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </attributeName_attributeList_datatable_dataset>
    </xsl:for-each>     
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:datatable_dataset/gmd:LW_Datatable_dataset/gmd:attributeList_datatable_dataset/gmd:LW_AttributeList_datatable_dataset/gmd:attributeLabel_attributeList_datatable_dataset/gco:CharacterString">    
        <attributeLabel_attributeList_datatable_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </attributeLabel_attributeList_datatable_dataset>
    </xsl:for-each>
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:datatable_dataset/gmd:LW_Datatable_dataset/gmd:attributeList_datatable_dataset/gmd:LW_AttributeList_datatable_dataset/gmd:attributeDefinition_attributeList_datatable_dataset/gco:CharacterString">
        <attributeDefinition_attributeList_datatable_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </attributeDefinition_attributeList_datatable_dataset>
    </xsl:for-each>    
    <!-- Unit - Ratio - MeasurementScale - AttributeList - Datatable - Dataset -->      
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:datatable_dataset/gmd:LW_Datatable_dataset/gmd:attributeList_datatable_dataset/gmd:LW_AttributeList_datatable_dataset/gmd:measurementScale_attributeList_datatable_dataset/gmd:LW_MeasurementScale_attributeList_datatable_dataset/gmd:ratio_measurementScale_attributeList_datatable_dataset/gmd:LW_Ratio_measurementScale_attributeList_datatable_dataset/gmd:unit_ratio_measurementScale_attributeList_datatable_dataset/gmd:LW_Unit_ratio_measurementScale_attributeList_datatable_dataset/gmd:standardUnit_unit_ratio_measurementScale_attributeList_datatable_dataset/gco:CharacterString">    
        <standardUnit_unit_ratio_measurementScale_attributeList_datatable_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </standardUnit_unit_ratio_measurementScale_attributeList_datatable_dataset>
    </xsl:for-each>     
    <!-- MissingValueCode - AttributeList - Datatable - Dataset -->  
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:datatable_dataset/gmd:LW_Datatable_dataset/gmd:attributeList_datatable_dataset/gmd:LW_AttributeList_datatable_dataset/gmd:missingValueCode_attributeList_datatable_dataset/gmd:LW_MissingValueCode_attributeList_datatable_dataset/gmd:code_missingValueCode_attributeList_datatable_dataset/gco:CharacterString">
        <code_missingValueCode_attributeList_datatable_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </code_missingValueCode_attributeList_datatable_dataset>
    </xsl:for-each> 
    <!-- AttributeAnnotation - AttributeList - Datatable - Dataset -->
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:datatable_dataset/gmd:LW_Datatable_dataset/gmd:attributeList_datatable_dataset/gmd:LW_AttributeList_datatable_dataset/gmd:attributeAnnotation_attributeList_datatable_dataset/gmd:LW_AttributeAnnotation_attributeList_datatable_dataset/gmd:propertyURI_attributeAnnotation_attributeList_datatable_dataset/gco:CharacterString">
        <propertyURI_attributeAnnotation_attributeList_datatable_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </propertyURI_attributeAnnotation_attributeList_datatable_dataset>
    </xsl:for-each> 
    <xsl:for-each select="gmd:dataset/gmd:LW_Dataset/gmd:datatable_dataset/gmd:LW_Datatable_dataset/gmd:attributeList_datatable_dataset/gmd:LW_AttributeList_datatable_dataset/gmd:attributeAnnotation_attributeList_datatable_dataset/gmd:LW_AttributeAnnotation_attributeList_datatable_dataset/gmd:valueURI_attributeAnnotation_attributeList_datatable_dataset/gco:CharacterString">
        <valueURI_attributeAnnotation_attributeList_datatable_dataset>
          <xsl:value-of select="normalize-space(.)"/>
        </valueURI_attributeAnnotation_attributeList_datatable_dataset>
    </xsl:for-each>     
        
    <!-- End Dataset LifeWatch -->
      
      <xsl:for-each select="gmd:dataQualityInfo/*">

        <xsl:for-each select="gmd:lineage/gmd:LI_Lineage/
                                gmd:statement/gco:CharacterString[. != '']">
          <lineage>
            <xsl:value-of select="."/>
          </lineage>
        </xsl:for-each>
        
        <!-- Indexing measure value -->
        <xsl:for-each select="gmd:report/*[
                normalize-space(gmd:nameOfMeasure[0]/gco:CharacterString) != '']">
          <xsl:variable name="measureName"
                        select="replace(
                                normalize-space(
                                  gmd:nameOfMeasure[0]/gco:CharacterString), ' ', '-')"/>
          <xsl:for-each select="gmd:result/gmd:DQ_QuantitativeResult/gmd:value">
            <xsl:if test=". != ''">
              <xsl:element name="measure_{replace($measureName, '[^a-zA-Z0-9]', '')}">
                <xsl:value-of select="."/>
              </xsl:element>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:for-each>
      <!-- end LifeWatch -->
      
      <!-- # Languages -->
      <mainLanguage>
        <xsl:value-of select="$mainLanguage"/>
      </mainLanguage>

      <xsl:for-each select="$otherLanguages">
        <otherLanguage>
          <xsl:value-of select="."/>
        </otherLanguage>
      </xsl:for-each>


      <!-- # Resource type -->
      <xsl:choose>
        <xsl:when test="$isDataset">
          <resourceType>dataset</resourceType>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="gmd:hierarchyLevel/gmd:MD_ScopeCode/
                              @codeListValue[normalize-space(.) != '']">
            <resourceType>
              <xsl:value-of select="."/>
            </resourceType>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>


      <!-- Indexing metadata contact -->
      <xsl:apply-templates mode="index-contact" select="gmd:contact">
        <xsl:with-param name="fieldSuffix" select="''"/>
      </xsl:apply-templates>

      <!-- Indexing all codelist

      Indexing method is:
      <gmd:accessConstraints>
        <gmd:MD_RestrictionCode codeListValue="otherRestrictions"
        is indexed as
        codelist_accessConstraints:otherRestrictions

        Exclude some useless codelist like
        Contact role, Date type.
      -->
      <xsl:for-each select=".//*[@codeListValue != '' and
                            name() != 'gmd:CI_RoleCode' and
                            name() != 'gmd:CI_DateTypeCode' and
                            name() != 'gmd:LanguageCode'
                            ]">
        <xsl:element name="codelist_{local-name(..)}">
          <xsl:value-of select="@codeListValue"/>
        </xsl:element>
      </xsl:for-each>


      <!-- Indexing resource information
      TODO: Should we support multiple identification in the same record
      eg. nl db60a314-5583-437d-a2ff-1e59cc57704e
      Also avoid error when records contains multiple MD_IdentificationInfo
      or SRV_ServiceIdentification or a mix
      eg. de 8bb5334f-558b-982b-7b12-86ea486540d7
      -->
      <xsl:for-each select="gmd:identificationInfo[1]/*[1]">
        <xsl:for-each select="gmd:citation/gmd:CI_Citation">
          <resourceTitle>
            <xsl:value-of select="gmd:title/gco:CharacterString/text()"/>
          </resourceTitle>
          <resourceAltTitle>
            <xsl:value-of
              select="gmd:alternateTitle/gco:CharacterString/text()"/>
          </resourceAltTitle>

          <xsl:for-each select="gmd:date/gmd:CI_Date[gmd:date/*/text() != '' and
                                  matches(gmd:date/*/text(), '[0-9]{4}.*')]">
            <xsl:variable name="dateType"
                          select="gmd:dateType[1]/gmd:CI_DateTypeCode/@codeListValue"
                          as="xs:string?"/>
            <xsl:variable name="date"
                          select="string(gmd:date[1]/gco:Date|gmd:date[1]/gco:DateTime)"/>
            <xsl:element name="{$dateType}DateForResource">
              <xsl:value-of select="$date"/>
            </xsl:element>
            <xsl:element name="{$dateType}YearForResource">
              <xsl:value-of select="substring($date, 0, 5)"/>
            </xsl:element>
            <xsl:element name="{$dateType}MonthForResource">
              <xsl:value-of select="substring($date, 0, 8)"/>
            </xsl:element>
          </xsl:for-each>

          <xsl:for-each
            select="gmd:presentationForm/gmd:CI_PresentationFormCode/@codeListValue[. != '']">
            <presentationForm>
              <xsl:value-of select="."/>
            </presentationForm>
          </xsl:for-each>
        </xsl:for-each>

        <resourceAbstract>
          <xsl:value-of select="substring(
                gmd:abstract/gco:CharacterString,
                0, $maxFieldLength)"/>
        </resourceAbstract>


        <!-- Indexing resource contact -->
        <xsl:apply-templates mode="index-contact"
                             select="gmd:pointOfContact">
          <xsl:with-param name="fieldSuffix" select="'ForResource'"/>
        </xsl:apply-templates>

        <xsl:for-each select="gmd:credit/*[. != '']">
          <resourceCredit>
            <xsl:value-of select="."/>
          </resourceCredit>
        </xsl:for-each>


        <xsl:variable name="overviews"
                      select="gmd:graphicOverview/gmd:MD_BrowseGraphic/
                              gmd:fileName/gco:CharacterString[. != '']"/>
        <hasOverview>
          <xsl:value-of select="if (count($overviews) > 0) then 'true' else 'false'"/>
        </hasOverview>

        <xsl:for-each select="$overviews">
          <overviewUrl>
            <xsl:value-of select="."/>
          </overviewUrl>
        </xsl:for-each>

        <xsl:for-each
          select="gmd:language/gco:CharacterString|gmd:language/gmd:LanguageCode/@codeListValue">
          <resourceLanguage>
            <xsl:value-of select="."/>
          </resourceLanguage>
        </xsl:for-each>


        <!-- TODO: create specific INSPIRE template or mode -->
        <!-- INSPIRE themes

        Select the first thesaurus title because some records
        may contains many even if invalid.

        Also get the first title at it may happen that a record
        have more than one.

        Select any thesaurus having the title containing "INSPIRE themes".
        Some records have "GEMET-INSPIRE themes" eg. sk:ee041534-b8f3-4683-b9dd-9544111a0712
        Some other "GEMET - INSPIRE themes"

        Take in account gmd:descriptiveKeywords or srv:keywords
        -->
        <!-- TODO: Some MS may be using a translated version of the thesaurus title -->
        <xsl:variable name="inspireKeywords"
                      select="*/gmd:MD_Keywords[
                      contains(lower-case(
                       gmd:thesaurusName[1]/*/gmd:title[1]/*[1]/text()
                       ), 'gemet') and
                       contains(lower-case(
                       gmd:thesaurusName[1]/*/gmd:title[1]/*[1]/text()
                       ), 'inspire')]
                  /gmd:keyword"/>
        <xsl:for-each
          select="$inspireKeywords">
          <xsl:variable name="position" select="position()"/>
          <xsl:for-each select="gco:CharacterString[. != '']|
                                gmx:Anchor[. != '']">
            <xsl:variable name="inspireTheme" as="xs:string"
                          select="index:analyzeField('synInspireThemes', text())"/>
            <inspireTheme_syn>
              <xsl:value-of select="text()"/>
            </inspireTheme_syn>
            <inspireTheme>
              <xsl:value-of select="$inspireTheme"/>
            </inspireTheme>

            <!--
            WARNING: Here we only index the first keyword in order
            to properly compute one INSPIRE annex.
            -->
            <xsl:if test="$position = 1">
              <inspireThemeFirst_syn>
                <xsl:value-of select="text()"/>
              </inspireThemeFirst_syn>
              <inspireThemeFirst>
                <xsl:value-of select="$inspireTheme"/>
              </inspireThemeFirst>
              <inspireAnnexForFirstTheme>
                <xsl:value-of
                  select="index:analyzeField('synInspireAnnexes', $inspireTheme)"/>
              </inspireAnnexForFirstTheme>
            </xsl:if>
            <inspireAnnex>
              <xsl:value-of
                select="index:analyzeField('synInspireAnnexes', $inspireTheme)"/>
            </inspireAnnex>
          </xsl:for-each>
        </xsl:for-each>

        <!-- For services, the count does not take into account
        dataset's INSPIRE themes which are transfered to the service
        by service-dataset-task. -->
        <inspireThemeNumber>
          <xsl:value-of
            select="count($inspireKeywords)"/>
        </inspireThemeNumber>

        <hasInspireTheme>
          <xsl:value-of
            select="if (count($inspireKeywords) > 0) then 'true' else 'false'"/>
        </hasInspireTheme>

        <!-- Index all keywords -->
        <xsl:variable name="keywords"
                      select="*/gmd:MD_Keywords/
                                gmd:keyword/gco:CharacterString|
                              */gmd:MD_Keywords/
                                gmd:keyword/gmd:PT_FreeText/gmd:textGroup/
                                  gmd:LocalisedCharacterString"/>

        <tagNumber>
          <xsl:value-of select="count($keywords)"/>
        </tagNumber>

        <xsl:for-each select="$keywords">
          <tag>
            <xsl:value-of select="text()"/>
          </tag>
        </xsl:for-each>

        <xsl:variable name="isOpenData">
          <xsl:for-each select="$keywords">
            <xsl:if test="matches(
                            normalize-unicode(replace(normalize-unicode(
                              lower-case(normalize-space(text())), 'NFKD'), '\p{Mn}', ''), 'NFKC'),
                            $openDataKeywords)">
              <xsl:value-of select="'true'"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="normalize-space($isOpenData) != ''">
            <isOpenData>true</isOpenData>
          </xsl:when>
          <xsl:otherwise>
            <isOpenData>false</isOpenData>
          </xsl:otherwise>
        </xsl:choose>

        <!-- Index keywords which are of type place -->
        <xsl:for-each
          select="*/gmd:MD_Keywords/
                          gmd:keyword[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue = 'place']/
                            gco:CharacterString|
                        */gmd:MD_Keywords/
                          gmd:keyword[gmd:type/gmd:MD_KeywordTypeCode/@codeListValue = 'place']/
                            gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString">
          <geotag>
            <xsl:value-of select="text()"/>
          </geotag>
        </xsl:for-each>


        <!-- Index all keywords having a specific thesaurus -->
        <xsl:for-each
          select="*/gmd:MD_Keywords[gmd:thesaurusName]">

          <xsl:variable name="thesaurusName"
                        select="gmd:thesaurusName[1]/gmd:CI_Citation/
                                  gmd:title[1]/gco:CharacterString"/>

          <xsl:variable name="thesaurusId"
                        select="normalize-space(gmd:thesaurusName/gmd:CI_Citation/
                                  gmd:identifier[position() = 1]/gmd:MD_Identifier/
                                    gmd:code/(gco:CharacterString|gmx:Anchor)/text())"/>

          <xsl:variable name="key">
            <xsl:choose>
              <xsl:when test="$thesaurusId != ''">
                <xsl:value-of select="$thesaurusId"/>
              </xsl:when>
              <!-- Try to build a thesaurus key based on the name
              by removing space - to be improved. -->
              <xsl:when test="normalize-space($thesaurusName) != ''">
                <xsl:value-of select="replace($thesaurusName, ' ', '-')"/>
              </xsl:when>
            </xsl:choose>
          </xsl:variable>

          <xsl:if test="normalize-space($key) != ''">
            <!-- Index keyword characterString including multilingual ones
             and element like gmx:Anchor including the href attribute
             which may contains keyword identifier. -->
            <xsl:variable name="thesaurusField"
                          select="concat('thesaurus_', replace($key, '[^a-zA-Z0-9]', ''))"/>

            <xsl:element name="{$thesaurusField}Number">
              <xsl:value-of select="count(gmd:keyword/(*[normalize-space() != '']))"/>
            </xsl:element>

            <xsl:for-each select="gmd:keyword/(*[normalize-space() != '']|
                                  */@xlink:href[normalize-space() != '']|
                                  gmd:PT_FreeText/gmd:textGroup/gmd:LocalisedCharacterString[normalize-space() != ''])">
              <xsl:element name="{$thesaurusField}">
                <xsl:value-of select="normalize-space(.)"/>
              </xsl:element>
            </xsl:for-each>
          </xsl:if>
        </xsl:for-each>


        <xsl:for-each select="gmd:topicCategory/gmd:MD_TopicCategoryCode">
          <topic>
            <xsl:value-of select="."/>
          </topic>
          <!-- TODO: Get translation ? -->
        </xsl:for-each>


        <xsl:for-each select="gmd:spatialResolution/gmd:MD_Resolution">
          <xsl:for-each
            select="gmd:equivalentScale/gmd:MD_RepresentativeFraction/gmd:denominator/gco:Integer[. != '']">
            <resolutionScaleDenominator>
              <xsl:value-of select="."/>
            </resolutionScaleDenominator>
          </xsl:for-each>

          <xsl:for-each select="gmd:distance/gco:Distance[. != '']">
            <resolutionDistance>
              <xsl:value-of select="concat(., ' ', @uom)"/>
            </resolutionDistance>
          </xsl:for-each>
        </xsl:for-each>

        <xsl:for-each
          select="gmd:spatialRepresentationType/gmd:MD_SpatialRepresentationTypeCode/@codeListValue[. != '']">
          <spatialRepresentationType>
            <xsl:value-of select="."/>
          </spatialRepresentationType>
        </xsl:for-each>


        <xsl:for-each select="gmd:resourceConstraints">
          <xsl:for-each
            select="*/gmd:accessConstraints/gmd:MD_RestrictionCode/@codeListValue[. != '']">
            <accessConstraints>
              <xsl:value-of select="."/>
            </accessConstraints>
          </xsl:for-each>
          <xsl:for-each
            select="*/gmd:otherConstraints/gco:CharacterString[. != '']">
            <otherConstraints>
              <xsl:value-of select="."/>
            </otherConstraints>
          </xsl:for-each>
          <xsl:for-each
            select="*/gmd:classification/gmd:MD_ClassificationCode/@codeListValue[. != '']">
            <constraintClassification>
              <xsl:value-of select="."/>
            </constraintClassification>
          </xsl:for-each>
          <xsl:for-each
            select="*/gmd:useLimitation/gco:CharacterString[. != '']">
            <useLimitation>
              <xsl:value-of select="."/>
            </useLimitation>
          </xsl:for-each>
        </xsl:for-each>


        <xsl:for-each select="*/gmd:EX_Extent">

          <xsl:for-each select="gmd:geographicElement/gmd:EX_GeographicDescription/
            gmd:geographicIdentifier/gmd:MD_Identifier/
            gmd:code/gco:CharacterString[normalize-space(.) != '']">
            <geoTag>
              <xsl:value-of select="."/>
            </geoTag>
          </xsl:for-each>

          <!-- TODO: index bounding polygon -->
          <xsl:for-each select=".//gmd:EX_GeographicBoundingBox[
                                ./gmd:westBoundLongitude/gco:Decimal castable as xs:decimal and
                                ./gmd:eastBoundLongitude/gco:Decimal castable as xs:decimal and
                                ./gmd:northBoundLatitude/gco:Decimal castable as xs:decimal and
                                ./gmd:southBoundLatitude/gco:Decimal castable as xs:decimal
                                ]">
            <xsl:variable name="format" select="'#0.000000'"></xsl:variable>

            <xsl:variable name="w"
                          select="format-number(./gmd:westBoundLongitude/gco:Decimal/text(), $format)"/>
            <xsl:variable name="e"
                          select="format-number(./gmd:eastBoundLongitude/gco:Decimal/text(), $format)"/>
            <xsl:variable name="n"
                          select="format-number(./gmd:northBoundLatitude/gco:Decimal/text(), $format)"/>
            <xsl:variable name="s"
                          select="format-number(./gmd:southBoundLatitude/gco:Decimal/text(), $format)"/>

            <!-- Example: ENVELOPE(-10, 20, 15, 10) which is minX, maxX, maxY, minY order
            http://wiki.apache.org/solr/SolrAdaptersForLuceneSpatial4
            https://cwiki.apache.org/confluence/display/solr/Spatial+Search

            bbox field type limited to one. TODO
            <xsl:if test="position() = 1">
              <bbox>
                <xsl:text>ENVELOPE(</xsl:text>
                <xsl:value-of select="$w"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$e"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$n"/>
                <xsl:text>,</xsl:text>
                <xsl:value-of select="$s"/>
                <xsl:text>)</xsl:text>
              </field>
            </xsl:if>
            -->
            <xsl:choose>
              <xsl:when test="-180 &lt;= number($e) and number($e) &lt;= 180 and
                              -180 &lt;= number($w) and number($w) &lt;= 180 and
                              -90 &lt;= number($s) and number($s) &lt;= 90 and
                              -90 &lt;= number($n) and number($n) &lt;= 90">
                <xsl:choose>
                  <xsl:when test="$e = $w and $s = $n">
                    <location><xsl:value-of select="concat($s, ',', $w)"/></location>
                  </xsl:when>
                  <xsl:when
                    test="($e = $w and $s != $n) or ($e != $w and $s = $n)">
                    <!-- Probably an invalid bbox indexing a point only -->
                    <location><xsl:value-of select="concat($s, ',', $w)"/></location>
                  </xsl:when>
                  <xsl:otherwise>
                    <geom>
                      <xsl:text>{"type": "polygon",</xsl:text>
                      <xsl:text>"coordinates": [</xsl:text>
                      <xsl:value-of select="concat('[', $w, ',', $s, ']')"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="concat('[', $e, ',', $s, ']')"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="concat('[', $e, ',', $n, ']')"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="concat('[', $w, ',', $n, ']')"/>
                      <xsl:text>,</xsl:text>
                      <xsl:value-of select="concat('[', $w, ',', $s, ']')"/>
                      <xsl:text>]}</xsl:text>
                    </geom>

                    <location><xsl:value-of select="concat(
                                              (number($s) + number($n)) div 2,
                                              ',',
                                              (number($w) + number($e)) div 2)"/></location>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:otherwise></xsl:otherwise>
            </xsl:choose>


            <!--<xsl:value-of select="($e + $w) div 2"/>,<xsl:value-of select="($n + $s) div 2"/></field>-->
          </xsl:for-each>
        </xsl:for-each>


        <!-- Service information -->
        <xsl:for-each select="srv:serviceType/gco:LocalName">
          <serviceType>
            <xsl:value-of select="text()"/>
          </serviceType>
          <xsl:variable name="inspireServiceType" as="xs:string"
                        select="index:analyzeField(
                                  'keepInspireServiceTypes', text())"/>
          <xsl:if test="$inspireServiceType != ''">
            <inspireServiceType>
              <xsl:value-of select="lower-case($inspireServiceType)"/>
            </inspireServiceType>
          </xsl:if>
          <xsl:if test="following-sibling::srv:serviceTypeVersion">
            <serviceTypeAndVersion>
              <xsl:value-of select="concat(
                        text(),
                        $separator,
                        following-sibling::srv:serviceTypeVersion/gco:CharacterString/text())"/>
            </serviceTypeAndVersion>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>


      <xsl:for-each select="gmd:referenceSystemInfo/gmd:MD_ReferenceSystem">
        <xsl:for-each select="gmd:referenceSystemIdentifier/gmd:RS_Identifier">
          <xsl:variable name="crs" select="gmd:code/gco:CharacterString"/>

          <xsl:if test="$crs != ''">
            <coordinateSystem>
              <xsl:value-of select="$crs"/>
            </coordinateSystem>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>


      <!-- INSPIRE Conformity -->

      <!-- Conformity for services -->
      <xsl:choose>
        <xsl:when test="$isService">
          <xsl:for-each-group select="gmd:dataQualityInfo/*/gmd:report"
                              group-by="*/gmd:result/*/gmd:specification/gmd:CI_Citation/
        gmd:title/gco:CharacterString">
            <xsl:variable name="title" select="current-grouping-key()"/>
            <xsl:variable name="matchingEUText"
                          select="if ($inspireRegulationLaxCheck)
                                  then daobs:search-in-contains($eu9762009/*, $title)
                                  else daobs:search-in($eu9762009/*, $title)"/>
            <xsl:if test="count($matchingEUText) = 1">
              <xsl:variable name="pass"
                            select="*/gmd:result/*/gmd:pass/gco:Boolean"/>
              <inspireConformResource>
                <xsl:value-of select="$pass"/>
              </inspireConformResource>
            </xsl:if>
          </xsl:for-each-group>
        </xsl:when>
        <xsl:otherwise>
          <!-- Conformity for dataset -->
          <xsl:for-each-group select="gmd:dataQualityInfo/*/gmd:report"
                              group-by="*/gmd:result/*/gmd:specification/gmd:CI_Citation/
        gmd:title/gco:CharacterString">

            <xsl:variable name="title" select="current-grouping-key()"/>
            <xsl:variable name="matchingEUText"
                          select="if ($inspireRegulationLaxCheck)
                                  then daobs:search-in-contains($eu10892010/*, $title)
                                  else daobs:search-in($eu10892010/*, $title)"/>

            <xsl:if test="count($matchingEUText) = 1">
              <xsl:variable name="pass"
                            select="*/gmd:result/*/gmd:pass/gco:Boolean"/>
              <inspireConformResource>
                <xsl:value-of select="$pass"/>
              </inspireConformResource>
            </xsl:if>
          </xsl:for-each-group>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:for-each-group select="gmd:dataQualityInfo/*/gmd:report"
                          group-by="*/gmd:result/*/gmd:specification/
                                      */gmd:title/gco:CharacterString">
        <xsl:variable name="title" select="current-grouping-key()"/>
        <xsl:variable name="pass" select="*/gmd:result/*/gmd:pass/gco:Boolean"/>
        <xsl:if test="$pass">
          <xsl:element name="conformTo_{replace(normalize-space($title), '[^a-zA-Z0-9]', '')}">
            <xsl:value-of select="$pass"/>
          </xsl:element>
        </xsl:if>
      </xsl:for-each-group>


      <xsl:for-each select="gmd:dataQualityInfo/*">

        <xsl:for-each select="gmd:lineage/gmd:LI_Lineage/
                                gmd:statement/gco:CharacterString[. != '']">
          <lineage>
            <xsl:value-of select="."/>
          </lineage>
        </xsl:for-each>


        <!-- Indexing measure value -->
        <xsl:for-each select="gmd:report/*[
                normalize-space(gmd:nameOfMeasure[0]/gco:CharacterString) != '']">
          <xsl:variable name="measureName"
                        select="replace(
                                normalize-space(
                                  gmd:nameOfMeasure[0]/gco:CharacterString), ' ', '-')"/>
          <xsl:for-each select="gmd:result/gmd:DQ_QuantitativeResult/gmd:value">
            <xsl:if test=". != ''">
              <xsl:element name="measure_{replace($measureName, '[^a-zA-Z0-9]', '')}">
                <xsl:value-of select="."/>
              </xsl:element>
            </xsl:if>
          </xsl:for-each>
        </xsl:for-each>
      </xsl:for-each>


      <xsl:for-each select="gmd:distributionInfo/*">
        <xsl:for-each
          select="gmd:distributionFormat/*/gmd:name/gco:CharacterString">
          <format>
            <xsl:value-of select="."/>
          </format>
        </xsl:for-each>

        <xsl:for-each select="gmd:transferOptions/*/
                                gmd:onLine/*[gmd:linkage/gmd:URL != '']">

          <xsl:variable name="protocol"
                        select="gmd:protocol/gco:CharacterString/text()"/>
          <xsl:variable name="linkName"
                        select="gn-fn-index:json-escape(gmd:name/gco:CharacterString/text())"/>

          <linkUrl>
            <xsl:value-of select="gmd:linkage/gmd:URL"/>
          </linkUrl>
          <linkProtocol>
            <xsl:value-of select="$protocol"/>
          </linkProtocol>
          <xsl:element name="linkUrlProtocol{replace($protocol, '[^a-zA-Z0-9]', '')}">
            <xsl:value-of select="gmd:linkage/gmd:URL"/>
          </xsl:element>
          <link type="object">{
            "protocol":"<xsl:value-of select="gn-fn-index:json-escape(gmd:protocol/*/text())"/>",
            "url":"<xsl:value-of select="gn-fn-index:json-escape(gmd:linkage/gmd:URL)"/>",
            "name":"<xsl:value-of select="$linkName"/>",
            "description":"<xsl:value-of select="gn-fn-index:json-escape(gmd:description/gco:CharacterString/text())"/>"
            }
            <!--Link object in Angular used to be
            //     name: linkInfos[0],
            //     title: linkInfos[0],
            //     url: linkInfos[2],
            //     desc: linkInfos[1],
            //     protocol: linkInfos[3],
            //     contentType: linkInfos[4],
            //     group: linkInfos[5] ? parseInt(linkInfos[5]) : undefined,
            //     applicationProfile: linkInfos[6]-->
          </link>

          <xsl:if test="$operatesOnSetByProtocol and normalize-space($protocol) != ''">
            <xsl:if test="daobs:contains($protocol, 'wms')">
              <recordOperatedByType>view</recordOperatedByType>
            </xsl:if>
            <xsl:if test="daobs:contains($protocol, 'wfs') or
                          daobs:contains($protocol, 'wcs') or
                          daobs:contains($protocol, 'download')">
              <recordOperatedByType>download</recordOperatedByType>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </xsl:for-each>

      <!-- Service/dataset relation. Create document for the association.
      Note: not used for indicators anymore
       This could be used to retrieve :
      {!child of=documentType:metadata}+documentType:metadata +id:9940c446-6fd4-4ab3-a4de-7d0ee028a8d1
      {!child of=documentType:metadata}+documentType:metadata +resourceType:service +serviceType:view
      {!child of=documentType:metadata}+documentType:metadata +resourceType:service +serviceType:download
       -->
      <xsl:for-each
        select="gmd:identificationInfo/srv:SV_ServiceIdentification/srv:operatesOn">
        <xsl:variable name="associationType" select="'operatesOn'"/>
        <xsl:variable name="serviceType"
                      select="../srv:serviceType/gco:LocalName"/>
        <!--<xsl:variable name="relatedTo" select="@uuidref"/>-->
        <xsl:variable name="getRecordByIdId">
          <xsl:if test="@xlink:href != ''">
            <xsl:analyze-string select="@xlink:href"
                                regex=".*[i|I][d|D]=([\w\-\.\{{\}}]*).*">
              <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
              </xsl:matching-substring>
            </xsl:analyze-string>
          </xsl:if>
        </xsl:variable>

        <xsl:variable name="datasetId">
          <xsl:choose>
            <xsl:when test="$getRecordByIdId != ''">
              <xsl:value-of select="$getRecordByIdId"/>
            </xsl:when>
            <xsl:when test="@uuidref != ''">
              <xsl:value-of select="@uuidref"/>
            </xsl:when>
          </xsl:choose>
        </xsl:variable>

        <xsl:if test="$datasetId != ''">
          <recordOperateOn>
            <xsl:value-of select="$datasetId"/>
          </recordOperateOn>
        </xsl:if>
      </xsl:for-each>

      <!-- Index more fields in this element -->
      <xsl:apply-templates mode="index-extra-fields" select="."/>
    </doc>

    <!-- Index more documents for this element -->
    <xsl:apply-templates mode="index-extra-documents" select="."/>
  </xsl:template>

  <xsl:template mode="index-contact" match="*[gmd:CI_ResponsibleParty]">
    <xsl:param name="fieldSuffix" select="''" as="xs:string"/>

    <!-- Select the first child which should be a CI_ResponsibleParty.
    Some records contains more than one CI_ResponsibleParty which is
    not valid and they will be ignored.
     Same for organisationName eg. de:b86a8604-bf78-480f-a5a8-8edff5586679 -->
    <xsl:variable name="organisationName"
                  select="*[1]/gmd:organisationName[1]/(gco:CharacterString|gmx:Anchor)"
                  as="xs:string*"/>

    <xsl:variable name="role"
                  select="replace(*[1]/gmd:role/*/@codeListValue, ' ', '')"
                  as="xs:string?"/>
    <xsl:if test="normalize-space($organisationName) != ''">
      <xsl:element name="Org{$fieldSuffix}">
        <xsl:value-of select="$organisationName"/>
      </xsl:element>
      <xsl:element name="{$role}Org{$fieldSuffix}">
        <xsl:value-of select="$organisationName"/>
      </xsl:element>
    </xsl:if>
    <xsl:element name="contact{$fieldSuffix}">{
      org:"<xsl:value-of
        select="replace($organisationName, '&quot;', '\\&quot;')"/>",
      role:"<xsl:value-of select="$role"/>"
      }
    </xsl:element>
  </xsl:template>
</xsl:stylesheet>
