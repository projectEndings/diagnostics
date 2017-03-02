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
        select="collection(concat($projectDirectory, '?select=*.xml;recurse=yes'))"/>
    <xsl:variable name="teiDocs" select="$projectCollection//TEI"/>

    <!--    TODO: This URL regex will need be a bit more sophisticated to capture everything.
    This is just a placeholder for now.-->
    
<!--    TODO: Create template for creating diagnostics checks divs, so that
    this document is easily expandable (following the model of Moses/MoEML diagnostics.-->

    <xsl:variable name="urlRegex">^https?://</xsl:variable>


    <!--<xsl:key name="declaredIds" match="*/@xml:id"
        use="normalize-space(concat(hcmc:returnFileName(.), '#', .))"/>-->
    <xsl:key name="declaredIds" match="*/@xml:id"
        use="normalize-space(concat(document-uri(root(.)), '#', .))"/>
    <!--    <xsl:key name="refs" match="TEI//@target" use="tokenize(.,'\s+')"/>-->
    

    <xsl:template match="/">
        <xsl:message>TESTING</xsl:message>
        <xsl:result-document href="{$outputDirectory}/diagnostics.html">
            <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;
            </xsl:text>
            <html>
                <head>
                    <title>Diagnostics for project at <xsl:value-of select="$projectDirectory"/></title>
                    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
                    <xsl:copy-of select="$css"/>
                    <xsl:copy-of select="$javascript"/>
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
        <xsl:message> TEI doc count: <xsl:value-of select="$teiDocCount"/> @xml:id count:
                <xsl:value-of select="$teiDocsDeclaredIdsCount"/>
        </xsl:message>
    </xsl:template>
    
    
    <!--************** CONSISTENCY CHECKS ********************-->
    
    
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
                declared somewhere in the project. It assumes that any locally declared targets are
                validated by tei_all.sch.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="badInternalLinks">

        <!--        <xsl:variable name="temp" as="xs:string*">-->
        <xsl:for-each select="$teiDocs[descendant::*[@*]][position() lt 76]">
            <xsl:variable name="thisDoc" select="."/>
            <xsl:variable name="thisDocUri" select="document-uri(root(.))"/>
<!--    We can't assume documents have ids on their root elements.        -->
            <!--<xsl:variable name="thisDocId" select="@xml:id"/>-->
            <xsl:variable name="thisDocFileName" select="hcmc:returnFileName(.)"/>
            <xsl:message>Checking <xsl:value-of select="$thisDocFileName"/> (<xsl:value-of
                    select="position()"/>/<xsl:value-of select="count($teiDocs[//@target])"
                />)</xsl:message>
            <xsl:variable name="temp" as="element()*">
                <xsl:for-each select="//@*">
                    <xsl:variable name="thisAtt" select="."/>
                    <xsl:variable name="thisAttString" select="normalize-space($thisAtt)"
                        as="xs:string"/>
                    <xsl:variable name="thisAttTokens" select="tokenize($thisAttString, '\s+')"
                        as="xs:string+"/>

                    <!--None of the target tokens should start with a hash,
                since they should be referenced in the file already
                and should already be checked by schematron. NOTE: 
                MDH says we should reverse this decision and check them too.    -->
                    <xsl:variable name="itemsFound">
                        
                        <xsl:for-each
                            select="$thisAttTokens">
                            <xsl:if test="hcmc:isLocalPointer(.)">
                                
                                <!-- At this point we need to resolve private URI schemes. 
                                     Leave that aside for the moment. -->
                                <xsl:variable name="thisToken" select="normalize-space(.)" as="xs:string"/>
    
                                <!--Joey says: Since we're using the declaredIds key, we don't need to know
                                    the absolute path for the token, just the filename and hash. 
                                    Martin says: unfortunately not so. Filepaths are relative to the 
                                    containing document, so all filepaths need to be resolved in order
                                    to be checked. -->
                                <xsl:variable name="targetDoc" select="
                                    if (matches($thisToken, '.+#'))
                                    then resolve-uri(substring-before($thisToken, '#'), $thisDocUri)
                                    else if (matches($thisToken, '^#'))
                                    then $thisDocUri else ''"/>
                                
                                <xsl:variable name="targetId" select="substring-after($thisToken, '#')"/>
                                <xsl:variable name="fullTarget" select="concat($targetDoc, '#', $targetId)"/>
        
                                <xsl:choose>
                                    <xsl:when test="$teiDocs//key('declaredIds', $fullTarget)">
                                         <xsl:message>Found id for <xsl:value-of select="."/></xsl:message>
                                    </xsl:when>
                                    <xsl:when test="doc-available($fullTarget)">
                                        <xsl:message>Found document for target.</xsl:message>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <li>
                                            <xsl:value-of select="."/>
                                        </li>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:if>
                            
                        </xsl:for-each>
                    </xsl:variable>
                    <xsl:if test="$itemsFound//*:li">
                        <ul>
                            <xsl:sequence select="$itemsFound"/>
                        </ul>
                    </xsl:if>
                </xsl:for-each>
                
            </xsl:variable>
            <xsl:if test="count($temp) gt 0">
<!--                <div>-->
<!--                    <h2>-->
                <ul>
                    <li><xsl:value-of select="$thisDocFileName"/>
                        <xsl:sequence select="$temp"/>
                    </li>
                </ul>
                
                    <!--</h2>-->
                    
                <!--</div>-->
            </xsl:if>
        </xsl:for-each>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>This function takes a string input and tries to determine
        whether it's the sort of internal reference link that we want to check.
        We do this because we cannot easily determine what kinds of attribute 
        values can or should contain pointers.</xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:isLocalPointer" as="xs:boolean">
        <xsl:param as="xs:string" name="token"/>
        <xsl:choose>
<!-- Exclude external schemes first. Crude but I think it should work.-->
            <xsl:when test="matches($token, '^[A-Za-z][A-Za-z\d\.\+\-]+://')">
                <xsl:value-of select="false()"/>
            </xsl:when>
<!-- Is it a private URI scheme? We use the regex from the TEI 
     definition of teidata.prefix. -->
            <xsl:when test="matches($token, '^[a-z][a-z0-9\+\.\-]*:[^/]+')">
                <xsl:value-of select="true()"/>
            </xsl:when>
<!-- Is it a direct link to a document? We assume that a document has
     an extension of up to six characters. -->
            <xsl:when test="matches($token, '[^\.]+\.[^\.]{1,6}$')">
                <xsl:value-of select="true()"/>
            </xsl:when>
<!-- Does it end with a hash followed by a QName? Regex is based on XML Schema
                XML Character Classes \i and \c.
            -->
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
        for people to modify them. -->
    
    <xsl:variable name="javascript">
        <script type="text/javascript" xmlns="http://www.w3.org/1999/xhtml">
            <![CDATA[
 
 
 if (window.addEventListener) window.addEventListener('load', init, false)
else if (window.attachEvent) window.attachEvent('onload', init);


function init(){
 var url = window.location.href;
 var n = url.lastIndexOf('#');
 var hashDiv = url.substring(n+1);
 var div = document.getElementById(hashDiv);
 if (div !== null){ 
 div.setAttribute('class', 'showing');
}
}
            
                         
            function showHide(sender){
              var div = sender.parentNode;
             
              if (div.getAttribute('class') == 'hidden'){
                div.setAttribute('class', 'showing');
              }
              else{
                div.setAttribute('class', 'hidden');
              }
            }
          ]]>
        </script>
    </xsl:variable>
    
<!-- We should store this externally and pull it in with unparsed-text().   -->
    <xsl:variable name="css">
        <style type="text/css" xmlns="http://www.w3.org/1999/xhtml">
            <xsl:comment>
          body{
            font-family: georgia;
            font-size: 100%;
            margin: 1em 15%;
            color: #505050;
          }
          div{
            padding: 0;
            margin: 1em;
          }
          body > div, body > div > div{
            border: solid 1px gray;
          }
          div.explanation{
            font-style: italic;
          }
          h2, h3, h4{
            padding: 0.25em;
            margin: 0 0 1em 0;
            color: #000000;
          }
          h2{
            border-color: #ccccff #000066 #000066 #ccccff;
            border-width: 0.1em;
            border-style: solid;
            background-color: #aaaaff;
            
          }
         
          h3.complete {
          background-color: rgba(27, 152, 27,.5);
          }
          
          h3.toDo {
          background-color: rgba(249, 21, 47,.86);
          }
          
          div.hidden > *{
            display: none;
          }
          div.showing > * {
            display: block;
          }
          div.hidden > h3{
            display: block;
            cursor: pointer;
          }
          div.showing > h3{
            cursor: pointer;
          }
          div.hidden > h3:after{
            content: " ▶";
          }
          div.showing > h3:after{
            content: " ▼";
          }
          div.hidden > h2{
            display: block;
            cursor: pointer;
          }
          div.showing > h2{
            cursor: pointer;
          }
          div.hidden > h2:after{
            content: " ▶";
          }
          div.showing > h2:after{
            content: " ▼";
          }
          p{
            margin: 0.25em;
          }
          ul{
            margin-top: 1em;
            marin-bottom: 0.5em;
          }
          li{
            margin-top: 0.5em;
          }
          span.fileName{
            font-family: monospace;
            color: #000099;
            font-size: 120%;
          }
          table{
            margin: 1em;
            border: solid 1px gray;
            border-collapse: collapse;
          }
          thead > tr > td {
              font-weight:bold;
              }
          td{
            padding: 0.5em;
            border: solid 1px gray;
          }
          td + td{
            text-align: right;
          }
          td {
          font-size: 110%;
          }
          .xmlTag, .xmlAttName, .xmlAttVal, .teiCode{
          font-family: monospace;
          font-variant: normal;
          }
          .xmlTag, .xmlAttName, .xmlAttVal{
          font-weight: bold;
          }
          .xmlTag{
          color: #000099;
          }
          
          .xmlAttName{
          color: #f5844c;
          }
          .xmlAttVal{
          color: #993300;
          }

          .brokenLink{
          color: rgb(249, 21, 47);
          font-weight:bold;
          }
          
          .movedLink{
          font-style:italic;
          }
          
          .timestamp{
            font-size:80%;
            text-align:center;
            }
            
          </xsl:comment>
        </style>
    </xsl:variable>


</xsl:stylesheet>
