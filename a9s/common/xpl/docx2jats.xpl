<p:declare-step 
  xmlns:p="http://www.w3.org/ns/xproc" 
  xmlns:c="http://www.w3.org/ns/xproc-step"
  xmlns:docx2hub="http://transpect.io/docx2hub" 
  xmlns:tr="http://transpect.io" 
  xmlns:css="http://www.w3.org/1996/css"
  xmlns:letex="http://www.le-tex.de/namespace" 
  xmlns:jats="http://jats.nlm.nih.gov"
  xmlns:cx="http://xmlcalabash.com/ns/extensions"
  xmlns:pxp="http://exproc.org/proposed/steps"
  xmlns:hub2htm="http://transpect.io/hub2htm"
  xmlns:epub="http://transpect.io/epubtools" 
  xmlns:dc="http://purl.org/dc/elements/1.1/"
  xmlns:hub="http://transpect.io/hub" name="docx2epub" version="1.0">

  <p:input port="conf">
    <p:document href="http://this.transpect.io/conf/transpect-conf.xml"/>
  </p:input>

  <p:output port="result" primary="true">
    <p:documentation>JATS</p:documentation>
    <p:pipe port="result" step="jats-remove-srcpath"/>
  </p:output>
  <p:serialization port="result" indent="true" omit-xml-declaration="false"
    doctype-public="-//NLM//DTD JATS (Z39.96) Journal Archiving and Interchange DTD v1.0 20120330//EN" 
    doctype-system="JATS-archivearticle1.dtd"/>

  <p:output port="htmlreport" sequence="true">
    <p:pipe port="result" step="htmlreport-remove-ns"/>
  </p:output>
  <p:serialization port="htmlreport" omit-xml-declaration="false" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"/>

  <p:option name="file" required="true"/>
  <p:option name="clades" select="''"/>

  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/docx2hub/xpl/docx2hub.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/paths.xpl"/>
  <p:import href="http://transpect.io/evolve-hub/xpl/evolve-hub.xpl"/>
  <p:import href="http://transpect.io/hub2bits/xpl/hub2bits.xpl"/>
  <p:import href="http://transpect.io/jats2html/xpl/jats2html.xpl"/>
  <p:import href="http://transpect.io/xproc-util/remove-ns-decl-and-xml-base/xpl/remove-ns-decl-and-xml-base.xpl"/> 
  <p:import href="http://transpect.io/htmlreports/xpl/check-styles.xpl"/>
  <p:import href="http://transpect.io/htmlreports/xpl/validate-with-schematron.xpl"/>
  <p:import href="http://transpect.io/htmlreports/xpl/validate-with-rng.xpl"/>
  <p:import href="http://transpect.io/map-style-names/xpl/map-style-names.xpl"/>
  <p:import href="http://transpect.io/cascade/xpl/load-cascaded.xpl"/>
  <p:import href="http://transpect.io/epubcheck-idpf/xpl/epubcheck.xpl"/>
  <p:import href="http://transpect.io/epubtools/xpl/epub-convert.xpl"/>
  <p:import href="http://transpect.io/nlm-stylechecker/xpl/nlm-stylechecker.xpl"/>  

  <p:load>
    <p:with-option name="href" select="/tr:conf/@paths-xsl-uri">
      <p:pipe port="conf" step="docx2epub"/>
    </p:with-option>
  </p:load>

  <tr:paths name="paths" pipeline="docx2jats.xpl">
    <p:with-option name="clades" select="$clades"/>
    <p:with-option name="file" select="$file"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:input port="conf">
      <p:pipe port="conf" step="docx2epub"/>
    </p:input>
    <p:input port="params">
      <p:empty/>
    </p:input>
  </tr:paths>

  <p:sink/>

  <docx2hub:convert name="docx2hub" srcpaths="yes" unwrap-tooltip-links="yes">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="docx" select="$file"/>
  </docx2hub:convert>
  
  <css:map-styles name="map-styles">
    <p:input port="source">
      <p:pipe port="result" step="docx2hub"/>
    </p:input>
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="map-name" select="concat('styles/map-', /c:param-set/c:param[@name eq 'ext']/@value, '.xhtml')">
      <p:pipe port="result" step="paths"/>
    </p:with-option>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </css:map-styles>
  
  <tr:check-styles name="check-styles">
    <p:input port="html-in">
      <p:empty/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="cssa" select="'styles/cssa.xml'"/>
    <p:with-option name="differentiate-by-style" select="'true'"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:check-styles>

  <tr:validate-with-schematron name="sch_flat">
    <p:input port="html-in">
      <p:empty/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-param name="family" select="'flat'"/>
    <p:with-param name="step-name" select="'sch_flat'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:validate-with-schematron>
  
  <hub:evolve-hub name="evolve-hub-dyn" srcpaths="yes" load="evolve-hub/driver">
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </hub:evolve-hub>

  <tr:validate-with-schematron name="sch_evolve">
    <p:input port="html-in">
      <p:empty/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-param name="family" select="'evolve-hub'"/>
    <p:with-param name="step-name" select="'sch_evolve-hub'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:validate-with-schematron>

  <jats:hub2bits name="hub2jats" load="hub2jats/hub2jats-driver" 
    fallback-xsl="http://transpect.io/hub2bits/xsl/hub2jats-fallback.xsl">
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:input port="models">
      <p:inline>
        <c:models>
          <c:model href="http://transpect.io/schema/jats/archiving/1.0/rng/JATS-archivearticle1.rng" 
            type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"/>
        </c:models>
      </p:inline>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </jats:hub2bits>

  <tr:nlm-stylechecker name="nlm-stylecheck">
    <p:input port="parameters">
      <p:empty/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </tr:nlm-stylechecker>

  <p:sink/>

  <tr:validate-with-schematron name="sch_jats">
    <p:input port="source">
      <p:pipe port="result" step="hub2jats"/>
    </p:input>
    <p:input port="html-in">
      <p:empty/>
    </p:input>
    <p:input port="parameters">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-param name="family" select="'jats'"/>
    <p:with-param name="step-name" select="'sch_jats'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:validate-with-schematron>

  <tr:validate-with-rng-svrl name="rng">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:input port="schema">
      <p:document href="http://transpect.io/schema/jats/archiving/1.0/rng/JATS-archivearticle1.rng"/>
    </p:input>
  </tr:validate-with-rng-svrl>

  <jats:html name="jats2html">
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:input port="source">
      <p:pipe port="result" step="hub2jats"/>
    </p:input>
    <p:with-option name="css-location" select="''"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </jats:html>
  
  <p:add-xml-base name="add-xml-base"/>
  
  <p:add-attribute name="html-add-xml-base" attribute-name="xml:base" match="/*">
    <p:with-option name="attribute-value" select="replace(/*/@xml:base, '[.\p{L}]+$', '.xhtml')"/>
  </p:add-attribute>
  
  <tr:store-debug pipeline-step="html-base">
    <p:with-option name="active" select="$debug"/>
    <p:with-option name="base-uri" select="$debug-dir-uri"/>
  </tr:store-debug>

  <p:sink/>

  <tr:load-cascaded filename="epubtools/epub-config.xml">
    <p:input port="paths">
      <p:pipe port="result" step="paths"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:load-cascaded>
  
  <p:string-replace match="/epub-config/metadata/dc:identifier[1]/text()" name="epub-conf" >
    <p:with-option name="replace" select="concat('''', /c:param-set/c:param[@name = 'basename']/@value, '''')">
      <p:pipe port="result" step="paths"/>
    </p:with-option>
  </p:string-replace>
  
  <p:sink/>
  
  <epub:convert name="epub-convert" clean-target-dir="yes" terminate-on-error="no">
    <p:input port="source">
      <p:pipe port="result" step="html-add-xml-base"/>
    </p:input>
    <p:input port="meta">
      <p:pipe port="result" step="epub-conf"/>
    </p:input>
    <p:input port="conf">
      <p:empty/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </epub:convert>

  <tr:epubcheck-idpf name="epubcheck">
    <p:with-option name="epubfile-path" select="/*/@os-path"/>
    <p:with-option name="svrl-srcpath" select="'BC_orphans'"/>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
  </tr:epubcheck-idpf>

  <p:sink/>

  <p:delete match="@srcpath" name="html-remove-srcpath">
    <p:input port="source">
      <p:pipe port="html" step="epub-convert"/>
    </p:input>
  </p:delete>
  
  <tr:remove-ns-decl-and-xml-base name="html-remove-ns"/>
  
  <p:sink/>

  <tr:remove-ns-decl-and-xml-base name="jats-remove-ns">
    <p:input port="source">
      <p:pipe port="result" step="hub2jats"/>
    </p:input>
  </tr:remove-ns-decl-and-xml-base>
  
  <p:delete match="@srcpath | /*/@source-dir-uri" name="jats-remove-srcpath"/>
  
  <p:sink/>

  <tr:patch-svrl name="patch">
    <p:input port="source">
      <p:pipe port="result" step="jats2html"/>
    </p:input>
    <p:input port="reports">
      <p:pipe port="report" step="docx2hub"/>
      <p:pipe port="report" step="check-styles"/>
      <p:pipe port="report" step="sch_flat"/>
      <p:pipe port="report" step="sch_evolve"/>
      <p:pipe port="report" step="check-styles"/>
      <p:pipe port="report" step="sch_jats"/>
      <p:pipe port="report" step="rng"/>
      <p:pipe port="report" step="epub-convert"/>
      <p:pipe port="result" step="epubcheck"/>
      <p:pipe port="report" step="nlm-stylecheck"/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:input port="params">
      <p:pipe port="result" step="paths"/>
    </p:input>
  </tr:patch-svrl>

  <p:delete name="htmlreport-remove-srcpath" match="@srcpath"/>

  <tr:remove-ns-decl-and-xml-base name="htmlreport-remove-ns"/>

</p:declare-step>