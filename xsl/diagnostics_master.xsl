<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
            <xd:p><xd:b>Authors:</xd:b> <xd:a href="http://mapoflondon.uvic.ca/TAKE1.htm">jtakeda</xd:a> and <xd:a href="http://mapoflondon.uvic.ca/HOLM3.htm">mholmes</xd:a>.</xd:p>
            <xd:p> This XSLT produces the necessary pages for the diagnostics report. It calls upon
                a statistics module and a diagnostics module. </xd:p>
        </xd:desc>
        <xd:param name="projectDirectory">
            <xd:p>The directory that contains all of the XML documents to be analyzed.</xd:p>
        </xd:param>
        <xd:param name="outputDirectory">
            <xd:p>The directory where any products from this transformation should be placed.</xd:p>
        </xd:param>
        <xd:param name="currDate">
            <xd:p>The current date in W3C format (YYYY-MM-DD).</xd:p>
        </xd:param>
    </xd:doc>

    <xsl:output method="xhtml" encoding="UTF-8" normalization-form="NFC" exclude-result-prefixes="#all"
         omit-xml-declaration="yes" />

    <xsl:param name="projectDirectory"/>
    <xsl:param name="outputDirectory"/>
    <xsl:param name="currDate"/>

    <xd:doc scope="component">
        <xd:desc>We use the project directory to create a collection of all the 
        XML documents in it. We'll process all of those documents.</xd:desc>
    </xd:doc>
    <xsl:variable name="projectCollection"
        select="collection(concat('file:///', translate($projectDirectory, '\', '/'), '?select=*.xml;recurse=yes'))"/>
    <xsl:variable name="teiDocs" select="$projectCollection//TEI"/>

    <xd:doc scope="component">
        <xd:desc>Although we check all attributes, there are some that we absolutely
        must explicitly exclude because they're bound to look like links and are 
        definitely not.</xd:desc>
    </xd:doc>
    <xsl:variable name="excludedAtts" select="('matchPattern', 'replacementPattern')"/>
    
<!--    TODO: Create template for creating diagnostics checks divs, so that
    this document is easily expandable (following the model of Moses/MoEML diagnostics.-->

    <xd:doc scope="component">
        <xd:desc>This key indexes all @xml:id attributes that might be pointed at
        using a fully-expanded path to their container document followed by '#[id]'.
        When idrefs are encountered in documents, they too are fully expanded before
        being checked against the key. If there's no match in the key, presumably 
        the idref is wrong.</xd:desc>
    </xd:doc>
    <xsl:key name="declaredIds" match="*/@xml:id"
        use="normalize-space(concat(document-uri(root(.)), '#', .))"/>
    
    <xd:doc scope="component">
        <xd:desc>This key is used to index all prefixDefs in a project so that 
            their expansion regexes can be retrieved and used easily.
        </xd:desc>
    </xd:doc>
    <xsl:key name="prefixDefs" match="prefixDef" use="@ident"/>
    
    <xsl:template match="/">
        <xsl:message>Running diagnostics...</xsl:message>
        <xsl:result-document href="file:///{translate($outputDirectory, '\', '/')}/diagnostics.html">
            <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;
            </xsl:text>
            <html>
                <head>
                    <title>Diagnostics for project at <xsl:value-of select="$projectDirectory"/></title>
                    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
                    <xsl:copy-of select="$javascript"/>
                    <xsl:copy-of select="$css"/>
                </head>
                <body>
                    <h1>Diagnostics for project at <xsl:value-of select="$projectDirectory"/></h1>
                    <div>
                        <xsl:call-template name="generateStatistics"/>
                        <xsl:call-template name="generateDiagnosticChecks"/>
<!--                        <xsl:call-template name="badInternalLinks"/>-->
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <!--************** STATISTICS ********************-->
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="generateStatistics" type="template"/>
            <xd:p>template: generateStatistics</xd:p>
            <xd:p>This template generates a number of statistics about a project. Statistics included: <!--                List stats as they come up-->
                <xd:ul>
                    <xd:li/>
                    <xd:li/>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="generateStatistics">
        <xsl:variable name="teiDocCount" select="count($teiDocs)"/>
        <xsl:variable name="teiDocsDeclaredIdsCount" select="count($teiDocs//*/@xml:id)"/>
        <div>
            <h2>Statistics</h2>
            <table>
                <tbody>
                    <tr><td>TEI documents</td><td><xsl:value-of select="$teiDocCount"/></td></tr>
                    <tr><td>Declared xml:ids</td><td><xsl:value-of select="$teiDocsDeclaredIdsCount"/></td></tr>
                </tbody>
            </table>
        </div>
        <xsl:message>TEI doc count: <xsl:value-of select="$teiDocCount"/>&#x0a;@xml:id count: <xsl:value-of select="$teiDocsDeclaredIdsCount"/>
        </xsl:message>
    </xsl:template>
    
    
    <!--************** CONSISTENCY CHECKS ********************-->
    
    
    <xd:doc>
        <xd:desc>
            <xd:ref name="createDiagnosticsDiv" type="template"/>
            <xd:p>This template creates the XHTML5 div elements for the 
            diagnostics output.</xd:p>
        </xd:desc>
        <xd:param name="id">
            <xd:p>Gives a unique id to the div. If nothing is supplied,
            it generates an id.</xd:p>
        </xd:param>
        <xd:param name="title">
            <xd:p>This is the title and header for the div. Required.</xd:p>
        </xd:param>
        <xd:param name="explanation">
            <xd:p>A short, prose explanation of what each div contains.</xd:p>
        </xd:param>
        <xd:param name="results">
            <xd:p>The results of a consistency check (usually &lt;table&gt; or &lt;ul&gt;).</xd:p>
        </xd:param>
        <xd:param name="resultsCount">
            <xd:p>The count of the results of a check. Since the results can be 
            any container elements with any number of descendants, this count needs
            to be supplied as a parameter, not calculated within this template.</xd:p>
        </xd:param>
        <xd:return>
            <xd:p>An XHTML div element.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:template name="createDiagnosticsDiv" as="element(xh:div)">
        <xsl:param name="id"/>
        <xsl:param name="title"/>
        <xsl:param name="explanation"/>
        <xsl:param name="results" as="element()*"/>
        <xsl:param name="resultsCount" as="xs:integer"/>
<!--        REMINDER: @CLASS='SHOWING' TEMPORARILY;-->
        <div class="showing" data-count="{$resultsCount}" id="{$id}" data-title="{string-join($title,'')}">
            <h3 onclick="showHide(this)" class="{if ($resultsCount=0) then 'complete' else 'toDo'}"><xsl:copy-of select="$title"/> (<xsl:value-of select="$resultsCount"/>)</h3>
            <div id="{$id}Explanation">
                <h4>Explanation</h4>
                <div class="explanation">
                    <p><xsl:copy-of select="$explanation"/></p>
                </div>
            </div>
            <xsl:choose>
                <xsl:when test="$resultsCount gt 0">
                    <xsl:sequence select="$results"/>
                </xsl:when>
                <xsl:otherwise><p>None found.</p></xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="generateDiagnosticsChecks" type="template"/>
            <xd:p>template: generateDiagnosticsChecks</xd:p>
            <xd:p>This template generates the main body of the diagnostics document,
                calling all of the consistency checks. Templates called: <!--List as they come up; do we need to list them?-->
                <xd:ul>
                    <xd:li></xd:li>
                    <xd:li/>
                </xd:ul>
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="generateDiagnosticChecks">
        <div>
            <h2>Consistency Checks</h2>
            <xsl:call-template name="badInternalLinks"/>
        </div>
    </xsl:template>

    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="badInternalLinks" type="template"/>
            <xd:p>template: badInternalLinks</xd:p>
            <xd:p>This template checks that all internal targets are pointing to a declared entity
                declared somewhere in the project.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="badInternalLinks" as="element(xh:div)">
        <xsl:variable name="output" as="element(xh:ul)*">
            <xsl:for-each select="$teiDocs[descendant::*[@*]]">
                <xsl:variable name="thisDoc" select="."/>
                <xsl:variable name="thisDocUri" select="document-uri(root(.))"/>
    <!--    We can't assume documents have ids on their root elements.        -->
                <!--<xsl:variable name="thisDocId" select="@xml:id"/>-->
                <xsl:variable name="thisDocFileName" select="hcmc:returnFileName(.)"/>
                <xsl:message>Checking <xsl:value-of select="$thisDocFileName"/> (<xsl:value-of
                        select="position()"/>/<xsl:value-of select="count($teiDocs[//@target])"
                    />)</xsl:message>
                <xsl:variable name="temp" as="element()">
                    <ul>
                        <xsl:for-each select="//@*[not(local-name(.) = $excludedAtts)]">
                            <xsl:variable name="thisAtt" select="."/>
                            <xsl:variable name="thisAttString" select="normalize-space($thisAtt)"
                                as="xs:string"/>
                            <xsl:variable name="thisAttTokens" select="tokenize($thisAttString, '\s+')"
                                as="xs:string+"/>
    
                            <!--<xsl:variable name="itemsFound">-->
                                
                                <xsl:for-each select="$thisAttTokens">
                                    <!-- Is it a private URI scheme? We use the regex from the TEI 
                                         definition of teidata.prefix. If it is one, resolve it 
                                         before continuing. -->
                                    <xsl:variable name="thisToken" select="if (matches(., '^[a-z][a-z0-9\+\.\-]*:[^/]+')) then hcmc:resolvePrefixDef(., root($thisDoc)) else ." as="xs:string"/>
                                    
                                    <xsl:if test="hcmc:isLocalPointer($thisToken)">
                                        
                                        <!-- At this point we need to resolve private URI schemes. 
                                             Leave that aside for the moment. -->
                                        
            
                                        <!-- Filepaths are relative to the containing document, so all 
                                             filepaths need to be resolved in order to be checked. -->
                                        <xsl:variable name="targetDoc" select="
                                            if (matches($thisToken, '.+#'))
                                            then resolve-uri(substring-before($thisToken, '#'), $thisDocUri)
                                            else if (matches($thisToken, '^#'))
                                            then $thisDocUri else ''"/>
                                        
                                        <xsl:variable name="targetId" select="substring-after($thisToken, '#')"/>
                                        <xsl:variable name="fullTarget" select="concat($targetDoc, '#', $targetId)"/>
                
                                        <xsl:choose>
                                            <xsl:when test="$teiDocs//key('declaredIds', $fullTarget)">
                                                 <!--<xsl:message>Found id for <xsl:value-of select="."/></xsl:message>-->
                                            </xsl:when>
                                            <xsl:when test="doc-available($fullTarget)">
                                                <!--<xsl:message>Found document for target.</xsl:message>-->
                                            </xsl:when>
                                            <xsl:otherwise>
                                                <li><span class="xmlAttName"><xsl:value-of select="local-name($thisAtt)"/></span>: 
                                                    <span class="xmlAttVal"><xsl:value-of select="."/></span>
                                                </li>
                                            </xsl:otherwise>
                                        </xsl:choose>
                                    </xsl:if>
                                    
                                </xsl:for-each>
                            <!--</xsl:variable>-->
                           <!-- <xsl:if test="$itemsFound//*:li">
                                <ul>
                                    <xsl:sequence select="$itemsFound"/>
                                </ul>
                            </xsl:if>-->
                        </xsl:for-each>
                    </ul>
                </xsl:variable>
                
                <xsl:if test="$temp//*:li">
                    <ul>
                        <li><xsl:value-of select="$thisDocFileName"/>
                            <xsl:sequence select="$temp"/>
                        </li>
                    </ul>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>
<!--        Now create the output div.-->
 <!--       <xsl:if test="$output//*:ul">-->
        <xsl:call-template name="createDiagnosticsDiv">
            <xsl:with-param name="id" select="'badInternalLinks'"/>
            <xsl:with-param name="explanation"
                select="'These are links in the project to entities within
                the projects that do not seem to exist.'"/>
            <xsl:with-param name="title" select="'Bad Internal Links'"/>
            <xsl:with-param name="results" select="$output"/>
            <xsl:with-param name="resultsCount"
                select="count($output//xh:li[ancestor::xh:li])"/>
        </xsl:call-template>
  <!--          <div>
                <h3>Links within the project to targets which 
                    don't seem to exist</h3>
                <xsl:sequence select="$output"/>
            </div>-->
        <!--</xsl:if>-->
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="hcmc:isLocalPointer" type="function"/>
            <xd:p>This function takes a string input and tries to determine
        whether it's the sort of internal reference link that we want to check.
        We do this because we cannot easily determine what kinds of attribute 
        values can or should contain pointers.</xd:p>
        </xd:desc>
        <xd:param name="token">
            <xd:p>A string input.</xd:p>
        </xd:param>
        <xd:return>
            <xd:p>A boolean value in reference to whether or not
            the string refers to a local pointer.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:function name="hcmc:isLocalPointer" as="xs:boolean">
        <xsl:param as="xs:string" name="token"/>
        <xsl:choose>
<!-- Exclude external schemes first. Crude but I think it should work.-->
            <xsl:when test="matches($token, '^[A-Za-z][A-Za-z\d\.\+\-]+://')">
                <xsl:value-of select="false()"/>
            </xsl:when>
<!-- Is it a direct link to a document? We assume that a document has
     an extension of up to six characters. -->
            <xsl:when test="matches($token, '[^\.]+\.[^\.]{1,6}$')">
                <xsl:value-of select="true()"/>
            </xsl:when>
<!-- Does it end with a hash followed by a QName? Regex is based on XML Schema
                XML Character Classes \i and \c. -->
            <xsl:when test="matches($token, '#\i\c*')">
                <xsl:value-of select="true()"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="false()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="hcmc:resolvePrefixDef" type="function"/>
            <xd:p>This function tries to look up a prefixDef by 
            prefix for the apparent prefix component of a pointer;
            if it finds a prefixDef, it does the replacement, but
            otherwise it returns the string unchanged.</xd:p>
        </xd:desc>
        <xd:param name="token">
            <xd:p>A referencing token with a private URI.</xd:p>
        </xd:param>
        <xd:return>
            <xd:p>If the private URI for the token can be resolved,
            then return the resolved token. Otherwise, do nothing
            to the token and return it.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:function name="hcmc:resolvePrefixDef" as="xs:string">
        <xsl:param name="token" as="xs:string"/>
        <xsl:param name="sourceDoc" as="document-node()"/>
        <xsl:variable name="prefix" select="substring-before($token, ':')"/>
<!--    Search for a prefixDef in the source document first, but if not found them look elsewhere.   -->
        <xsl:variable name="localPrefixDef" select="$sourceDoc/key('prefixDefs', $prefix)"/>
        <xsl:variable name="prefixDef" select="if ($localPrefixDef/@matchPattern) then $localPrefixDef else $teiDocs//key('prefixDefs', $prefix)"/>
        <xsl:choose>
            <xsl:when test="$prefixDef">
                <!--<xsl:message>prefixDef: <xsl:value-of select="concat($prefixDef[1]/@ident, ', ', $prefixDef[1]/@matchPattern, ', ', $prefixDef[1]/@replacementPattern)"/></xsl:message>-->
                <xsl:value-of select="replace(substring-after($token, ':'), $prefixDef[@matchPattern][1]/@matchPattern, $prefixDef[@matchPattern][1]/@replacementPattern)"/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$token"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="hcmc:returnFileName" type="function"/>
            <xd:p>Takes in any node and returns the root file name
            without the path.</xd:p>
        </xd:desc>
        <xd:param name="node">
            <xd:p>Any node.</xd:p>
        </xd:param>
        <xd:return>
            <xd:p>The filename as a string.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:function name="hcmc:returnFileName" as="xs:string">
        <xsl:param name="node" as="node()"/>
        <xsl:value-of select="normalize-space(tokenize(base-uri($node), '/')[last()])"/>
    </xsl:function>
    
    
<!--    HTML HEADER VARIABLES (TAKEN FROM THE MAP OF EARLY MODERN LONDON)-->
<!--    Joey to Martin: Should we have a globals module for these sorts of things?
        Martin to Joey: I think we should store these in external CSS and JS 
        files and pull them in with unparsed-text(). That will make it easier
        for people to modify them.
        Joey to Martin: Good call. I've commented out the CDATAs since they
        were breaking the Javascript in the output.
    
    -->
    
    <xsl:variable name="javascript">
        <script type="text/javascript" xmlns="http://www.w3.org/1999/xhtml">
<!--            These CDATAs seem to break the javascript in the XHTML5 output.-->
          <!--<xsl:text>&lt;![CDATA[</xsl:text>-->
            <xsl:value-of select="unparsed-text('script.js')"/>
         <!-- <xsl:text>]]&gt;</xsl:text>-->
        </script>
    </xsl:variable>
    
<!-- We should store this externally and pull it in with unparsed-text().   -->
    <xsl:variable name="css">
        <style type="text/css" xmlns="http://www.w3.org/1999/xhtml">
          <xsl:comment>
            <xsl:value-of select="unparsed-text('style.css')"/>
          </xsl:comment>
        </style>
    </xsl:variable>


</xsl:stylesheet>
