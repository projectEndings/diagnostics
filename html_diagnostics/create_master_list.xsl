<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">
    
    <xsl:param name="masterListPath"/>
    
    <xsl:variable name="docs" select="collection(concat($masterListPath,'?select=*.xml'))"/>
    <xsl:variable name="links" select="$docs//*:link/@href/xs:string(.)" as="xs:string*"/>
    <xsl:variable name="distinctLinks" select="distinct-values($links)" as="xs:string*"/>   
    <xsl:variable name="fileRegex" select="concat('^',string-join(for $n in $files return concat('(',hcmc:escape-for-regex($n),')'),'|'),'$')"/>
    
    <!--Docs-->
    <xsl:variable name="docsToCheck" select="distinct-values(for $n in $distinctLinks return if (contains($n,'#')) then substring-before($n,'#') else $n)" as="xs:string*"/>
    
    <!--<xsl:variable name="docFrags" as="element()*">
        <xsl:for-each select="$docsToCheck">
            <xsl:variable name="thisDoc" select="."/>
            
            
            <xsl:if test="count($frags) gt 0">
                <fragment id="{substring-after(.,'#')}" sourceDoc="{substring-before(.,'#')}"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:variable>-->
    

    
    <xsl:template match="/">
        <xsl:message>Found <xsl:value-of select="count($docsToCheck)"/> distinct docs from <xsl:value-of select="count($distinctLinks)"/> distinct links from <xsl:value-of select="count($links)"/> total links</xsl:message>
        <xsl:for-each select="$docsToCheck">
            <xsl:message>Processing <xsl:value-of select="position()"/></xsl:message>
            <xsl:variable name="thisDoc" select="."/>
            <xsl:variable name="linkedDocs" select="string-join($docs//*:link[@href=$thisDoc]/parent::*:links/@sourceDoc,' ')"/>
            <xsl:variable name="frags" select="for $n in $distinctLinks return if (matches($n,concat('^',$thisDoc,'#.+$'))) then substring-after($n,'#') else ()"/>
            <xsl:choose>
                <xsl:if test="matches($thisHref"
            </xsl:choose>
            <links>
                <link href="{.}">
                    <docs><xsl:value-of select="$linkedDocs"/></docs>
                    <xsl:if test="not(empty($frags))">
                        <entities><xsl:value-of select="string-join($frags,' ')"/></entities>
                    </xsl:if>
                   
                </link>
            </links>
        </xsl:for-each>
    </xsl:template>
</xsl:stylesheet>