<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:xh="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Started on:</xd:b> February 22, 2017</xd:p>
            <xd:p><xd:b>Authors:</xd:b> <xd:a href="http://mapoflondon.uvic.ca/TAKE1.htm">jtakeda</xd:a>
            and <a href="http://mapoflondon.uvic.ca/HOLM3.htm">mholmes</a>.</xd:p>
            <xd:p>
                This XSLT produces the necessary pages for the diagnostics report. It calls upon
                a statistics module and a diagnostics module.
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:param name="projectDirectory"/>
    
<!--    Has to made relative since the xsl is being called from a subfolder.-->
    <xsl:variable name="relativeProjectDirectory" select="concat('../',$projectDirectory)"/>
    <xsl:variable name="projectCollection" select="collection(concat($projectDirectory,'?select=*.xml;recurse=yes'))"/>
    <xsl:variable name="teiFiles" select="$projectCollection//TEI"/>
    
    <xsl:key name="declaredIds" match="*/@xml:id" use="normalize-space(concat(hcmc:returnFileName(.),'#',.))"/>
    
    <xsl:template match="/">
        <xsl:message>TESTING</xsl:message>
        <xsl:for-each select="$teiFiles//*/@target">
            <xsl:variable name="thisTarg" select="."/>
            <xsl:variable name="thisTargFileName" select="hcmc:returnFileName(.)"/>
            <xsl:variable name="thisTargString" select="normalize-space($thisTarg)" as="xs:string"/>
            <xsl:variable name="thisTargTokens" select="tokenize($thisTargString,'\s+')" as="xs:string*"/>
            <xsl:for-each select="$thisTargTokens">
                <xsl:variable name="thisToken" select="normalize-space(.)"/>
                <xsl:variable name="thisTokenAfterHash" select="normalize-space(substring-after($thisToken,'#'))"/>
                <xsl:choose>
                    <xsl:when test="$teiFiles//key('declaredIds',$thisToken)">
                        <xsl:message>Found id for <xsl:value-of select="."/></xsl:message>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>ID <xsl:value-of select="."/> not found.</xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:for-each>
    </xsl:template>
    
    <xsl:function name="hcmc:returnFileName" as="xs:string">
        <xsl:param name="file"/>
        <xsl:value-of select="normalize-space(tokenize(base-uri($file),'/')[last()])"/>
    </xsl:function>
    
    
</xsl:stylesheet>