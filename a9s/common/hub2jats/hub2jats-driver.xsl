<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:jats="http://jats.nlm.nih.gov" xmlns:dbk="http://docbook.org/ns/docbook" xmlns:css="http://www.w3.org/1996/css"
  xmlns:xlink="http://www.w3.org/1999/xlink" exclude-result-prefixes="css jats dbk xs " version="2.0">

  <xsl:import href="http://transpect.io/hub2bits/xsl/hub2jats-fallback.xsl"/>

  <xsl:template name="custom-meta-group"/>

  <xsl:template match="@css:* | td/p/@content-type" mode="clean-up"/>

  <xsl:variable name="dtd-version-att" as="attribute(dtd-version)">
    <xsl:attribute name="dtd-version" select="'1.0'"/>
  </xsl:variable>

  <xsl:template match="custom-meta-group | css:rules" mode="clean-up"/>

  <xsl:template match="ref-list/p" mode="clean-up"/>

  <xsl:template match="bold[bold]" mode="clean-up">
    <xsl:copy-of select="bold"/>
  </xsl:template>

  <xsl:template match="styled-content[bold]" mode="clean-up">
    <xsl:copy-of select="bold"/>
  </xsl:template>

  <xsl:template match="styled-content[@xml:lang]" mode="clean-up">
    <xsl:copy-of select="text()"/>
  </xsl:template>
  
    <!-- not permitted by schema: -->
  <xsl:template match="sub/@content-type | sub/@xml:lang | sup/@content-type " mode="clean-up"/>

  <xsl:template name="meta">
    <xsl:variable name="source-basename" select="dbk:keywordset[@role eq 'hub']/dbk:keyword[matches(@role, 'source-basename')]"/>
    <journal-meta>
      <journal-id journal-id-type="nlm-ta">
        <xsl:value-of select="replace($source-basename, '(^\w+)(_\d+_\d+)' , '$1')"/>
      </journal-id>
      <journal-title-group>
      <xsl:if test="matches(replace($source-basename, '(^\w+)(_\d+_\d+)' , '$1'), 'CSMI')">
        <journal-title>Clinical Sports Medicine International</journal-title>
      </xsl:if>
      </journal-title-group>
      <xsl:if test="matches(replace($source-basename, '(^\w+)(_\d+_\d+)' , '$1'), 'CSMI')">
        <issn pub-type="ppub">1617-9870</issn>
      </xsl:if>
    </journal-meta>
    <article-meta>
      <xsl:apply-templates select="dbk:abstract/dbk:section[dbk:title[matches(text(),'[kK]ey\s?[wW]ords')]]" mode="#current">
        <xsl:with-param name="process" select="true()" as="xs:boolean?"/>
      </xsl:apply-templates>
      <xsl:if test="dbk:colophon/dbk:para//dbk:phrase[matches(@role, 'ch_doi')]">
        <article-id book-id-type="doi">
          <xsl:value-of select="replace(string-join(dbk:colophon/dbk:para//dbk:phrase[matches(@role, 'ch_doi')], ''), '^.+doi\.org/', '')"/>
        </article-id>
        <article-id book-id-type="publisher">
          <xsl:value-of select="replace(string-join(dbk:colophon/dbk:para//dbk:phrase[matches(@role, 'ch_doi')], ''), '^(.+doi\.org/.+/)?(\d{5})-.+$', '$2')"/>
        </article-id>
      </xsl:if>
      <title-group>
        <xsl:apply-templates select="dbk:title" mode="#current">
          <xsl:with-param name="process" select="true()" as="xs:boolean?"/>
        </xsl:apply-templates>
        <xsl:apply-templates select="dbk:subtitle" mode="#current">
          <xsl:with-param name="process" select="true()" as="xs:boolean?"/>
        </xsl:apply-templates>
      </title-group>
      <xsl:if test="dbk:authorgroup">
        <contrib-group>
          <xsl:apply-templates select="dbk:authorgroup" mode="#current">
            <xsl:with-param name="process" select="true()" as="xs:boolean"></xsl:with-param>
          </xsl:apply-templates>
        </contrib-group>
      </xsl:if>
      <xsl:apply-templates select="dbk:authorgroup/dbk:author/dbk:address" mode="default"/>
      <xsl:apply-templates select="dbk:para[matches(@role, 'quotation')]"/>
      <xsl:if test="dbk:seriesvolnums">
        <article-volume-number>
          <xsl:value-of select="dbk:seriesvolnums"/>
        </article-volume-number>
      </xsl:if>
      <pub-date pub-type="ppub">
        <year>
          <xsl:value-of select="replace($source-basename, '(^\w+)_(\d+)_(\d+)' , '$2')"/>
        </year>
      </pub-date>
      <volume>
        <xsl:value-of select="replace($source-basename, '(^\w+)_(\d+)_(\d)0(\d)' , '$3')"/>
      </volume>
      <issue>
        <xsl:value-of select="replace($source-basename, '(^\w+)_(\d+)_(\d)0(\d)' , '$4')"/>
      </issue>
      <fpage>
        <xsl:value-of select="replace(dbk:abstract/dbk:para[matches(@role, 'quotation')], '(^.*):\s*(\d+)-(\d+)[\s\S]?', '$2')"/></fpage>
      <lpage><xsl:value-of select="replace(dbk:abstract/dbk:para[matches(@role, 'quotation')], '(^.*):\s*(\d+)-(\d+)[\s\S]?', '$3')"/></lpage>
      <xsl:if test="dbk:edition">
        <edition>
          <xsl:value-of select="dbk:edition"/>
        </edition>
      </xsl:if>
      <xsl:call-template name="custom-meta-group"/>
      <xsl:apply-templates select="dbk:info[dbk:keywordset[@role eq 'hub']]/dbk:keywordset[@role eq 'hub']" mode="#current"/>
      <xsl:apply-templates select="dbk:abstract" mode="#current">
        <xsl:with-param name="process" select="true()" as="xs:boolean"/>
      </xsl:apply-templates>
    </article-meta>
  </xsl:template>

  <xsl:template match="dbk:org | dbk:orgname" mode="default" priority="2">
    <xsl:param name="process" as="xs:boolean?"/>
    <xsl:if test="$process">
      <xsl:apply-templates mode="#current"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dbk:authorgroup" mode="default" priority="2">
    <xsl:param name="process" as="xs:boolean?"/>
    <xsl:if test="$process">
      <xsl:apply-templates select="
          @srcpath,
          node()" mode="#current"/>
    </xsl:if>
    <xsl:for-each-group select="dbk:author/dbk:affiliation[dbk:shortaffil]" group-by="replace(dbk:shortaffil, '^(\d+).+', '$1')">
      <xsl:variable name="tmp" as="element(*)">
        <xsl:apply-templates select="." mode="#current"/>
      </xsl:variable>
      <xsl:sequence select="$tmp"/>
    </xsl:for-each-group>
  </xsl:template>

  <xsl:template match="dbk:affiliation" mode="default" priority="2">
    <aff>
      <xsl:apply-templates select="dbk:shortaffil/node()" mode="#current"/>
    </aff>
  </xsl:template>

  <xsl:template match="dbk:shortaffil//text()[. is (ancestor::dbk:shortaffil//text())[1]]" mode="default">
    <xsl:variable name="prelim" as="item()*">
      <xsl:analyze-string select="." regex="^(\d+)\s+">
        <xsl:matching-substring>
          <xsl:attribute name="id" select="concat('aff', replace(regex-group(1), '\s', ''))"/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:value-of select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>
    <xsl:if test="not($prelim/self::attribute(id))">
      <xsl:attribute name="id" select="'aff1'"/>
    </xsl:if>
    <xsl:sequence select="$prelim"/>
  </xsl:template>

  <xsl:template match="dbk:abstract" mode="default">
    <xsl:param name="process" as="xs:boolean?"/>
    <xsl:if test="$process">
      <abstract>
        <xsl:apply-templates select="@srcpath, node()" mode="#current"/>
      </abstract>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dbk:abstract/dbk:title" mode="default">
    <title>
      <xsl:apply-templates select="@srcpath, node()" mode="#current"/>
    </title>
  </xsl:template>

  <xsl:template match="dbk:author" mode="default">
    <contrib contrib-type="{local-name()}">
      <xsl:if test="dbk:address">
        <xsl:attribute name="corresp" select="'yes'"/>
      </xsl:if>
      <xsl:apply-templates select="@srcpath" mode="#current"/>
      <xsl:apply-templates select="dbk:personname" mode="#current"/>
      <xsl:if test="dbk:affiliation">
        <xsl:element name="xref">
          <xsl:attribute name="ref-type" select="'aff'"/>
          <xsl:attribute name="rid" separator=" ">
            <xsl:apply-templates select="dbk:affiliation/dbk:shortaffil" mode="affrid"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:if>
      <xsl:if test="dbk:address">
        <xsl:element name="xref">
          <xsl:attribute name="ref-type" select="'corresp'"/>
          <xsl:attribute name="rid" separator=" ">
            <xsl:apply-templates select="dbk:address" mode="affrid"/>
          </xsl:attribute>
        </xsl:element>
      </xsl:if>
    </contrib>
  </xsl:template>

  <xsl:template match="dbk:shortaffil" mode="affrid">
    <xsl:variable name="num" as="xs:integer"
      select="
        (for $i in replace(., '^(\d+).+', '$1')[. castable as xs:integer]
        return
          xs:integer($i),
        1)[1]"/>
    <xsl:sequence select="concat('aff', $num)"/>
  </xsl:template>

  <xsl:template match="dbk:address" mode="affrid">
    <xsl:variable name="num" as="xs:integer"
      select="
        (replace(., '^(\d+).+', '$1')[. castable as xs:integer],
        1)[1]"/>
    <xsl:sequence select="concat('cor', $num)"/>
  </xsl:template>

  <xsl:template match="dbk:personname" mode="default">
    <name>
      <xsl:apply-templates select="@srcpath,node()" mode="#current"/>
    </name>
<!--    <xsl:apply-templates select="dbk:honorific" mode="#current"/>-->
  </xsl:template>

  <xsl:template match="dbk:surname" mode="default">
    <surname>
      <xsl:apply-templates select="
          @srcpath,
          node()" mode="#current"/>
    </surname>
  </xsl:template>

  <xsl:template match="dbk:firstname" mode="default">
    <given-names>
      <xsl:apply-templates select="
          @srcpath,
          node()" mode="#current"/>
    </given-names>
  </xsl:template>

<!--  <xsl:template match="dbk:honorific" mode="default">
    <degrees>
      <xsl:apply-templates select="
          @srcpath,
          node()" mode="#current"/>
    </degrees>
  </xsl:template>-->

  <xsl:template match="dbk:address" mode="default">
    <author-notes>
      <corresp>
        <xsl:attribute name="id">
          <xsl:apply-templates select="." mode="affrid"/>
        </xsl:attribute>
        <xsl:apply-templates select="
            @srcpath,
            node()" mode="#current"/>
      </corresp>
    </author-notes>
  </xsl:template>

  <xsl:template match="dbk:address/dbk:phrase" mode="default">
    <xsl:for-each select="tokenize(., ',')">
      <addr-line>
        <xsl:value-of select="normalize-space(.)"/>
      </addr-line>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="dbk:email" mode="default">
    <email>
      <xsl:call-template name="css:content"/>
    </email>
  </xsl:template>

  <!-- BLOCK -->


  <xsl:template match="dbk:info/dbk:title" mode="default">
    <xsl:param name="process" as="xs:boolean?"/>
    <xsl:if test="$process">
      <article-title>
        <xsl:apply-templates select="@srcpath, node()" mode="#current"/>
      </article-title>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dbk:section/dbk:title" mode="default">
    <title>
      <xsl:apply-templates select="@srcpath, node()" mode="#current"/>
    </title>
  </xsl:template>

  <xsl:template match="dbk:info/dbk:abstract/dbk:section[dbk:title[matches(string-join(text(),''), '[kK]ey\s?[wW]ords')]]" mode="default">
    <xsl:param name="process" as="xs:boolean?"/>
    <xsl:choose>
      <xsl:when test="$process">
        <article-categories>
          <subj-group subj-group-type="heading">
            <subject>Research Article</subject>
            <subj-group>
              <xsl:for-each select="tokenize(dbk:para/dbk:phrase/text()| dbk:para/text(), ',')">  
                <subject>
                  <xsl:value-of select="normalize-space(.)"/>
                </subject>
              </xsl:for-each>
            </subj-group>
          </subj-group>
        </article-categories>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- FIGURES -->

  <xsl:template match="dbk:para[@role eq 'figure']" mode="default" priority="2">
    <fig>
      <xsl:apply-templates select="
          @srcpath,
          node()" mode="#current"/>
    </fig>
  </xsl:template>

  <xsl:template
    match="dbk:mediaobject[parent::*[self::dbk:para or self::dbk:section or self::dbk:chapter or self::dbk:appendix]]"
    mode="default">
    <xsl:call-template name="css:other-atts"/>
    <xsl:apply-templates select="(.//dbk:anchor[not(matches(@xml:id, '^(cell)?page_'))])[1]/@xml:id" mode="#current"/>
    <xsl:apply-templates mode="#current" select="../following-sibling::dbk:para[matches(@role, 'figuretitle')]/node()"/>
    <xsl:if test="dbk:alt">
      <alt-text>
        <xsl:apply-templates select="dbk:alt/node()" mode="#current"/>
      </alt-text>
    </xsl:if>
    <xsl:apply-templates select="* except (dbk:title | dbk:info[dbk:legalnotice[@role eq 'copyright']] | dbk:note)"
      mode="#current"/>
    <xsl:apply-templates select="dbk:info[dbk:legalnotice[@role eq 'copyright']]" mode="#current"/>
  </xsl:template>


  <xsl:template match="fig[target]" mode="clean-up">
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="not(@id)">
        <xsl:attribute name="id" select="target/@id"/>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current">
        <xsl:with-param name="move-floating-target-in-fig-to-caption"
          select="
            if (@id) then
              true()
            else
              false()" as="xs:boolean"
          tunnel="yes"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="fig/target" mode="clean-up"/>

  <xsl:template match="dbk:mediaobject/dbk:alt" mode="default"/>

  <xsl:template match="fig/label" mode="clean-up">
    <xsl:param name="move-floating-target-in-fig-to-caption" as="xs:boolean?" tunnel="yes"/>
    <xsl:copy copy-namespaces="no">
      <xsl:apply-templates select="@*" mode="#current"/>
      <xsl:if test="$move-floating-target-in-fig-to-caption">
        <xsl:copy-of select="../target"/>
      </xsl:if>
      <xsl:apply-templates select="node()" mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template
    match="dbk:para[matches(@role, 'figuretitle')]//text()[. is (ancestor::dbk:para[matches(@role, 'figuretitle')]//text())[1]]"
    mode="default">
    <xsl:analyze-string select="." regex="^(\w*\.\s*\d+:)\s+">
      <xsl:matching-substring>
        <xsl:element name="label">
          <xsl:value-of select="replace(regex-group(1), '\s', '')"/>
        </xsl:element>
      </xsl:matching-substring>
      <xsl:non-matching-substring>
        <xsl:element name="caption">
          <xsl:element name="title">
            <xsl:value-of select="."/>
          </xsl:element>
        </xsl:element>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:template>


  <xsl:template match="dbk:para[matches(@role, 'figuretitle')]" mode="default"/>

<!-- TABLES -->

  <xsl:template match="dbk:table/@frame" mode="default" priority="2">
    <xsl:variable name="type" as="xs:string?">
      <xsl:choose>
        <xsl:when test=". = 'all'">
          <xsl:value-of select="'box'"/>
        </xsl:when>
        <xsl:when test=". = 'top'">
          <xsl:value-of select="'above'"/>
        </xsl:when>
        <xsl:when test=". = 'bottom'">
          <xsl:value-of select="'below'"/>
        </xsl:when>
        <xsl:when test=". = 'topbot'">
          <xsl:value-of select="'hsides'"/>
        </xsl:when>
        <xsl:when test=". = 'none'">
          <xsl:value-of select="'void'"/>
        </xsl:when>
        <xsl:when test=". = 'sides'">
          <xsl:value-of select="'vsides'"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="$type">
      <xsl:attribute name="frame" select="$type"/>
    </xsl:if>
  </xsl:template>

  <xsl:template match="dbk:thead" mode="default">
    <thead>
      <xsl:call-template name="css:content"/>
    </thead>
  </xsl:template>

  <xsl:template match="dbk:entry" mode="default">
    <xsl:element name="{if (ancestor::dbk:thead) then 'th' else 'td'}">
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="dbk:entry/dbk:para" mode="default">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <xsl:template match="dbk:entry/dbk:para[preceding-sibling::*[1]/self::dbk:para]" priority="2" mode="default">
    <break/>
    <xsl:next-match/>
  </xsl:template>

  <xsl:template match="dbk:informaltable | dbk:table" mode="default">
    <xsl:if test="
        dbk:textobject[every $elt in node()
          satisfies $elt/self::dbk:sidebar]">
      <xsl:apply-templates select="dbk:textobject/node()" mode="#current"/>
    </xsl:if>
    <table-wrap>
      <xsl:apply-templates select="
          @* except (@role | @frame | @css:* | @srcpath),
          dbk:title"
        mode="#current"/>
      <xsl:choose>
        <xsl:when test="exists(dbk:mediaobject) and not(dbk:tgroup)">
          <xsl:apply-templates select="* except (dbk:title | dbk:info[dbk:legalnotice[@role eq 'copyright']])" mode="#current"/>
          <xsl:apply-templates select="dbk:info[dbk:legalnotice[@role eq 'copyright']]" mode="#current"/>
        </xsl:when>
        <xsl:when test="exists(dbk:tgroup/*/dbk:row)">
          <!-- if there is an alternative image (additional to the real table) -->
          <xsl:apply-templates select="dbk:alt" mode="#current"/>
          <table>
            <xsl:apply-templates select="@frame | @role | @css:* | @srcpath" mode="#current"/>
            <xsl:apply-templates select="* except (dbk:alt | dbk:title | dbk:info[dbk:legalnotice[@role eq 'copyright']])"
              mode="#current"/>
            <xsl:apply-templates select="dbk:info[dbk:legalnotice[@role eq 'copyright']]" mode="#current"/>
          </table>
        </xsl:when>
        <xsl:otherwise>
          <table>
            <xsl:apply-templates select="@role | @css:*" mode="#current"/>
            <HTMLTABLE_TODO/>
            <xsl:apply-templates mode="#current"/>
          </table>
        </xsl:otherwise>
      </xsl:choose>
      <!--<xsl:for-each select="self::dbk:informaltable">
        <xsl:call-template name="css:other-atts"/>
        </xsl:for-each>-->
      <!-- extra content-type attribute at the contained table (also process css here, only id above?): -->
      <xsl:if
        test="
          dbk:textobject[not(every $elt in node()
            satisfies $elt/self::dbk:sidebar)]
          | ./following-sibling::dbk:para[matches(@role, 'tablesub')]">
        <table-wrap-foot>
          <xsl:apply-templates select="dbk:textobject/dbk:para" mode="#current"/>
          <xsl:apply-templates select="./following-sibling::dbk:para[matches(@role, 'tablesub')]" mode="#current">
            <xsl:with-param name="process" select="true()" as="xs:boolean?"/>
          </xsl:apply-templates>
        </table-wrap-foot>
      </xsl:if>
    </table-wrap>
  </xsl:template>

  <xsl:template match="dbk:para[matches(@role, 'tablesub')]" mode="default" priority="2">
    <xsl:param name="process" as="xs:boolean?"/>
    <xsl:if test="$process">
      <fn id="{concat('fn',position())}">
        <p>
          <xsl:apply-templates select="
              @*,
              node()" mode="#current"/>
        </p>
      </fn>
    </xsl:if>
  </xsl:template>

<!-- REFERENCES -->

  <xsl:template match="dbk:phrase[matches(@role, 'ref')]" mode="default">
    <xsl:for-each select="tokenize(replace(text(), '\[(.*)\]', '$1'), ',')">
      <xref ref-type="bibr" rid="{concat('R',normalize-space(current()))}">
        <xsl:value-of select="normalize-space(current())"/>
      </xref>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="dbk:bibliomisc | dbk:bibliomixed" mode="default">
    <ref>
      <xsl:attribute name="id" select="concat('R', position())"/>
      <xsl:attribute name="srcpath" select="@srcpath"/>
      <mixed-citation>
        <xsl:if test="../@xml:id">
          <xsl:attribute name="id" select="../@xml:id"/>
        </xsl:if>
        <xsl:apply-templates select="@srcpath, node()" mode="#current"/>
      </mixed-citation>
    </ref>
  </xsl:template>

  <xsl:template match="dbk:bibliomisc" mode="default">
    <xsl:if test="../@xml:id">
      <xsl:attribute name="id" select="../@xml:id"/>
    </xsl:if>
    <xsl:call-template name="css:content"/>
  </xsl:template>

  <xsl:template match="dbk:link[@xlink:href]" mode="default">
    <ext-link ext-link-type="uri">
      <xsl:apply-templates select="@*, node()" mode="#current"/>
    </ext-link>
  </xsl:template>

  <xsl:template match="dbk:phrase[matches(@role, 'fig')]" mode="default">
    <xsl:for-each select="tokenize(replace(text(), '[Ff]ig\w*\.?(\d*)', '$1'), ',|and')">
      <xref ref-type="fig" rid="{concat('Fig',normalize-space(current()))}">
        <xsl:value-of select="concat('Fig. ', normalize-space(current()))"/>
      </xref>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="dbk:phrase[matches(@role, 'tab')]" mode="default">
    <xsl:message select="'text', text()"/>
    <xsl:message select="'replace', replace(text(), '[Tt]able\s*(\d*)', '$1')"/>
    <xsl:for-each select="tokenize(replace(text(), '^[Tt]able\s*(\d*)', '$1'), ',')">
      <xref ref-type="table" rid="{concat('Tab',normalize-space(current()))}">
        <xsl:value-of select="concat('Table ', normalize-space(current()))"/>
      </xref>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="dbk:phrase[matches(@role, 'fn')]
                                 [ancestor::dbk:table]" mode="default">
    <xsl:for-each select="tokenize(text(), ',')">
      <xref ref-type="table-fn" rid="{concat('fn',position())}">
        <xsl:value-of select="current()"/>
      </xref>
    </xsl:for-each>
  </xsl:template>



  <xsl:template match="dbk:imagedata" mode="default">
    <xsl:element name="graphic">
      <xsl:apply-templates select="(ancestor::dbk:mediaobject | ancestor::dbk:inlinemediaobject)[1]/@xml:id" mode="#current"/>
      <xsl:call-template name="css:content"/>
    </xsl:element>
  </xsl:template>

  <!-- Override in adaptions -->
  <xsl:template match="dbk:imagedata/@fileref" mode="default">
    <xsl:attribute name="xlink:href" select="."/>
  </xsl:template>
  <!--
<xsl:template match="@srcpath" mode="test" priority="10">
  <xsl:message select="'öööööööööööö ' , ancestor::*[1]/local-name()"/>
</xsl:template>-->

</xsl:stylesheet>
