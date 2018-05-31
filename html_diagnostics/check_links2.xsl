<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="3.0">
    
    <xsl:param name="projectDirectory"/>
    <xsl:param name="suffix"/>
    <xsl:param name="fileList"/>
    <xsl:param name="line.separator"/>
    <xsl:param name="uniques"/>
    <xsl:param name="outputDir"/>
    
    <xsl:variable name="thisDocId" select="tokenize(document-uri(.),'/')[last()]"/>
    <xsl:variable name="systemFiles" select="tokenize(unparsed-text($fileList),$line.separator)"/>    
    <xsl:variable name="systemFilesCount" select="count($systemFiles)"/>
    <xsl:variable name="lines" select="tokenize(unparsed-text($uniques),$line.separator)"/>
    <xsl:variable name="lineCount" select="count($lines)"/>
    <xsl:variable name="documentRegex" select="'\.((xml)|(kml)|(html?)|(xsl),(rss))(#.+)?$'"/>
    <xsl:variable name="unparsedRegex" select="'\.((txt)|(md)|(css)|(js))$'"/>
    <xsl:variable name="binaryDocsInProject" select="for $n in $systemFiles return if (not(matches($n,$documentRegex)) and not(matches($n,$unparsedRegex))) then $n else ()"/>
    
    <xsl:variable name="collectionRegex" select="concat('^',string-join(for $n in $binaryDocsInProject return concat('(',hcmc:escape-for-regex($n),')'),'|'),'$')"/>
    
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        <xsl:message>Initiating...</xsl:message>
        <!--<xsl:message>Here is the count of files that we should be checking: <xsl:value-of select="count($filesToCheck)"/></xsl:message>-->
        <!--Okay, first do the easy ones-->
        <xsl:variable name="out" as="xs:string*">
            <xsl:for-each-group select="$lines" group-by="hcmc:getBaseUri(.)">
                <xsl:variable name="baseUri" select="current-grouping-key()"/>
                <xsl:message>Checking this uri: <xsl:value-of select="$baseUri"/></xsl:message>
                <xsl:variable name="thisDocId" select="substring-before(tokenize($baseUri,'/')[last()],'.')"/>
                <xsl:variable name="groupItemsToCheck" select="for $n in current-group() return if (contains($n,'#')) then $n else ()"/>
                <xsl:choose>
                    <xsl:when test="hcmc:testAvailability($baseUri)">
                        <xsl:choose>
                            
                            <xsl:when test="not(empty($groupItemsToCheck))">
                                <xsl:message>Found fragments!</xsl:message>
                                <!--Now we need to find the index!-->
                                <xsl:variable name="thisDoc" select="unparsed-text(concat($outputDir,'/',$thisDocId,'_ids.txt'))"/>
                                <xsl:variable name="thisDocIds" select="tokenize($thisDoc,$line.separator)"/>
                                <xsl:for-each select="$groupItemsToCheck">
                                    <xsl:variable name="thisSubUri" select="."/>
                                    <xsl:variable name="thisFrag" select="substring-after($thisSubUri,'#')"/>
                                    <xsl:message>checking this frag <xsl:value-of select="$thisSubUri"/></xsl:message>
                                    <xsl:choose>
                                        <xsl:when test="$thisDocIds[.=$thisSubUri]"/>
                                        <xsl:otherwise>
                                            <xsl:message>Fragment not found.</xsl:message>
                                            <xsl:value-of select="$thisSubUri"/>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                    
                                </xsl:for-each>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="$baseUri"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="$baseUri"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:variable>
        <xsl:if test="not(empty($out))">
            <xsl:value-of select="string-join($out,$line.separator)"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:function name="hcmc:escape-for-regex" as="xs:string">
        <xsl:param name="arg" as="xs:string?"/>
        
        <xsl:sequence select="
            replace($arg,
            '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
            "/>
        
    </xsl:function>
    
    <xsl:function name="hcmc:testAvailability" as="xs:boolean">
        <xsl:param name="uri"/>
        <xsl:message>Testing availability of <xsl:value-of select="$uri"/></xsl:message>
        <!--<xsl:variable name="result" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="matches($uri,$documentRegex)">
                    <xsl:value-of select="doc-available(if (contains($uri,'#')) then substring-before($uri,'#') else $uri)"/>
                </xsl:when>
                <xsl:when test="matches($uri,$unparsedRegex)">
                    <xsl:value-of select="unparsed-text-available($uri)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="matches($uri,$collectionRegex)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>-->
        <xsl:variable name="result" as="xs:boolean">
            <xsl:choose>
                <xsl:when test="$systemFiles[concat('file:',.)=$uri]">
                    <xsl:value-of select="true()"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="false()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
       <xsl:value-of select="$result"/>
        <xsl:if test="not($result)">
            <xsl:message><xsl:value-of select="$result"/></xsl:message>
        </xsl:if>
        
    </xsl:function>
    
    <xsl:function name="hcmc:getBaseUri" as="xs:string">
        <xsl:param name="uri"/>
        <xsl:value-of select="if (contains($uri,'#')) then substring-before($uri,'#') else $uri"/>
    </xsl:function>
    
    
    
</xsl:stylesheet>