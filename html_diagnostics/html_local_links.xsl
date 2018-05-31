<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    version="3.0">
    
    <!--The assumption here is that your project has internal linking within
        the site itself; this is mostly for an endings implementation.
        
        We could write a parallel, and more capacious that doesn't rely on a project specific regex, XSLT3.0 version, too-->
    
    <xsl:param name="projectDirectory"/>
    <xsl:param name="fileList"/>
    <xsl:param name="line.separator"/>
    <xsl:param name="suffix"/>
    
    <xsl:variable name="thisDoc" select="."/>
   
   
    <xsl:key name="id" match="*[@id]"  use="@id"/>
    
    <xsl:template match="/">
        <xsl:variable name="localLinks" select="//a[starts-with(@href,'#')]/@href/xs:string(.)"/>
        <xsl:for-each select="distinct-values($localLinks)">
            <xsl:variable name="thisLink" select="."/>
            <xsl:choose>
                <xsl:when test="$thisDoc//key('id',substring-after($thisLink,'#'))"/>
                <xsl:otherwise>
                    <xsl:message>Cannot find internal link: <xsl:value-of select="$thisLink"/></xsl:message>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>