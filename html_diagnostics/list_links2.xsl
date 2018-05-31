<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">
    
    <xsl:param name="projectDirectory"/>
    <xsl:param name="suffix"/>
    <xsl:param name="fileList"/>
    <xsl:param name="line.separator"/>
    <xsl:param name="outputDir"/>
<!--    
    <xsl:variable name="docPaths" select="for $n in tokenize($fileList,$line.separator) return if (matches($n,concat('\.',$suffix,'$'))) then $n else ()"/>-->
    <xsl:variable name="currDoc" select="."/>
    <xsl:variable name="currUri" select="document-uri($currDoc)"/>
    <xsl:variable name="docId" select="substring-before(tokenize($currUri,'/')[last()],concat('.',$suffix))"/>
    <xsl:variable name="documentRegex" select="'\.((xml)|(kml)|(html?)|(xsl),(rss))$'"/>
    <xsl:variable name="textRegex" select="'\.((txt)|(md)|(css)|(js))$'"/>
    
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        <!--we do internal links in another pass-->
        <xsl:variable name="links" select="distinct-values(//a[@href][not(matches(@href,'^((mailto:)|(https?:)|(null)|(#)|(javascript))'))]/@href/xs:string(.))"/>
        
        <xsl:for-each select="$links">
            <xsl:variable name="uri" select="resolve-uri(hcmc:cleanUri(.),$currUri)"/>
            <xsl:value-of select="$uri"/><xsl:value-of select="$line.separator"/>            
        </xsl:for-each>
        <xsl:result-document href="{$outputDir}/{$docId}_ids.txt">
            <xsl:message>Creating <xsl:value-of select="concat($outputDir,'/',$docId,'_ids.txt')"/></xsl:message>
            <xsl:for-each select="//*[@id]/@id">
                <xsl:value-of select="."/><xsl:value-of select="$line.separator"/>
            </xsl:for-each>
        </xsl:result-document>

    </xsl:template>
    
    <xsl:function name="hcmc:cleanUri">
        <xsl:param name="string"/>
        <xsl:choose>
            <xsl:when test="contains($string,'?')">
               
                <xsl:value-of select="substring-before($string,'?')"/>
      
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:function>
</xsl:stylesheet>