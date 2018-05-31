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

    
    <xsl:variable name="thisDoc" select="."/>
    
    <!--Now get the external references errors...-->

    <xsl:variable name="currUri" select="document-uri(/)"/>
    <xsl:variable name="docId" select="substring-before(tokenize($currUri,'/')[last()],concat('.',$suffix))"/>
    <xsl:variable name="internalRefsFile" select="unparsed-text(concat($outputDir,'/',$docId,'.txt'))"/>
    <xsl:variable name="internalRefs" select="tokenize($internalRefsFile,$line.separator)"/>
    <xsl:variable name="localIds" select="tokenize(unparsed-text(concat($outputDir,'/',$docId,'_ids.txt')),$line.separator)"/>
    <xsl:variable name="documentRegex" select="'\.((xml)|(kml)|(html?)|(xsl),(rss))(#.+)?$'"/>
    <xsl:variable name="unparsedRegex" select="'\.((txt)|(md)|(css)|(js))$'"/>
    <xsl:variable name="systemFiles" select="tokenize($fileList,$line.separator)"/>    
    <xsl:variable name="systemFilesCount" select="count($systemFiles)"/>
    
    
    
    <xsl:template match="/">
        <xsl:message>Found <xsl:value-of select="count($internalRefs)"/></xsl:message>
        <xsl:variable name="result" as="xs:string*">
            <xsl:for-each-group select="$internalRefs" group-by="hcmc:getBaseUri(.)">
                <xsl:variable name="baseUri" select="current-grouping-key()"/>
                <xsl:message>Checking this uri: <xsl:value-of select="$baseUri"/></xsl:message>
                <xsl:variable name="groupItemsToCheck" select="for $n in current-group() return if (contains($n,'#')) then $n else ()"/>
                <xsl:choose>
                    <xsl:when test="hcmc:testAvailability($baseUri)">
                        <xsl:choose>
                            
                            <xsl:when test="not(empty($groupItemsToCheck))">
                                <xsl:message>Found fragments!</xsl:message>
                                <!--Now we need to find the index!-->
                                <xsl:variable name="thisDoc" select="unparsed-text(concat($outputDir,'/',$docId,'_ids.txt'))"/>
                                <xsl:variable name="thisDocIds" select="tokenize($thisDoc,$line.separator)"/>
                                <xsl:for-each select="$groupItemsToCheck">
                                    <xsl:variable name="thisSubUri" select="."/>
                                    <xsl:variable name="thisFrag" select="substring-after($thisSubUri,'#')"/>
                                    <xsl:message>checking this frag <xsl:value-of select="$thisFrag"/></xsl:message>
                                    <xsl:choose>
                                        <xsl:when test="$thisDocIds[.=$thisFrag]">
                                            <xsl:message>Frag found!</xsl:message>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <xsl:message>Fragment not found!</xsl:message>
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
       <xsl:result-document method="text">
           ## External Errors
           <xsl:sequence select="string-join($result,$line.separator)"/>
           
           ## Internal Errors
            <xsl:sequence select="unparsed-text(concat($outputDir,'/',$docId,'_internalErrors.txt'))"/>
       </xsl:result-document>
    </xsl:template>
    
    
    <xsl:function name="hcmc:getBaseUri" as="xs:string">
        <xsl:param name="uri"/>
        <xsl:value-of select="if (contains($uri,'#')) then substring-before($uri,'#') else $uri"/>
    </xsl:function>
    
    <xsl:function name="hcmc:testAvailability" as="xs:boolean">
        <xsl:param name="uri"/>
        <xsl:message>Testing availability of <xsl:value-of select="$uri"/></xsl:message>
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
        <xsl:message><xsl:value-of select="$result"/></xsl:message>
        
        
    </xsl:function>
  
    
</xsl:stylesheet>