<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">
    
    <xsl:param name="projectDirectory"/>
    <xsl:param name="suffix"/>
    <xsl:param name="fileList"/>
    <xsl:param name="line.separator"/>
    
    <xsl:variable name="thisDocId" select="tokenize(document-uri(.),'/')[last()]"/>
    <xsl:variable name="files" select="tokenize($fileList,$line.separator)"/>
    
    <xsl:variable name="regex" select="concat('^',string-join(for $n in $files return concat('(',hcmc:escape-for-regex($n),')'),'|'),'$')"/>
    
    <xsl:template match="links">
<!--        <xsl:message>This regex: <xsl:value-of select="$regex"/></xsl:message>-->
        <xsl:copy>
            <xsl:apply-templates/>   
        </xsl:copy>
    </xsl:template>
    
    <xsl:variable name="documentRegex" select="'\.((xml)|(kml)|(html?)|(xsl),(rss))$'"/>
    <xsl:variable name="unparsedText" select="'\.((txt)|(md)|(css)|(js))$'"/>
    
    <!--Easiest case-->
    <xsl:template match="link[not(@entity)][matches(@href,$documentRegex)]">
        <!--<xsl:message><xsl:value-of select="$thisDocId"/>: Easy case (<xsl:copy-of select="."/>)</xsl:message>-->
        <xsl:choose>
            <xsl:when test="doc-available(@href)"/>
            <xsl:otherwise>
                <!--<xsl:message><xsl:value-of select="$thisDocId"/>: FAILED</xsl:message>-->
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="link[not(@entity)][matches(@href,$unparsedText)]">
        <!--<xsl:message><xsl:value-of select="$thisDocId"/>: Unparsed text (<xsl:copy-of select="."/>)</xsl:message>-->
        <xsl:choose>
            <xsl:when test="unparsed-text-available(@href)"/>
            <xsl:otherwise>
                <!--<xsl:message><xsl:value-of select="$thisDocId"/>: FAILED</xsl:message>-->
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="link[@entity]">
        <!--<xsl:message><xsl:value-of select="$thisDocId"/>: Fragment (<xsl:copy-of select="."/>)</xsl:message>-->
        <xsl:variable name="thisEntity" select="@entity"/>
        <xsl:choose>
            <xsl:when test="doc-available(@href)">
                <xsl:choose>
                    <xsl:when test="document(@href)[descendant-or-self::*[@id=$thisEntity]]"/>
                    <xsl:otherwise>
                        <!--<xsl:message><xsl:value-of select="$thisDocId"/>: FAILED</xsl:message>-->
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="link">
        <!--<xsl:message><xsl:value-of select="$thisDocId"/>: Must be a binary doc (<xsl:value-of select="@href"/>)</xsl:message>-->
        <xsl:choose>
            <xsl:when test="matches(@href,$regex)"/>
            <xsl:otherwise>
                <!--<xsl:message><xsl:value-of select="$thisDocId"/>: FAILED</xsl:message>-->
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!--xsl:template match="link[contains(@href,'#')]">
        <xsl:variable name="doc" select="substring-before(@href,'#')"/>
        <xsl:choose>
            <xsl:when test="doc-available($doc)">
                <xsl:variable name="entity" select="substring-after(@href,'#')"/>
                <xsl:choose>
                    <xsl:when test="document($doc)[descendant::*[@id=$entity]]"/>
                    <xsl:otherwise>
                        <xsl:copy-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:copy-of select="."/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->
    
   <!-- <xsl:template match="link">
        <xsl:message>Binary doc, maybe: <xsl:value-of select="@href"/></xsl:message>
    </xsl:template>-->
    
   <!-- <xsl:template match="link[matches(@href,$regex)]">
<!-\-        <xsl:message>Found match!</xsl:message>-\->
    </xsl:template>
    
    <xsl:template match="link[not(matches(@href,$regex))]">
        <xsl:message>Did not find match</xsl:message>
        <xsl:copy-of select="."/>
    </xsl:template>-->
    
    <xsl:function name="hcmc:escape-for-regex" as="xs:string">
        <xsl:param name="arg" as="xs:string?"/>
        
        <xsl:sequence select="
            replace($arg,
            '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
            "/>
        
    </xsl:function>
    
    
</xsl:stylesheet>