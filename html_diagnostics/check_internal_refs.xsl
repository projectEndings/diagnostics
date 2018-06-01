<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    version="2.0">
    
    <xsl:include href="global.xsl"/>
    <xsl:output method="text"/>
    
    
    <xsl:template match="/">
       <!-- <xsl:variable name="localLinks" select="//a[starts-with(@href,'#')]/@href/xs:string(.)"/>-->
        <xsl:variable name="out" as="xs:string*">
            <xsl:for-each select="$thisDocInternalRefs">
              <!--  <xsl:message>Processing <xsl:value-of select="."/></xsl:message>-->
                <xsl:choose>
                    <xsl:when test="substring-after(.,'#')=$thisDocIds"/>
                    <xsl:otherwise>
                        <xsl:message>Could not find reference: <xsl:value-of select="."/></xsl:message>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="string-join($out,$line.separator)"/>
    </xsl:template>
</xsl:stylesheet>