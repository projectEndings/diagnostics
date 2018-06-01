<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">
    <xsl:include href="global.xsl"/>
    
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        <xsl:message>Checking all unique pointers...</xsl:message>
        <!--<xsl:message>Here is the count of files that we should be checking: <xsl:value-of select="count($filesToCheck)"/></xsl:message>-->
        <!--Okay, first do the easy ones-->
        <xsl:variable name="uniqueRefsCount" select="count(distinct-values(for $n in $uniqueRefs return hcmc:getBaseUri($n)))"/>
        <xsl:variable name="out" as="xs:string*">
            <xsl:for-each-group select="$uniqueRefs" group-by="hcmc:getBaseUri(.)">
                <xsl:variable name="baseUri" select="current-grouping-key()"/>
                <xsl:variable name="currPos" select="position()"/>
                <xsl:message>Checking <xsl:value-of select="$currPos"/>/<xsl:value-of select="$uniqueRefsCount"/></xsl:message>
               <!-- <xsl:message>Checking this uri: <xsl:value-of select="$baseUri"/></xsl:message>-->
                <xsl:variable name="thisDocId" select="substring-before(tokenize($baseUri,'/')[last()],'.')"/>
                <xsl:variable name="groupItemsToCheck" select="for $n in current-group() return if (contains($n,'#')) then $n else ()"/>
                <xsl:choose>
                    <xsl:when test="hcmc:testAvailability($baseUri)">
                        <xsl:if test="not(empty($groupItemsToCheck))">
                            
                            <!--Get the path after the project dir (i.e. my/project/this/file.html becomes /this/file.html)-->
                            <xsl:variable name="relativePath" select="substring-after($baseUri,$projectDirectory)"/>
                            
                            <!--Now add the outputTxtDir path and get rid of the suffix (i.e. /this/file.html becomes my/project/this/outputDir/txt/this/file)-->
                            <xsl:variable name="fullOutputDir" select="substring-before(concat($outputTxtDir,$relativePath),concat('.',$suffix))"/>

                            <xsl:variable name="thisDocIdsFile" select="unparsed-text(concat($fullOutputDir,'_ids.txt'))"/>
                            <xsl:variable name="thisDocIds" select="tokenize($thisDocIdsFile,$line.separator)"/>
                            <xsl:for-each select="$groupItemsToCheck">
                                <xsl:variable name="thisSubUri" select="."/>
                                <xsl:variable name="thisFrag" select="substring-after($thisSubUri,'#')"/>
                                <!--  <xsl:message>checking this frag <xsl:value-of select="$thisFrag"/></xsl:message>-->
                                <xsl:choose>
                                    <xsl:when test="$thisDocIds[.=$thisFrag]">
                                        <!--    <xsl:message>Frag found!</xsl:message>-->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:message>Could not find URI: <xsl:value-of select="$thisSubUri"/></xsl:message>
                                        <xsl:value-of select="$thisSubUri"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message>Could not find URI: <xsl:value-of select="$baseUri"/></xsl:message>
                        <xsl:value-of select="$baseUri"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:if test="not(empty($out))">
            <xsl:value-of select="string-join($out,$line.separator)"/>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>