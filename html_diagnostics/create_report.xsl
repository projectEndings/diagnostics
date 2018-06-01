<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xh="http://www.w3.org/1999/xhtml"
    version="2.0">
    <xsl:include href="global.xsl"/>
    
    
    <xsl:output method="html"/>
    <xsl:variable name="filenames" select="tokenize(unparsed-text($docsToProcess),$line.separator)"/>
    <xsl:variable name="css">
        <style type="text/css" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:comment>
            <xsl:value-of select="unparsed-text('../diagnostics/xsl/style.css')"/>
          </xsl:comment>
        </style>
    </xsl:variable>
   
    <xsl:template match="/">
            <html>
                <head>
                    <title>Diagnostics for project at <xsl:value-of select="$projectDirectory"/></title>
                    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
                    <xsl:copy-of select="$css"/>
                </head>
                <body>
                    <div>
                        <h2>Broken Links</h2>
                        <xsl:variable name="errors">
                            <xsl:for-each select="$filenames">
                                <xsl:variable name="thisFn" select="."/>
                             
                                <!--A small more relative path-->
                                <xsl:variable name="thisFnPath" select="substring-after($thisFn,$projectDirectory)"/>
                                <xsl:variable name="thisFileLoc" select="substring-before($thisFnPath,concat('.',$suffix))"/>
                                <xsl:message>This filename: <xsl:value-of select="$thisFn"/></xsl:message>
                                <xsl:message>This file path: <xsl:value-of select="$thisFnPath"/></xsl:message>
                                <xsl:message>This File Loc <xsl:value-of select="$thisFileLoc"/></xsl:message>
                                <xsl:variable name="internalErrors" select="hcmc:lineTokenize(hcmc:getText(concat($outputTxtDir,$thisFileLoc,'_internalErrors.txt')))"/>
                                <xsl:variable name="refErrors" select="hcmc:lineTokenize(hcmc:getText(concat($outputTxtDir,$thisFileLoc,'_refErrors.txt')))"/>
                                <xsl:variable name="internalErrorsCount" select="count($internalErrors)"/>
                                <xsl:variable name="refErrorsCount" select="count($refErrors)"/>
                                <xsl:if test="$refErrorsCount + $internalErrorsCount gt 0">
                                    <div>
                                        <h3><xsl:value-of select="$thisFn"/></h3>
                                        <xsl:if test="$refErrorsCount gt 0">
                                            <div>
                                                <h3>Ref Errors (<xsl:value-of select="$refErrorsCount"/>)</h3>
                                                <ul>
                                                    <xsl:for-each select="$refErrors">
                                                        
                                                        <li><xsl:value-of select="substring-after(normalize-space(.),concat($projectDirectory,'/'))"/></li>
                                                    </xsl:for-each>
                                                </ul>
                                            </div>
                                        </xsl:if>
                                        <xsl:if test="$internalErrorsCount gt 0">
                                            <div>
                                                <h3>Internal Errors (<xsl:value-of select="$internalErrorsCount"/>)</h3>
                                                <ul>
                                                    <xsl:for-each select="$internalErrors">
                                                        <li><xsl:value-of select="."/></li>
                                                    </xsl:for-each>
                                                </ul>
                                            </div>
                                        </xsl:if>
                                    </div>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        <xsl:variable name="distinct" select="distinct-values($errors//xh:li/xs:string(.))"/>
                            
                        
                        <xsl:message>Found <xsl:value-of select="count($errors//xh:li)"/> errors in <xsl:value-of select="count($filenames)"/> files.</xsl:message>
                        <xsl:message><xsl:value-of select="count(distinct-values($errors//xh:li/xs:string(.)))"/> are distinct errors.</xsl:message>
                        
                        <xsl:sequence select="$errors"/>
                        
                    </div>
                </body>
            </html>
        
    </xsl:template>
    
</xsl:stylesheet>