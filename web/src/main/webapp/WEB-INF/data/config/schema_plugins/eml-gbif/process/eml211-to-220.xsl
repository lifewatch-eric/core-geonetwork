<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:eml="https://eml.ecoinformatics.org/eml-2.2.0"
                xmlns:eml_211="eml://ecoinformatics.org/eml-2.1.1"
                xmlns:stmml_211="http://www.xml-cml.org/schema/stmml-1.1"
                xmlns:dc_oai="http://www.openarchives.org/OAI/2.0/"
                version="2.0" exclude-result-prefixes="eml_211 stmml_211 dc_oai">

  <xsl:template match="eml_211:eml">
    <xsl:element name="eml:eml" namespace="https://eml.ecoinformatics.org/eml-2.2.0">
      <xsl:namespace name="eml" select="'https://eml.ecoinformatics.org/eml-2.2.0'"/>
      <xsl:namespace name="stmml" select="'http://www.xml-cml.org/schema/stmml-1.2'"/>

      <xsl:apply-templates select="@*[name() != 'xsi:schemaLocation']|node()" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="dc_oai:*">
    <xsl:element name="{name()}">
        <xsl:apply-templates select="@*|node()" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*|node()">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>
</xsl:stylesheet>


