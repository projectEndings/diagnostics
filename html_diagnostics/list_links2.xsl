<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">

    <xsl:include href="global.xsl"/>
    
    <xsl:output method="text"/>
    
    <xsl:variable name="allIds" select="descendant-or-self::*/@id"/>
    
    <xsl:template match="/">
        <!--we do internal links in another pass-->
        <xsl:variable name="links" select="for $n in distinct-values(//a[@href][not(matches(@href,'^((mailto:)|(https?:)|(null)|(#)|(javascript))'))]/@href/xs:string(.)) return normalize-space($n)" as="xs:string*"/>
        <xsl:variable name="internalRefs" select="distinct-values(//a[@href][matches(@href,'^#')]/@href/xs:string(.))" as="xs:string*"/>
        <!--This is the first result-document-->
        <xsl:for-each select="$links">

            <xsl:variable name="uri" select="resolve-uri(hcmc:cleanUri(.),$thisDocUri)"/>
            <xsl:message>This link... <xsl:value-of select="$uri"/></xsl:message>
            <xsl:value-of select="$uri"/><xsl:value-of select="$line.separator"/>            
        </xsl:for-each>
        
        <!--ALl of the ids-->
        <xsl:result-document href="{$outputTxtDir}/{$thisDocId}_ids.txt" method="text">
           <!-- <xsl:message>Creating <xsl:value-of select="concat($outputDir,'/',$docId,'_ids.txt')"/></xsl:message>-->
            <xsl:for-each select="$allIds">
                <xsl:value-of select="."/><xsl:value-of select="$line.separator"/>
            </xsl:for-each>
        </xsl:result-document>
        
        <xsl:result-document href="{$outputTxtDir}/{$thisDocId}_internalRefs.txt" method="text">
            <xsl:value-of select="string-join($internalRefs,$line.separator)"/>
        </xsl:result-document>
    </xsl:template>
    
   
</xsl:stylesheet>