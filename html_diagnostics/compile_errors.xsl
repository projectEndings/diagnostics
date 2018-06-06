<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">
    <xsl:include href="global.xsl"/>
    
    <!--And now we need to compile some errors-->
    
    <!--We're going doc by doc here-->
    
    
    <xsl:output method="xml"/>
    <xsl:variable name="xmlDocs" select="collection(concat($outputTxtDir,'?select=*.xml'))//references"/>
    <xsl:variable name="distinctReferences" select="distinct-values($xmlDocs/descendant::*:ref/xs:string(normalize-space(.)))"/>

    <xsl:template match="/">
        <!--<xsl:message>Processing this document: <xsl:value-of select="$thisDocId"/></xsl:message>-->
        <xsl:variable name="compileErrorsTest">
            <xsl:for-each select="$thisDocRefs">
                <xsl:choose>
                    <xsl:when test="$uniquesXml//key('string-to-error',.)"/>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        
      <!--  <xsl:variable name="pointerErrors" select=""/>-->
        <xsl:message>Checking <xsl:value-of select="count($thisDocRefs)"/> refs</xsl:message>
        <!--<xsl:variable name="pointerErrors" as="xs:string*">
            <xsl:for-each select="$thisDocRefs">
                <xsl:variable name="thisLine" select="."/>
                <!-\-<xsl:message>Investigating this line: <xsl:value-of select="$thisLine"/></xsl:message>-\->
                <xsl:choose>
                    <xsl:when test="$siteErrors[.=$thisLine]">
                        <!-\-<xsl:message>!!!!!Found this error: <xsl:value-of select="$thisLine"/></xsl:message>-\->
                        <xsl:value-of select="$thisLine"/>
                    </xsl:when>
                    <xsl:otherwise/>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>-->
     <!--   <xsl:if test="not(empty($xmlErrorTest))">
            <xsl:message>Found errors!</xsl:message>
            <xsl:message>
                <xsl:for-each select="$xmlErrorTest">
                    <xsl:value-of select="."/>
                </xsl:for-each>
            </xsl:message>
           
        </xsl:if>-->
        <xsl:message>
            <xsl:copy-of select="$compileErrorsTest"/>
        </xsl:message>
    </xsl:template>
    
 
    
</xsl:stylesheet>