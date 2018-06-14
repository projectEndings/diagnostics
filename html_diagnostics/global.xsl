<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    exclude-result-prefixes="xs math"
    xmlns:xh="http://www.w3.org/1999/xhtml"
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
    
    <!--Current date-->
    <xsl:param name="currDate"/>
    
    <xsl:param name="useEE" select="false()"/>
    
    
    <!--DIRECTORIES-->
    
    <!--The base output dir-->
    <xsl:variable name="outputTxtDir" select="concat($outputDir,'/tmpLinksTxt')"/>
    
    <!--FILES-->
    
    <!--First simple lists-->
    <xsl:variable name="systemFilesTxt" select="unparsed-text(concat($outputDir,'/system_files.txt'))"/>
    <xsl:variable name="systemFilesPath" select="concat($outputDir,'/system_files.xml')"/>
    <xsl:variable name="systemFilesDoc" select="document($systemFilesPath)/xh:ul"/>
    
    <!--Index collections-->
    <xsl:variable name="refDocs" select="collection(concat($outputTxtDir,'?select=*_refs.xml&amp;recurse=yes'))"/>
    <xsl:variable name="idDocs" select="collection(concat($outputTxtDir,'?select=*_ids.xml&amp;recurse=yes'))"/>
    <xsl:variable name="internalRefsDocs" select="collection(concat($outputTxtDir,'?select=*_internalRefs.xml&amp;recurse=yes'))"/>
    
    
    <!--Error files-->
    <xsl:variable name="errorsPath" select="concat($outputDir,'/errors.xml')"/>
    <xsl:variable name="errorsDoc" select="document($errorsPath)"/>
    
    <xsl:variable name="internalErrorsPath" select="concat($outputDir,'/internalErrors.xml')"/>
    <xsl:variable name="internalErrorsDoc" select="document($internalErrorsPath)"/>
    

   
    
    
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

    
   
    <xsl:function name="hcmc:getBaseUri" as="xs:string">
        <xsl:param name="uri"/>
        <xsl:value-of select="if (contains($uri,'#')) then substring-before($uri,'#') else $uri"/>
    </xsl:function>
    
    <xsl:function name="hcmc:getRelativeUri" as="xs:string">
        <xsl:param name="uri"/>
        <xsl:value-of select="if (matches($uri,$projectDirectory)) then substring-after($uri,concat($projectDirectory,'/')) else $uri"/>
    </xsl:function>
    
    <xsl:function name="hcmc:getOutputUriNe" as="xs:string">
        <xsl:param name="uri"/>
        <xsl:value-of select="substring-before(concat($outputTxtDir,substring-after($uri,$projectDirectory)),concat('.',$suffix))"/>
    </xsl:function>
    
    <!--This function compares two sequences and returns all of $seq1
        that is not in $seq2-->
    <!--Thanks to this: http://www.xsltfunctions.com/xsl/functx_value-except.html-->
    <xsl:function name="hcmc:compareSeq" as="xs:string*">
        <xsl:param name="seq1"/>
        <xsl:param name="seq2"/>
        <xsl:sequence select="$seq1[not(.=$seq2)]"/>
    </xsl:function>
    
    
</xsl:stylesheet>