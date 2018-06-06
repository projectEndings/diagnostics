<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    version="2.0">
    
    <xsl:include href="global.xsl"/>

    
    <xsl:output method="xml"/>
    <xsl:template match="/">
        <ul>
            <xsl:for-each select="$systemFiles">
                <li><xsl:value-of select="normalize-space(.)"/></li>
            </xsl:for-each>
        </ul>
    </xsl:template>
</xsl:stylesheet>