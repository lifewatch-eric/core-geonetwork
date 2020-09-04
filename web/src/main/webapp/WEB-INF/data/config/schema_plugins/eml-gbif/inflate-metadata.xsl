<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet   xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0"
                  xmlns:eml="https://eml.ecoinformatics.org/eml-2.2.0"
                  exclude-result-prefixes="#all">

  <xsl:output method="xml" indent="yes"/>

  <xsl:template match="/root">
    <xsl:apply-templates select="*[1]"/>
  </xsl:template>

  <xsl:template match="abstract[count(*) = 0]">
    <xsl:copy>
      <xsl:copy-of select="@*" />

      <para></para>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="ulink">[<xsl:value-of select="citetitle" />] (<xsl:value-of select="@url" />)</xsl:template>

  <!-- Do a copy of every nodes and attributes -->
  <xsl:template match="@*|node()">
    <xsl:copy>
      <xsl:apply-templates select="@*|node()"/>
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>
