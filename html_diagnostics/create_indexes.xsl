<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">

    <xsl:include href="global.xsl"/>
    
    <xsl:output method="xml"/>
    
    <xsl:key name="hash-to-id" use="concat('#',@xml:id)" match="*"/>
    
    <xsl:variable name="allIds" select="descendant-or-self::*/@id"/>
    <xsl:variable name="links" select="for $n in distinct-values(//a[@href][not(matches(@href,'^((mailto:)|(https?:)|(null)|(#)|(javascript))|(/$)'))]/@href/xs:string(.)) return normalize-space($n)" as="xs:string*"/>
    
    <xsl:variable name="internalRefs" select="distinct-values(//a[@href][matches(@href,'^#')]/@href/xs:string(.))" as="xs:string*"/>
    <xsl:variable name="thisDocUri" select="document-uri(.)"/>
    <xsl:variable name="thisOutUri" select="hcmc:getOutputUriNe($thisDocUri)"/>

    <xsl:template match="/">
        <xsl:result-document href="{$thisOutUri}_refs.xml">
            <ul id="references" data-doc="{$thisDocUri}">
                <xsl:for-each select="$links">
                    <xsl:variable name="uri" select="resolve-uri(hcmc:cleanUri(.),$thisDocUri)"/>
                    <li><xsl:value-of select="$uri"/></li>
                </xsl:for-each>
            </ul>
        </xsl:result-document>
        
        <xsl:result-document href="{$thisOutUri}_ids.xml">
            <ul id="ids" data-doc="{$thisDocUri}">
                <xsl:for-each select="$allIds">
                    <li><xsl:value-of select="."/></li>
                </xsl:for-each>
            </ul>
        </xsl:result-document>
        
        <xsl:result-document href="{$thisOutUri}_internalRefs.xml">
            <ul id="internalRefs" data-doc="{$thisDocUri}">
                <xsl:for-each select="$internalRefs">
                    <li><xsl:value-of select="."/></li>
                </xsl:for-each>
            </ul>
        </xsl:result-document>
        
        

    </xsl:template>
    
   
</xsl:stylesheet>