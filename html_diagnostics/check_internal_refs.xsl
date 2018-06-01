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
        <xsl:variable name="cleanRefs" select="for $n in $thisDocInternalRefs return substring-after($n,'#')" as="xs:string*"/>
        <xsl:variable name="errors" select="hcmc:compareSeq($cleanRefs,$thisDocIds)"/>
        <xsl:if test="not(empty($errors))">
            <xsl:message>Found <xsl:value-of select="count($errors)"/></xsl:message>
            <xsl:value-of select="string-join($errors,$line.separator)"/>
        </xsl:if>
    </xsl:template>
</xsl:stylesheet>