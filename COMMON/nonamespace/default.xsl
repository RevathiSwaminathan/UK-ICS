<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:glp="http://www.lexis-nexis.com/glp" xmlns:ci="http://www.lexis-nexis.com/ci" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">
    
    <xsl:template match="/">
        <xsl:apply-templates/>
    </xsl:template>
       
    <xsl:variable name="RosettaNamespaces" as="element()">
        <RosettaNamepaces>
            <RosettaNamespace>xmlns:docinfo="http://www.lexis-nexis.com/glp/docinfo"</RosettaNamespace>
            <RosettaNamespace>xmlns:comm="http://www.lexis-nexis.com/glp/comm"</RosettaNamespace>
            <RosettaNamespace>xmlns:dict="http://www.lexis-nexis.com/glp/dict"</RosettaNamespace>
            <RosettaNamespace>xmlns:leg="http://www.lexis-nexis.com/glp/leg"</RosettaNamespace>
            <RosettaNamespace>xmlns:ci="http://www.lexis-nexis.com/ci"</RosettaNamespace>
            <RosettaNamespace>xmlns:case="http://www.lexis-nexis.com/glp/case"</RosettaNamespace>
            <RosettaNamesoace>xmlns:glp="http://www.lexis-nexis.com/glp"</RosettaNamesoace>
            <RosettaNamesoace>xmlns:in="http://www.lexis-nexis.com/glp/in"</RosettaNamesoace>
        </RosettaNamepaces>
    </xsl:variable>
    
    <xsl:template match="comment() | processing-instruction()">
        <xsl:copy-of select="."/>
    </xsl:template>
    
    <xsl:variable name="quot">'</xsl:variable>
    <xsl:variable name="openquote">&#8216;</xsl:variable>
    <xsl:variable name="closequote">&#8217;</xsl:variable>
    
    <xsl:template match="text()" name="replace" priority="20">
        <xsl:param name="text" select="."/>
        <xsl:param name="usequote" select="$openquote"/>
        <xsl:choose>            
            <xsl:when test="contains($text,$quot)">
                <xsl:variable name="strlen" select="string-length(substring-before($text,$quot))"/>
                <xsl:choose>
                    <xsl:when test="matches(substring-after($text,$quot),'^\s')">
                        <xsl:value-of select="concat(substring-before($text, $quot), $closequote)"/>
                    </xsl:when>
                    
                    <xsl:when test="substring-before($text,$quot)!='' and substring-after($text,$quot)!='' and matches(substring(substring-before($text,$quot),number($strlen),1),'[a-zA-Z]') and matches(substring(substring-after($text,$quot),1,1),'[a-zA-Z]')">
                        <xsl:value-of select="concat(substring-before($text, $quot), $closequote)"/>
                    </xsl:when>
                    <xsl:otherwise>  
                        <xsl:value-of select="concat(substring-before($text, $quot), $usequote)"/>                      
                    </xsl:otherwise>
                </xsl:choose>
                
                <xsl:call-template name="replace">
                    <xsl:with-param name="text" select="substring-after($text,$quot)"/>
                    <xsl:with-param name="usequote"
                        select="substring(concat($openquote, $closequote), 2 - number($usequote=$closequote), 1)"/>
                </xsl:call-template>
            </xsl:when>
      
            <xsl:when test="matches($text,'\([0-9]{4}\)\s[0-9]+\s[A-Z]+\s[0-9]+[,\s]*$') and self::text()/not(ancestor::ci:cite)">               
                <xsl:analyze-string select="$text" regex="([\(][0-9]{{4}}[\)])\s([0-9]+)\s([A-Z]+)\s([0-9]+)([,\s]*)">
                    <xsl:matching-substring>
                        <ci:cite searchtype='CASE-REF'>
                            <ci:case>
                                <ci:caseref>
                                    <ci:reporter value="{regex-group(3)}"/>
                                    <ci:volume num="{regex-group(2)}"/>
                                    <ci:edition>
                                        <ci:date year="{translate(regex-group(1),'()','')}"/>
                                    </ci:edition>
                                    <ci:page num="{regex-group(4)}"/>
                                </ci:caseref>
                            </ci:case>
                            <ci:content><xsl:value-of select="concat(regex-group(1),' ',regex-group(2),' ',regex-group(3),' ',regex-group(4))"/></ci:content>                            
                        </ci:cite><xsl:value-of select="regex-group(5)"/>
                    </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>                
                <xsl:value-of select="translate($text,'&#160;','')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="Normalize_id_string">
        <xsl:param name="string"/>
        <xsl:variable name="Remove_non_breaking_space">
            <xsl:value-of select="translate($string,'&#160;','')"/>
        </xsl:variable>
        <xsl:variable name="apos">'</xsl:variable>
        <xsl:variable name="Remove_apos">
            <xsl:value-of select="replace($Remove_non_breaking_space,$apos,'_')"/>
        </xsl:variable>
       
        <xsl:value-of select="translate(normalize-space($Remove_apos) , ' &quot;,£&amp;-.!#$%()*+/:;=?@![]\^`|{}~’‘—“Â€ÂÃ¢–', '_')"/>
        
    </xsl:template>
  
    
</xsl:stylesheet>