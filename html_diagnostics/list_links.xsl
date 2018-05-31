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
    
    <xsl:variable name="docPaths" select="for $n in tokenize($fileList,$line.separator) return if (matches($n,concat('\.',$suffix,'$'))) then $n else ()"/>
    <xsl:variable name="currDoc" select="."/>
    <xsl:variable name="currUri" select="document-uri($currDoc)"/>
    
    <xsl:output method="xml"/>

    <xsl:template match="/">
        <!--we do internal links in another pass-->
        <xsl:variable name="links" select="distinct-values(//a[@href][not(matches(@href,'^((mailto:)|(https?:)|(null)|(#)|(javascript))'))]/@href/xs:string(.))"/>
        <links sourceDoc="{$currUri}">
            <xsl:for-each select="$links">
                <xsl:variable name="clean" select="hcmc:cleanUri(.)">
                </xsl:variable>
                <xsl:variable name="link1" select="if (contains(.,'?')) then substring-before(.,'?') else ."/>
                <xsl:variable name="thisDoc" select="if (contains($link1,'#')) then substring-before($link1,'#') else ."/>
                <link href="{resolve-uri($thisDoc,$currUri)}">
                    <xsl:if test="contains($link1,'#')">
                        <xsl:attribute name="entity" select="substring-after($link1,'#')"/>
                    </xsl:if>
                </link>
            </xsl:for-each>
        </links>
    </xsl:template>
    
    <xsl:function name="hcmc:cleanUri">
        <xsl:param name="string"/>
        <xsl:analyze-string select="$string" regex="^(.+\.[a-z])((#.+)|(\?.+))?$">
            <xsl:matching-substring>
                <xsl:value-of select="regex-group(1)"/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:message>What?? <xsl:value-of select="$string"/></xsl:message>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
</xsl:stylesheet>