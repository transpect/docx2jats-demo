<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:tr="http://transpect.io"
  exclude-result-prefixes="xs"
  version="2.0">
  <xsl:import href="http://transpect.io/cascade/xsl/paths.xsl"/>
  <xsl:param name="filenames" as="xs:string?"/>
  <!-- that param is for filenames like images -->
  <xsl:variable name="regex" select="'^((\p{L}+)_(\d{4})_(\d{3})).*$'" as="xs:string"/>
  
  <xsl:function name="tr:parse-file-name" as="attribute(*)*">
    <xsl:param name="filename" as="xs:string?"/>
    <xsl:variable name="basename" select="tr:basename($filename)" as="xs:string"/>
    <xsl:variable name="ext" select="tr:ext($filename)" as="xs:string"/>
    <xsl:attribute name="ext" select="$ext"/>
    <xsl:attribute name="base" select="$basename"/>
    <xsl:analyze-string select="$basename" regex="{$regex}">
      <xsl:matching-substring>
        <xsl:attribute name="publisher" select="'ulsp'"/>
        <xsl:choose>
          <xsl:when test="not($ext = ('docx', 'xml', 'idml', 'png', 'jpg', 'tif', 'epub', 'mobi', 'report.xhtml'))"/>
          <xsl:otherwise>
            <xsl:attribute name="journal" select="regex-group(2)"/>
            <xsl:attribute name="ms" select="regex-group(1)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:attribute name="ms" select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:function>
    
  <!--<xsl:template match="@ext[. = 'xml']" mode="tr:ext-to-target-subdir">
    <xsl:sequence select="'jats'"/>
  </xsl:template>-->
</xsl:stylesheet>