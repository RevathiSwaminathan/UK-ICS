<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:dict="http://www.lexis-nexis.com/glp/dict"
    xmlns:glp="http://www.lexis-nexis.com/glp"
    xmlns:case="http://www.lexis-nexis.com/glp/case"
    xmlns:ci="http://www.lexis-nexis.com/ci"
    xmlns:jrnl="http://www.lexis-nexis.com/glp/jrnl"
    exclude-result-prefixes="xs"
    version="2.0">
        
    <!-- Uncomment the below xsl:param while unit testing -->
    <!-- Start: For unit-testing -->
   <!-- <xsl:param name="selectorID" select="'dictionary'"/>
    <xsl:include href="../nonamespace/default.xsl"/>-->
    <!-- End: For unit-testing -->
    
    <xsl:template match="emph[ancestor::defterm] | emph[parent::h] | emph[parent::dict:topicname] | emph[parent::remotelink/parent::url] [$selectorID='dictionary']" priority="20">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="emph[child::remotelink][$selectorID='dictionary']" priority="20">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="emph[ancestor::defterm | child::remotelink | emph[parent::h] | emph[parent::dict:topicname]]/@* [$selectorID='dictionary']" priority="20"/>
    
    <xsl:template match="emph[ancestor::heading/parent::dict:body][$selectorID='dictionary']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="emph[@typestyle='bf'][$selectorID='index']">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="emph[parent::jrnl:articletitle][$selectorID='journal'] | emph[parent::name.text][$selectorID='journal'] | emph[parent::title][$selectorID='journal'] | emph[ancestor::abstract][$selectorID='journal']">
        <xsl:apply-templates/>
    </xsl:template>    

    
    <xsl:template match="emph[@typestyle='smcaps'][$selectorID='index']">
        <emph typestyle="smcaps">            
                <remotelink service="DOC-ID" remotekey1="REFPTID">
                    <xsl:attribute name="refpt">
                     <xsl:variable name="prepend" select="'acronym:HALS-INDEX::term:'"/>
                        <xsl:variable name="remtext" select="self::emph/text()"/>                        
                        <xsl:value-of
                            select="concat($prepend,translate(upper-case($remtext),' ','_'))"/>
                    </xsl:attribute>
                    <xsl:attribute name="docidref" select="'95ed127a-e22e-4234-939e-bf12978c46da'"/>
                    <xsl:attribute name="dpsi" select="'003B'"/>
                    <xsl:attribute name="status" select="'valid'"/>
               <xsl:apply-templates/>                
                </remotelink>           
        </emph>
    </xsl:template>
    
   <!-- <xsl:template match="emph[self::emph/following-sibling::ci:cite][ancestor::case:priorhist | ancestor::case:consideredcases] [$selectorID='cases']">
        <xsl:apply-templates/>
    </xsl:template>
    -->
    <xsl:template match="emph">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>
    
    <xsl:template match="emph[parent::text/node()[1]=self::emph] [matches(self::emph,'^(\([a-zA-Z0-9]+\)|&#x25cf;|&#x2022;)([\t&#160;]*)')]"/>
    
    
    <xsl:template match="emph/@*">
        <xsl:copy/>
    </xsl:template>
    
</xsl:stylesheet>