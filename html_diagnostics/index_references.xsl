<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xmlns="http://www.w3.org/1999/xhtml"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">
    <xsl:include href="global.xsl"/>
    <xsl:output method="xml"/>
    
    <xsl:variable name="references" select="$refDocs/descendant::li"/>
    <xsl:variable name="processedDocs" select="$refDocs//@data-doc"/>
    <xsl:variable name="distinctGroupsCount" select="count(distinct-values(for $n in $references return hcmc:getBaseUri($n)))"/>
    
    <xsl:key name="ref-to-doc" match="ul" use="@data-doc"/>
    <xsl:key name="ref-to-system" match="li" use="."/>
    <xsl:key name="hash-to-id" match="li" use="."/>
    
    
    <xsl:template match="/">
        <div>
            <h3>Reference Errors</h3>
            <xsl:for-each-group select="$references" group-by="hcmc:getBaseUri(.)">
                <xsl:variable name="thisBaseUri" select="current-grouping-key()"/>
                <xsl:variable name="currRefs" select="current-group()"/>
                <!--Booleans-->
                <xsl:variable name="alreadyProcessed" select="not(empty($refDocs/key('ref-to-doc',$thisBaseUri)))" as="xs:boolean"/>
                <xsl:variable name="exists" select="not(empty($systemFilesDoc/key('ref-to-system',$thisBaseUri)))" as="xs:boolean"/>
                <xsl:message>Checking references to this <xsl:value-of select="$thisBaseUri"/> (<xsl:value-of select="position()"/>/<xsl:value-of select="$distinctGroupsCount"/>)</xsl:message>
                <xsl:choose>
                    <!--We expidite this slightly by seeing if we've already processed the document (i.e. there's a @data-doc)-->
                    <xsl:when test="$alreadyProcessed">
                        <!--If that's true, then go ahead and check the internal refs-->
                        <xsl:copy-of select="hcmc:checkInternalRefs($thisBaseUri, $currRefs)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <!--If we haven't already processed it, then ...-->
                        <xsl:choose>
                            <!--Do another check-->
                            <xsl:when test="$exists">
                                <!--Does it exist in the file system?-->
                                <xsl:copy-of select="hcmc:checkInternalRefs($thisBaseUri, $currRefs)"/>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:copy-of select="hcmc:outputErrors($thisBaseUri, $currRefs)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </div>
    </xsl:template>
    
    <xsl:function name="hcmc:checkInternalRefs">
        <xsl:param name="thisRef"/>
        <xsl:param name="theseDocs"/>
        <!--TheseDocs is a variable comprised of <li> tags that have ancestor <ul>s with a @data-doc pointing tot heir context-->
        
        <!--Hash refs is the subset of documents that have hashes.-->
        <xsl:variable name="hashRefs" select="for $n in $theseDocs return if (contains($n,concat($suffix,'#'))) then $n else ()"/>
        <xsl:if test="not(empty($hashRefs))">
            <xsl:variable name="thisDocIdsFile" select="$idDocs/ul[@data-doc=$thisRef]" as="element()"/>
            
            <!--Now check the groups of hashrefs, so if there are three of them
                A.html#blah
                A.html#blah
                A.html#blorp
                
                Then you'd have
                A.html#blah [group with 2 members]
                A.html#blorp [group with 1 member]
                -->
            <xsl:for-each-group select="$hashRefs" group-by="substring-after(.,'#')">
                <!--These pointers are all the pointers with this hash-->
                <xsl:variable name="thesePtrs" select="current-group()"/>
                <!--This has ref is the current grouping key, aka the frag identifier-->
                <xsl:variable name="thisHashRef" select="current-grouping-key()"/>
                
                <!--This is just the string value-->
                <xsl:variable name="thisRef" select="$thesePtrs[1]"/>
                <!--If that frag exists-->
                <xsl:variable name="fragExists" select="not(empty($thisDocIdsFile[li/text()=$thisHashRef]))" as="xs:boolean"/>
                 <xsl:choose>
                    <xsl:when test="$fragExists"/>
                    <xsl:otherwise>
                        <!--Otherwise, send the reference (i.e. the string value) with the current group-->
                        <xsl:copy-of select="hcmc:outputErrors($thisRef,$thesePtrs)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="hcmc:outputErrors">
        <xsl:param name="thisRef"/>
        <xsl:param name="theseDocs"/>
        <xsl:message>Found error: <xsl:value-of select="$thisRef"/></xsl:message>
        <ul>
            <li><xsl:value-of select="$thisRef"/>
                <ul>
                    <xsl:message>In these documents:</xsl:message>
                    <xsl:for-each-group select="$theseDocs" group-by="ancestor::ul/@data-doc">
                        <xsl:variable name="docVal" select="current-grouping-key()"/>
                        <li><xsl:value-of select="$docVal"/></li>
                        <xsl:message>* <xsl:value-of select="$docVal"/></xsl:message>
                    </xsl:for-each-group>
                </ul>
            </li>
        </ul>
    </xsl:function>
               
    

    
</xsl:stylesheet>