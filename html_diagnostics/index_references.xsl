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
    <xsl:variable name="xmlDocs" select="collection(concat($outputTxtDir,'?select=*_refs.xml'))//ul"/>
    <xsl:variable name="references" select="$xmlDocs/descendant::li"/>
    <xsl:variable name="systemFilesXml" select="document(concat($outputDir,'/system_files.xml'))//ul"/>
    
    <xsl:key name="ref-to-doc" match="li" use="."/>
    <xsl:key name="ref-to-system" match="li" use="."/>
    <xsl:key name="hash-to-id" match="li" use="."/>
    
    <xsl:template match="/">
        <div>
            <h3>Reference Errors</h3>
            <xsl:for-each-group select="$references" group-by=".">
                <xsl:variable name="thisRef" select="current-grouping-key()"/>
                <xsl:variable name="theseDocs" select="current-group()"/>
                <xsl:variable name="thisBaseUri" select="hcmc:getBaseUri(.)"/>
                <xsl:message>Processing <xsl:value-of select="$thisRef"/>...</xsl:message>
                <xsl:choose>
                    <xsl:when test="$systemFilesXml//key('ref-to-system',$thisBaseUri)">
                        <xsl:choose>
                            <!--When it is a document with an id that we've indexed...-->
                            <xsl:when test="contains($thisRef,concat($suffix,'#'))">
                                <xsl:variable name="thisFrag" select="substring-after($thisRef,'#')"/>
                                <xsl:variable name="relativePath" select="substring-after($thisBaseUri,$projectDirectory)"/>
                                <xsl:variable name="thisFullOutputDir" select="substring-before(concat($outputTxtDir,$relativePath),concat('.',$suffix))"/>
                                <xsl:variable name="thisDocIdsFile" select="document(concat($thisFullOutputDir,'_ids.xml'))//ul"/>
                                <xsl:variable name="thisSubUri" select="substring-after($thisRef,'#')"/>
                                <xsl:choose>
                                    <xsl:when test="$thisDocIdsFile//key('hash-to-id',$thisSubUri)"/>
                                    <xsl:otherwise>
                                        <ul>
                                            <li><xsl:value-of select="$thisRef"/>
                                                <ul>
                                                    <xsl:for-each select="$theseDocs">
                                                        <xsl:variable name="dataDocVal" select="ancestor::ul/@data-doc"/>
                                                        <li><xsl:value-of select="$dataDocVal"/></li>
                                                    </xsl:for-each>
                                                </ul>
                                            </li>
                                        </ul>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <!--We have to let it through ohterwise-->
                            <xsl:otherwise/>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <ul>
                            <li><xsl:value-of select="$thisRef"/>
                            <ul>
                                <xsl:for-each select="$theseDocs">
                                    <xsl:variable name="dataDocVal" select="ancestor::ul/@data-doc"/>
                                    <li><xsl:value-of select="$dataDocVal"/></li>
                                </xsl:for-each>
                            </ul>
                            </li>
                        </ul>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each-group>
        </div>
    </xsl:template>

    
</xsl:stylesheet>