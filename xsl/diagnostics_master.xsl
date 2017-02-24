<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:xh="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="#all"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Started on:</xd:b> February 22, 2017</xd:p>
            <xd:p><xd:b>Authors:</xd:b> <xd:a href="http://mapoflondon.uvic.ca/TAKE1.htm">jtakeda</xd:a>
            and <a href="http://mapoflondon.uvic.ca/HOLM3.htm">mholmes</a>.</xd:p>
            <xd:p>
                This XSLT produces the necessary pages for the diagnostics report. It calls upon
                a statistics module and a diagnostics module.
            </xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:param name="projectDirectory"/>
    
<!--    Has to made relative since the xsl is being called from a subfolder.-->
    <xsl:variable name="relativeProjectDirectory" select="concat('../',$projectDirectory)"/>
    <xsl:variable name="projectCollection" select="collection(concat($projectDirectory,'?select=*.xml;recurse=yes'))"/>
    <xsl:variable name="teiDocs" select="$projectCollection//TEI"/>
    

    <xsl:variable name="urlRegex">^http(s)?://</xsl:variable>
    <xsl:key name="declaredIds" match="*/@xml:id" use="normalize-space(concat(hcmc:returnFileName(.),'#',.))"/>
<!--    <xsl:key name="refs" match="TEI//@target" use="tokenize(.,'\s+')"/>-->
    
    <xsl:template match="/">
        <xsl:message>TESTING</xsl:message>
        <xsl:result-document href="../test/results.html">
            <xsl:call-template name="generateStatistics"/>
            <xsl:call-template name="badInternalLinks"/>
        </xsl:result-document>
       
    </xsl:template>
    
    <xsl:template name="generateStatistics">
        <xd:desc>
            <xd:p>template: generateStatistics</xd:p>
            <xd:p>This template generates a number of statistics about a project. Statistics included:
<!--                List stats as they come up-->
            <xd:ul>
                <xd:li></xd:li>
                <xd:li></xd:li>
            </xd:ul>
            </xd:p>
        </xd:desc>
        <xsl:variable name="teiDocCount" select="count($teiDocs)"/>
        <xsl:variable name="teiDocsDeclaredIdsCount" select="count($teiDocs//*/@xml:id)"/>
        <xsl:message>
            TEI doc count: <xsl:value-of select="$teiDocCount"/>
            XML:ID count: <xsl:value-of select="$teiDocsDeclaredIdsCount"/>
        </xsl:message>
    </xsl:template>
    
    
    <xsl:template name="badInternalLinks">
        <xd:desc>
            <xd:p>template: badInternalLinks</xd:p>
            <xd:p>This template checks that all internal targets are pointing to a declared entity 
            declared somewhere in the project. It assumes that any locally declared targets are validated
            by tei_all.sch.</xd:p>
        </xd:desc>
<!--        <xsl:variable name="temp" as="xs:string*">-->
               <xsl:for-each select="$teiDocs[//@target][position() lt 70]">
                <xsl:variable name="thisDoc" select="."/>
                <xsl:variable name="thisDocId" select="@xml:id"/>
                <xsl:variable name="thisDocFileName" select="hcmc:returnFileName(.)"/>
                 <xsl:message>Checking <xsl:value-of select="$thisDocFileName"/> (<xsl:value-of select="position()"/>/<xsl:value-of select="count($teiDocs[//@target])"/>)</xsl:message>
                   <xsl:variable name="temp" as="element()*">
                       <xsl:for-each select="//@target">
                           <xsl:variable name="thisTarg" select="." as="attribute(target)"/>
                           <xsl:variable name="thisTargString" select="normalize-space($thisTarg)" as="xs:string"/>
                           <xsl:variable name="thisTargTokens" select="tokenize($thisTargString,'\s+')" as="xs:string+"/>
                           
                           <!--None of the target tokens should start with a hash,
                since they should be referenced in the file already
                and should already be checked by schematron.-->
                           <xsl:for-each select="$thisTargTokens[not(starts-with(.,'#'))][not(matches(.,$urlRegex))]">
                               <xsl:variable name="thisToken" select="normalize-space(.)" as="xs:string"/>
                               
                               <!--Since we're using the declaredIds key, we don't need to know
                the absolute path for the token, just the filename and hash. -->
                               
                               <xsl:variable name="pathlessToken" select="tokenize($thisToken,'/')[last()]"/>
                               <xsl:variable name="thisTokenAfterHash" 
                                   select="normalize-space(substring-after($pathlessToken,'#'))" as="xs:string"/>
                               <xsl:choose>
                                   <xsl:when test="$teiDocs//key('declaredIds',$pathlessToken)">
                                       <!-- <xsl:message>Found id for <xsl:value-of select="."/></xsl:message>-->
                                   </xsl:when>
                                   <xsl:otherwise>
                                      <ul><xsl:value-of select="."/></ul>
                                   </xsl:otherwise>
                               </xsl:choose>
                           </xsl:for-each>
                       </xsl:for-each>
                   </xsl:variable>
                <xsl:if test="count($temp) gt 0">
                    <div>
                        <head><xsl:value-of select="$thisDocFileName"/></head>
                        <xsl:sequence select="$temp"/>
                    </div>
                </xsl:if>
                </xsl:for-each>
           
               
      

    </xsl:template>
    
    <xsl:function name="hcmc:returnFileName" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:value-of select="normalize-space(tokenize(base-uri($node),'/')[last()])"/>
    </xsl:function>
    
    
</xsl:stylesheet>