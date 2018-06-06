<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xpath-default-namespace="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    xmlns:xh="http://www.w3.org/1999/xhtml"
    xmlns="http://www.w3.org/1999/xhtml"
    version="2.0">
    <xsl:include href="global.xsl"/>
    
    <xsl:output method="xml"/>
    
    <!--A parameter-->
    <xsl:param name="groupByDoc" select="false()"/>
    
    <xsl:variable name="xmlDocs" select="collection(concat($outputTxtDir,'?select=*_refs.xml'))"/>
    <xsl:variable name="errorXmlDoc" select="document(concat($outputDir,'/','errors.xml'))"/>
    <xsl:variable name="internalErrorXmlDoc" select="document(concat($outputDir,'/','internalErrors.xml'))"/>
    <xsl:variable name="systemFilesXml" select="document(concat($outputDir,'/system_files.xml'))//ul"/>

    
    <xsl:variable name="externalErrorDocs" select="distinct-values($errorXmlDoc//ul/lu/ul/li/text())"/>
    <xsl:variable name="internalErrorDocs" select="distinct-values($internalErrorXmlDoc//ul[not(ancestor::ul)]/li/text())"/>
    
    <xsl:variable name="internalOnly" select="hcmc:compareSeq($internalErrorDocs,$externalErrorDocs)"/>
    
    <xsl:key name="doc-to-externalError" match="div/ul/li" use="ul/li/normalize-space(text())"/>
    <xsl:key name="doc-to-internalError" match="div/ul/li" use="normalize-space(text())"/>
    
    
    
    <xsl:template match="/">
        
        <html>
            <head>
                <title>HTML Diagnostics</title>
                <link rel="stylesheet" type="text/css" href="https://cdn.rawgit.com/projectEndings/diagnostics/master/xsl/style.css"/>
            </head>
            <body>
                <div>
                    <h1>HTML Diagnostics for <xsl:value-of select="$projectDirectory"/></h1>
                    <div id="stats">
                        <h2>Statistics</h2>
                        <table>
                            <tbody>
                                <tr>
                                    <td>Total documents analyzed:</td>
                                    <td><xsl:value-of select="count($xmlDocs)"/></td>
                                </tr>
                                <tr>
                                    <td>Documents in project:</td>
                                    <td><xsl:value-of select="count($systemFilesXml//li)"/></td>
                                </tr>
                                <tr>
                                    <td>Total unique external errors found:</td>
                                    <td><xsl:value-of select="count($errorXmlDoc//div/ul/li)"/></td>
                                </tr>
                                <tr>
                                    <td>Total internal errors found:</td>
                                    <td><xsl:value-of select="count($internalErrorXmlDoc//div/ul/li/ul/li)"/></td>
                                </tr>
                            </tbody>
                        </table>
                    </div>
                    <xsl:choose>
                        <xsl:when test="$groupByDoc">
                            <xsl:for-each-group select="$errorXmlDoc//div/ul/li" group-by="ul/li">
                                <xsl:variable name="thisDocName" select="current-grouping-key()"/>
                                <xsl:variable name="currGroup" select="current-group()"/>
                                <xsl:variable name="internalErrors" select="$internalErrorXmlDoc//key('doc-to-internalError',$thisDocName)"/>
                                <xsl:message>Processing <xsl:value-of select="$thisDocName"/>...</xsl:message> 
                                <div>
                                    <h3><xsl:value-of select="hcmc:getRelativeUri(current-grouping-key())"/></h3>
                                    <div>
                                        <h4>External Errors</h4>
                                        <ul>
                                            <xsl:for-each select="$currGroup">
                                                <li><xsl:value-of select="hcmc:getRelativeUri(text())"/></li>
                                            </xsl:for-each>
                                        </ul>
                                    </div>
                                    <xsl:if test="not(empty($internalErrors))">
                                        <div>
                                            <h4>Internal Errors</h4>
                                            <xsl:for-each select="$internalErrors/ul/li">
                                                <li><xsl:value-of select="text()"/></li>
                                            </xsl:for-each>
                                        </div>
                                    </xsl:if>
                                </div>
                            </xsl:for-each-group>
                            <!--Now we need to get all the documents that are not in the internal, but not the external-->
                            <xsl:for-each select="$internalOnly">
                                <xsl:variable name="thisInternalDoc" select="."/>
                                <div>
                                    <h3><xsl:value-of select="hcmc:getRelativeUri($thisInternalDoc)"/></h3>
                                    <xsl:for-each select="$internalErrorXmlDoc//key('doc-to-internalError',$thisInternalDoc)/ul/li">
                                        <li><xsl:value-of select="text()"/></li>
                                    </xsl:for-each>
                                </div>
                            </xsl:for-each>
                        </xsl:when>
                        <xsl:otherwise>
                            <div>
                                <xsl:apply-templates select="$errorXmlDoc | $internalErrorXmlDoc" mode="output"/>
                            </div>
                        </xsl:otherwise>
                    </xsl:choose>
                </div>
            </body>
        </html>
    </xsl:template>
    
    
    
    <xsl:template match="ul/text() | li/text()" mode="output">
        <xsl:value-of select="hcmc:getRelativeUri(.)"/>
    </xsl:template>
    
    <xsl:template match="node()" priority="-1" mode="output">
        <xsl:copy>
            <xsl:apply-templates select="node()" mode="#current"/>
        </xsl:copy>
    </xsl:template>
    
    
</xsl:stylesheet>