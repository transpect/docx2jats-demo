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
  xmlns:hub="http://transpect.io/hub" name="docx2epub" version="1.0">

  <p:output port="result" primary="true">
    <p:documentation>JATS</p:documentation>
  </p:output>
  <p:serialization port="result" indent="true"/>

  <p:option name="file" required="true"/>

  <p:option name="debug" select="'yes'"/>
  <p:option name="debug-dir-uri" select="'debug'"/>
  <p:option name="status-dir-uri" select="'status'"/>
  
  <p:import href="http://xmlcalabash.com/extension/steps/library-1.0.xpl"/>
  <p:import href="http://transpect.io/docx2hub/xpl/docx2hub.xpl"/>
  <p:import href="http://transpect.io/xproc-util/store-debug/xpl/store-debug.xpl"/>
  <p:import href="http://transpect.io/evolve-hub/xpl/evolve-hub.xpl"/>
  <p:import href="http://transpect.io/hub2bits/xpl/hub2bits.xpl"/>
  <p:import href="http://transpect.io/jats2html/xpl/jats2html.xpl"/>
  <p:import href="http://transpect.io/xproc-util/remove-ns-decl-and-xml-base/xpl/remove-ns-decl-and-xml-base.xpl"/> 
 
  <docx2hub:convert name="docx2hub" srcpaths="yes" unwrap-tooltip-links="yes">
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
    <p:with-option name="docx" select="$file"/>
  </docx2hub:convert>

  <hub:evolve-hub name="evolve-hub-dyn" srcpaths="yes" load="evolve-hub/driver">
    <p:input port="paths">
      <p:empty/>
    </p:input>
    <p:with-option name="debug" select="$debug"/>
    <p:with-option name="debug-dir-uri" select="$debug-dir-uri"/>
    <p:with-option name="status-dir-uri" select="$status-dir-uri"/>
  </hub:evolve-hub>

  <jats:hub2bits name="hub2jats" load="hub2jats/hub2jats-driver" 
    fallback-xsl="http://transpect.io/hub2bits/xsl/hub2jats-fallback.xsl">
    <p:input port="paths">
      <p:empty/>
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
  
  <tr:remove-ns-decl-and-xml-base name="jats-remove-ns"/>
  
  <p:delete match="@srcpath" name="jats-remove-srcpath"/>
  
</p:declare-step>