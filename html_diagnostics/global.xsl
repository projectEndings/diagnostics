<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">
    
    
    <!--Parameters that have to be on every build-->
    
    <!--Should be seomthing like /Users/my/files/project/-->
    <xsl:param name="projectDirectory"/>
    
    <!--Should be something like .htm or .html-->
    <xsl:param name="suffix"/>
    
    <!--Should be a path to all of the files in the project-->
    <xsl:param name="fileList"/>
    
    <!--Should be \n or something-->
    <xsl:param name="line.separator"/>
    
    <!--Should be a path to all of the unique refs-->
    <xsl:param name="uniques"/>
    
    <!--Should be a path to the output, which is something like:
        Users/my/files/project/diagnostics-->
    <xsl:param name="outputDir"/>
    
    <!--And the list of docs to process-->
    <xsl:param name="docsToProcess"/>
    
    
    <xsl:variable name="outputTxtDir" select="concat($outputDir,'/tmpLinksTxt')"/>
    
    <!--Current date-->
    <xsl:param name="currDate"/>
    <!--Doc-->
    <xsl:variable name="thisDoc" select="."/>
    
    <!--Doc uri-->
    <xsl:variable name="thisDocUri" select="document-uri(.)"/>
    
    <!--A small more relative path-->
    <xsl:variable name="thisDocPath" select="substring-after($thisDocUri,$projectDirectory)"/>
    
    <!--Where my doc is-->
    <xsl:variable name="thisDocLoc" select="substring-before($thisDocPath,concat('.',$suffix))"/>
    
    <!--The document id-->
    <xsl:variable name="thisDocId" select="tokenize($thisDocLoc,'/')[last()]"/>
    
    <xsl:variable name="fullOutputDir" select="concat($outputTxtDir,$thisDocLoc)"/>
    
    <!--Where the refs document lives-->
    <xsl:variable name="thisDocRefsPath" select="concat($outputTxtDir,$thisDocLoc,'_refs.txt')"/>
    
    <!--Now the text-->
    <xsl:variable name="thisDocRefsFile" select="hcmc:getText($thisDocRefsPath)"/>
    
    <!--And the tokens-->
    <xsl:variable name="thisDocRefs" select="hcmc:lineTokenize($thisDocRefsFile)" as="xs:string*"/>
    
    <!--And the ids document-->
    <xsl:variable name="thisDocIdsPath" select="concat($outputTxtDir,$thisDocLoc,'_ids.txt')"/>
    
    <!--The document-->
    <xsl:variable name="thisDocIdsFile" select="hcmc:getText($thisDocIdsPath)"/>
    
    <!--And the lines-->
    <xsl:variable name="thisDocIds" select="hcmc:lineTokenize($thisDocIdsFile)"/>
    
    <!--Where the refs document lives-->
    <xsl:variable name="thisDocInternalRefsPath" select="concat($outputTxtDir,$thisDocLoc,'_internalRefs.txt')"/>
    
    <!--Now the text-->
    <xsl:variable name="thisDocInternalRefsFile" select="hcmc:getText($thisDocInternalRefsPath)"/>
    
    <!--And the tokens-->
    <xsl:variable name="thisDocInternalRefs" select="hcmc:lineTokenize($thisDocInternalRefsFile)" as="xs:string*"/>
    
    <!--Where the errors document lives-->
    <xsl:variable name="siteErrorsFile" select="unparsed-text(concat($outputDir,'/errors.txt'))"/>
    
    <!--And those errors-->
    <xsl:variable name="siteErrors" select="hcmc:lineTokenize($siteErrorsFile)"/>
    
    <!--The files-->
    <xsl:variable name="systemFilesDoc" select="hcmc:getText($fileList)"/> 
    
    <!--The lines-->
    <xsl:variable name="systemFiles" select="hcmc:lineTokenize($systemFilesDoc)"/>
    
    <!--Count-->
    <xsl:variable name="systemFilesCount" select="count($systemFiles)"/>
    
    <!--Unique refs-->
    <xsl:variable name="uniqueRefs" select="hcmc:lineTokenize(hcmc:getText($uniques))[not(.='')]" as="xs:string*"/>
    
    <!--Count-->
    <xsl:variable name="uniqueRefsCount" select="count($uniqueRefs)"/>

    
    <xsl:function name="hcmc:cleanUri">
        <xsl:param name="string"/>
        <xsl:choose>
            <xsl:when test="contains($string,'?')">
                <xsl:value-of select="substring-before($string,'?')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$string"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="hcmc:getText">
        <xsl:param name="uri"/>
        <!--<xsl:message>Looking for this URI <xsl:value-of select="$uri"/></xsl:message>-->
        <xsl:value-of select="if (unparsed-text-available($uri)) then unparsed-text($uri) else ()"/>
    </xsl:function>
    
    <xsl:function name="hcmc:lineTokenize" as="xs:string*">
        <xsl:param name="str"/>
        <xsl:sequence select="tokenize($str,$line.separator)"/>
    </xsl:function>

    
    <xsl:function name="hcmc:testAvailability" as="xs:boolean">
        <xsl:param name="uri"/>
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
    </xsl:function>
    
    <xsl:function name="hcmc:getBaseUri" as="xs:string">
        <xsl:param name="uri"/>
        <xsl:value-of select="if (contains($uri,'#')) then substring-before($uri,'#') else $uri"/>
    </xsl:function>
    
    
    
</xsl:stylesheet>