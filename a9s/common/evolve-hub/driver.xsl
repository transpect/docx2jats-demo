<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dbk="http://docbook.org/ns/docbook"
  xmlns:tr="http://transpect.io"
  xmlns:xlink="http://www.w3.org/1999/xlink"
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:hub="http://transpect.io/hub"
  xmlns="http://docbook.org/ns/docbook"
  xpath-default-namespace="http://docbook.org/ns/docbook"
  exclude-result-prefixes="xs tr xlink hub dbk"
  version="2.0">
  
  <xsl:import href="http://transpect.io/evolve-hub/xsl/evolve-hub.xsl"/>
  
  <xsl:variable name="hub:hierarchy-role-regexes-x" as="xs:string+"
    select="('^Headline-1$', '^Headline-2(_-_rule)?$', '^Headline-3$')" />
  
  
  <xsl:variable name="hub:figure-title-role-regex-x"  as="xs:string"
    select="'^figuretitle$'" />
  
    <xsl:variable name="hub:figure-caption-start-regex"  as="xs:string" select="'[Ff]ig\w*\.?'"/>
  
  <xsl:variable name="hub:table-title-role-regex-x" as="xs:string" 
    select="'^tabletitle$'"/>

  <xsl:variable name="hub:article-title-regex-x" as="xs:string" select="'^Headline-1$'"/>
  
  <xsl:function name="hub:condition-that-stops-indenting-apart-from-role-regex" as="xs:boolean">
    <xsl:param name="input" as="element(*)"/>
    <xsl:sequence select="matches($input/local-name(), 'table')"/>
   </xsl:function>  

  <xsl:template match="para/phrase[mediaobject]" mode="hub:split-at-tab">
    <xsl:copy-of select="mediaobject"/>
  </xsl:template>

  <!-- delete all non-word charcters from names (to avoid , in names, because of wrong characterstyle applied)-->
  <xsl:template match="phrase[matches(@role, 'name|degrees')]" mode="hub:split-at-tab">
    <xsl:copy>
      <xsl:copy-of select="@*"/>
      <xsl:value-of select="replace(text(), '^\W*(\w+\s?\w?)\W*','$1')"/>
      </xsl:copy>
  </xsl:template>

  <xsl:template match="/hub[every $e in * satisfies ($e/self::info or $e/self::section)]
                           [count(section) = 1]
                             /section[matches(@role, $hub:article-title-regex-x, 'x')]"
                mode="hub:postprocess-hierarchy">
    <xsl:apply-templates select="section[not(normalize-space(title) = 'Abstract')]" mode="#current"/>
  </xsl:template>
  
  <xsl:template mode="hub:postprocess-hierarchy" match="/hub/section/section[normalize-space(title) = 'Abstract']">
    <abstract>
      <xsl:apply-templates mode="#current"/>
    </abstract>
  </xsl:template>
  
  <xsl:template match="/hub/info" mode="hub:postprocess-hierarchy">
    <xsl:copy>
      <xsl:apply-templates select="@*, node()" mode="#current"/>
      
      <xsl:apply-templates mode="#current" 
        select="../section[matches(@role, $hub:article-title-regex-x, 'x')]
                    /(* except section[not(normalize-space(title) = 'Abstract')])"/>
    </xsl:copy>
  </xsl:template>
  
  <xsl:template match="/hub/section/para[matches(@role, 'authors')]" mode="hub:postprocess-hierarchy">
    <authorgroup>
      <xsl:variable name="unnumbered-affs" as="element(para)*" 
        select="../para[@role = 'affiliation'][not(matches(., '^\d+\s'))]"/>
      <xsl:for-each-group select="*" group-starting-with="phrase[matches(@role, 'surname')]">
        <author>
          <xsl:attribute name="srcpath">
            <xsl:copy-of select="@srcpath"/>
          </xsl:attribute>
          <personname>
            <surname>
              <xsl:apply-templates select="current-group()[matches(@role, 'surname')]/@srcpath, current-group()[matches(@role, 'surname')]/node()" mode="#current"/>
            </surname>
            <firstname>
              <xsl:apply-templates select="current-group()[matches(@role, 'given-names')]/@srcpath, current-group()[matches(@role, 'given-names')]/node()" mode="#current"/>
            </firstname>
            <!--<xsl:if test="current-group()[matches(@role, 'degrees')]">
              <honorific>
                <xsl:apply-templates select="current-group()[matches(@role, 'degrees')]/@srcpath, current-group()[matches(@role, 'degrees')]/node() " mode="#current"/>
              </honorific>
            </xsl:if>-->
          </personname>
          <xsl:choose>
            <xsl:when test="current-group()[matches(@role, 'aff')]">
              <xsl:variable name="affid" select="current-group()[matches(@role, 'aff')]" />
              <affiliation>
                <shortaffil>
                  <xsl:apply-templates select="../../para[matches(@role, 'affiliation')][starts-with(. , $affid)]/@srcpath, ../../para[matches(@role, 'affiliation')][starts-with(. , $affid)]/node()" mode="#current"/>
                </shortaffil>
              </affiliation>
            </xsl:when>
            <xsl:when test="$unnumbered-affs">
              <xsl:for-each select="$unnumbered-affs">
                <affiliation>
                  <shortaffil>
                    <xsl:apply-templates select="@* | node()" mode="#current"/>
                  </shortaffil>
                </affiliation>
              </xsl:for-each>
            </xsl:when>
          </xsl:choose>
          
          <xsl:if test="matches(current(), ../../section/para[matches(@role, 'author')]/phrase[matches(@role, 'surname')])">
            <address>
              <xsl:apply-templates select="../../section/para[matches(@role, 'address')]/@srcpath" mode="#current"/>
              <phrase>
                <xsl:apply-templates select="../../section/para[matches(@role, 'address')]/@*" mode="#current" />
                <xsl:value-of select="string-join(../../section/para[matches(@role, 'address')], ',')"/> </phrase>
                <email>
                  <xsl:apply-templates select="../../section/para[matches(@role, 'mail')]/@srcpath" mode="#current"/>
                  <xsl:value-of select="normalize-space(replace(../../section/para[matches(@role, 'mail')], '^.*:\s*' , ''))"/></email>
            </address>
          </xsl:if>
        </author>
      </xsl:for-each-group>
    </authorgroup>
  </xsl:template>

  <xsl:template match="para[matches(@role, 'affiliation')]" mode="hub:clean-hub"/>
  
  <xsl:template match="para[matches(@role, 'author')]| para[matches(@role, 'mail')] | para[matches(@role, 'address')]" mode="hub:clean-hub"/>

  <!--  Bibliography -->
  
  <xsl:template match="/hub/section/section/title[matches(., 'Bibliography|References')]" mode="hub:postprocess-hierarchy">
    <xsl:copy-of select="."/>
    <bibliography>
      <xsl:apply-templates select="./following-sibling::para[matches(@role, 'references')]" mode="#current" >
        <xsl:with-param name="processed" select="true()" as="xs:boolean?"/>
      </xsl:apply-templates>
    </bibliography>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, 'references')]" mode="hub:postprocess-hierarchy">
    <xsl:param name="processed" as="xs:boolean?"/>
  <xsl:if test="$processed">
    <bibliomixed>
      <xsl:apply-templates select="@* | node() except (dbk:tabs | dbk:phrase[matches(@role, 'hub:identifier')])" mode="#current"/>
    </bibliomixed>
  </xsl:if>
  </xsl:template>
  
  
<!--  disable bold or fett stylings in references -->
  <xsl:template match="dbk:phrase[matches(@role, 'fett|bold')]
                                 [ancestor::para[matches(@role, 'references')]]" mode="hub:postprocess-hierarchy">
    <xsl:copy-of select="text()"/>
  </xsl:template>
  
  <xsl:template match="para[matches(@role, 'references')]" mode="hub:clean-hub"/>
  
  <xsl:template match="para[not(matches(@role, 'table'))]
                           [not(text())]
                           [not(child::*)]" mode="hub:clean-hub"/>
  
  <!-- Normalizing Image-Path for Word -->
  <xsl:template match="imagedata/@fileref" mode="hub:postprocess-hierarchy">
    <xsl:variable name="src-dir-uri" select="/hub/info/keywordset[@role eq 'hub']/keyword[@role eq 'source-dir-uri']" as="xs:string"/>
    <xsl:variable name="container-prefix-regex" select="'^container:(.+)$'" as="xs:string"/>
    <xsl:variable name="patched-fileref" select="
      if(matches(., $container-prefix-regex )) 
      then concat( $src-dir-uri, replace(., $container-prefix-regex, '$1' )) 
      else ."/>
    <xsl:attribute name="fileref" select="$patched-fileref"/>
  </xsl:template>

</xsl:stylesheet>