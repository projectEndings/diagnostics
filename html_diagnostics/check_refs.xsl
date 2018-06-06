<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">
    <xsl:include href="global.xsl"/>
    
    <xsl:output method="text"/>
    <xsl:key name="string-to-error" match="*:file" use="."/>
    <xsl:variable name="systemFilesXml" select="document(concat($outputDir,'/systemFiles.xml'))"/>
    <xsl:template match="/">
      
        <xsl:message>Checking all unique pointers...</xsl:message>
        <xsl:variable name="hashedRefs" select="$uniqueRefs[contains(.,'#')]"/>
        <xsl:variable name="baseUris" select="distinct-values(for $n in $uniqueRefs return hcmc:getBaseUri($n))"/>
        <xsl:variable name="docErrors" as="xs:string*">
            <xsl:for-each select="$baseUris">
                <xsl:variable name="thisBaseUri" select="normalize-space(substring-after(.,'file:'))"/>
                <xsl:choose>
                    <xsl:when test="$systemFilesXml//key('string-to-error',$thisBaseUri)"/>
                    <xsl:otherwise>
                        <xsl:value-of select="."/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:message>
            <xsl:for-each select="$docErrors">
                ERROR: <xsl:value-of select="."/>
            </xsl:for-each>
        </xsl:message>
        
        <!--<xsl:message>Here is the count of files that we should be checking: <xsl:value-of select="count($filesToCheck)"/></xsl:message>-->
        <!--Okay, first do the easy ones-->

<!--        <xsl:variable name="docErrors" select="hcmc:compareSeq($baseUris,$systemFiles)" as="xs:string*"/>-->
        <xsl:variable name="docErrorsCount" select="count($docErrors)"/>
        <xsl:variable name="docErrorsOut" as="xs:string">
            <xsl:sequence select="string-join(for $n in $docErrors return normalize-space($n),$line.separator)"/>
        </xsl:variable>
      <!--    <xsl:variable name="out" as="xs:string*">
      <xsl:if test="not(empty($docErrors))">
                <xsl:message><xsl:sequence select="$docErrorsOut"/></xsl:message>
               <xsl:sequence select="$docErrorsOut"/>
                <xsl:for-each-group select="$hashedRefs" group-by="hcmc:getBaseUri(.)">
                    <xsl:variable name="baseUri" select="current-grouping-key()"/>
                    <xsl:variable name="currPos" select="position()"/>
                    <xsl:variable name="thisDocId" select="substring-before(tokenize($baseUri,'/')[last()],'.')"/>
                    <xsl:variable name="groupItemsToCheck" select="for $n in current-group() return if (contains($n,'#')) then $n else ()"/>
                    <xsl:choose>
                        <xsl:when test="empty($docErrors[.=$baseUri])">
                            <!-\- <xsl:message>Checking this uri: <xsl:value-of select="$baseUri"/></xsl:message>-\->

                            <!-\-Get the path after the project dir (i.e. my/project/this/file.html becomes /this/file.html)-\->
                            <xsl:variable name="relativePath" select="substring-after($baseUri,$projectDirectory)"/>
                            <!-\-Now add the outputTxtDir path and get rid of the suffix (i.e. /this/file.html becomes my/project/this/outputDir/txt/this/file)-\->
                            <xsl:variable name="fullOutputDir" select="substring-before(concat($outputTxtDir,$relativePath),concat('.',$suffix))"/>
                            <xsl:variable name="thisDocIdsFile" select="unparsed-text(concat($fullOutputDir,'_ids.txt'))"/>
                            <xsl:variable name="thisDocIds" select="tokenize($thisDocIdsFile,$line.separator)"/>
                            
                            <xsl:for-each select="$groupItemsToCheck">
                                <xsl:variable name="thisSubUri" select="."/>
                                <xsl:variable name="thisFrag" select="substring-after($thisSubUri,'#')"/>
                                <!-\-  <xsl:message>checking this frag <xsl:value-of select="$thisFrag"/></xsl:message>-\->
                                <xsl:choose>
                                    <xsl:when test="$thisDocIds[.=$thisFrag]">
                                        <!-\-    <xsl:message>Frag found!</xsl:message>-\->
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:message>Could not find URI: <xsl:value-of select="$thisSubUri"/></xsl:message>
                                        <xsl:value-of select="$thisSubUri"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                            
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence select="string-join(for $n in $groupItemsToCheck return normalize-space($n),$line.separator)"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:for-each-group>
                
                <!-\- <xsl:for-each-group select="$uniqueRefs" group-by="hcmc:getBaseUri(.)">
                <xsl:variable name="baseUri" select="current-grouping-key()"/>
                <xsl:variable name="currPos" select="position()"/>
                <xsl:message>Checking <xsl:value-of select="$currPos"/>/<xsl:value-of select="$uniqueRefsCount"/></xsl:message>
               <!-\\- <xsl:message>Checking this uri: <xsl:value-of select="$baseUri"/></xsl:message>-\\->
                <xsl:variable name="thisDocId" select="substring-before(tokenize($baseUri,'/')[last()],'.')"/>
                <xsl:variable name="groupItemsToCheck" select="for $n in current-group() return if (contains($n,'#')) then $n else ()"/>
                <xsl:choose>
                    <xsl:when test="hcmc:testAvailability($baseUri)">
                        <xsl:if test="not(empty($groupItemsToCheck))">
                            
                            <!-\\-Get the path after the project dir (i.e. my/project/this/file.html becomes /this/file.html)-\\->
                            <xsl:variable name="relativePath" select="substring-after($baseUri,$projectDirectory)"/>
                            
                            <!-\\-Now add the outputTxtDir path and get rid of the suffix (i.e. /this/file.html becomes my/project/this/outputDir/txt/this/file)-\\->
                            <xsl:variable name="fullOutputDir" select="substring-before(concat($outputTxtDir,$relativePath),concat('.',$suffix))"/>

                            <xsl:variable name="thisDocIdsFile" select="unparsed-text(concat($fullOutputDir,'_ids.txt'))"/>
                            <xsl:variable name="thisDocIds" select="tokenize($thisDocIdsFile,$line.separator)"/>
                            <xsl:for-each select="$groupItemsToCheck">
                                <xsl:variable name="thisSubUri" select="."/>
                                <xsl:variable name="thisFrag" select="substring-after($thisSubUri,'#')"/>
                                <!-\\-  <xsl:message>checking this frag <xsl:value-of select="$thisFrag"/></xsl:message>-\\->
                                <xsl:choose>
                                    <xsl:when test="$thisDocIds[.=$thisFrag]">
                                        <!-\\-    <xsl:message>Frag found!</xsl:message>-\\->
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
            </xsl:for-each-group>-\->
            
        </xsl:if>
        </xsl:variable>
        
        
        <!-\-<xsl:variable name="uniqueRefsCount" select="count(distinct-values(for $n in $uniqueRefs return hcmc:getBaseUri($n)))"/>-\->
        <!-\-fn:distinct-values($seq1[fn:not(.=$seq2)])-\->
       
        
        <xsl:if test="not(empty($out))">
            <xsl:value-of select="string-join($out,$line.separator)"/>
        </xsl:if>
        
       -->
    </xsl:template>

</xsl:stylesheet>