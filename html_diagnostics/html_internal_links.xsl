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

    
    <xsl:variable name="files" select="tokenize($fileList,$line.separator)"/>
    
    <xsl:variable name="fileRegex" select="concat('^',string-join(for $n in $files return concat('(',hcmc:escape-for-regex($n),')'),'|'),'$')"/>
    
    <xsl:template match="/">
        <!--<xsl:message>This regex: <xsl:value-of select="$fileRegex"/></xsl:message>-->
            <xsl:variable name="docUri" select="document-uri(root(.))"/>
            <xsl:message>Checking <xsl:value-of select="document-uri(root(.))"/></xsl:message>
            <xsl:variable name="links" select="distinct-values(//a[@href][not(matches(@href,'^((mailto:)|(https?:)|(null)|(#)|(javascript))'))]/@href/xs:string(.))"/>
            
<!--        <xsl:message><xsl:copy-of select="$fileRegex"/></xsl:message>-->
            <xsl:for-each select="$links">
                <xsl:variable name="thisLink" select="."/>
                        <xsl:variable name="thisUri" select="resolve-uri($thisLink,$docUri)"/>
                        <!--                <xsl:message>Checking this pointer: <xsl:value-of select="$thisUri"/></xsl:message>-->
                        <xsl:choose>
                            <xsl:when test="matches($thisUri,concat('\.',$suffix,'#.+$'))">
                                <xsl:variable name="thisDoc" select="concat(substring-before($thisUri,concat($suffix,'#')),$suffix)"/>
                                <xsl:variable name="thisFrag" select="substring-after($thisUri,concat($thisDoc,'#'))"/>
                                <!-- <xsl:message>This doc: <xsl:value-of select="$thisDoc"/></xsl:message>
                        <xsl:message>This frag: <xsl:value-of select="$thisFrag"/></xsl:message>-->
                                <xsl:variable name="thisDocument" select="document($thisDoc)"/>
                                <xsl:variable name="hasId" select="if ($thisDocument/descendant-or-self::*[@id=$thisFrag]) then true() else false()" as="xs:boolean"/>
                                <xsl:choose>
                                    <xsl:when test="$hasId">
                                        <!--                         <xsl:message>
                                    Found the fragment!
                                </xsl:message>-->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:message>ERROR: Could not find frag! <xsl:value-of select="$thisUri"/></xsl:message>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:when test="matches($thisUri,$fileRegex)">
                                <!--                        <xsl:message>Found the document!</xsl:message>-->
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:message>ERROR: Could not find document: <xsl:value-of select="$thisUri"/></xsl:message>
                            </xsl:otherwise>
                        </xsl:choose>
                
            </xsl:for-each>
    </xsl:template>
    
        <xsl:function name="hcmc:makeRegex" as="xs:string">
            <xsl:param name="strings"/>
            <xsl:param name="baseDir"/>            
            <xsl:variable name="escapedBaseDir" select="replace($baseDir, '\\', '/')"/>
            <!--<xsl:message><xsl:value-of select="string-join($strings, '&#x0a;')"/></xsl:message>
        <xsl:message><xsl:value-of select="$baseDir"/></xsl:message>-->
            <xsl:variable name="collapsedPaths" select="for $s in $strings return replace(replace($s,'/\./','/'),concat('file:', if (starts-with($escapedBaseDir, '/')) then '' else '/', $escapedBaseDir,'/'),'')"/>
            <xsl:variable name="regex" select="replace(concat('^file:', if (starts-with($escapedBaseDir, '/')) then '' else '/', $escapedBaseDir,'/(',string-join(for $s in $collapsedPaths return concat('(',$s,')'),'|'),')$'),'\.','\\.')"/>
            
            <!--<xsl:message select="$regex"/>-->
            <xsl:value-of select="$regex"/>
        </xsl:function>
    
    <xsl:function name="hcmc:escape-for-regex" as="xs:string">
        <xsl:param name="arg" as="xs:string?"/>
        
        <xsl:sequence select="
            replace($arg,
            '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
            "/>
        
    </xsl:function>
    
</xsl:stylesheet>