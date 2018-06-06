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
    
    
    <xsl:variable name="idDocs" select="collection(concat($outputTxtDir,'?select=*_ids.xml'))//ul"/>
    <xsl:variable name="hashDocs" select="collection(concat($outputTxtDir,'?select=*_internalRefs.xml'))//ul"/>
    <xsl:key name="id-to-doc" match="li" use="concat('#',.)"/>
    <xsl:template match="/">
        <xsl:message>Processing <xsl:value-of select="count($hashDocs)"/> files...</xsl:message>
        <xsl:result-document href="{$outputDir}/internalErrors.xml">
            <div>
                <h3>Hash Errors</h3>
                <xsl:for-each select="$hashDocs">
                    <xsl:variable name="thisDocId" select="@data-doc"/>
                    <xsl:message>Processing <xsl:value-of select="$thisDocId"/></xsl:message>
                    <xsl:variable name="errors" as="xs:string*">
                        <xsl:for-each select="li">
                            <xsl:variable name="thisRef" select="."/>
                            <xsl:choose>
                                <xsl:when test="$idDocs[@data-doc=$thisDocId]//key('id-to-doc',$thisRef)"/>
                                <xsl:otherwise>
                                    <xsl:value-of select="."/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:if test="not(empty($errors))">
                        <ul data-doc="{$thisDocId}">
                            <li><xsl:value-of select="$thisDocId"/>
                                <ul>
                                    <xsl:for-each select="$errors">
                                        <li><xsl:value-of select="."/></li>
                                    </xsl:for-each>
                                </ul>
                            </li>
                        </ul>
                    </xsl:if>
                </xsl:for-each>
            </div>
        </xsl:result-document>
    </xsl:template>
                         
    
    <!--<xsl:template match="/">
        <xsl:variable name="localLinks" select="//a[starts-with(@href,'#')]/@href/xs:string(.)"/>
        <xsl:variable name="cleanRefs" select="for $n in $thisDocInternalRefs return substring-after($n,'#')" as="xs:string*"/>
        <xsl:variable name="errors" select="hcmc:compareSeq($cleanRefs,$thisDocIds)"/>
        <xsl:if test="not(empty($errors))">
            <xsl:message>Found <xsl:value-of select="count($errors)"/></xsl:message>
            <xsl:value-of select="string-join($errors,$line.separator)"/>
        </xsl:if>
    </xsl:template>-->
</xsl:stylesheet>