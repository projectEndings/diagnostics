<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" 
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:xi="http://www.w3.org/2001/XInclude" 
    xmlns:xh="http://www.w3.org/1999/xhtml"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:teieg="http://www.tei-c.org/ns/Examples"
    xmlns:functx="http://www.functx.com"
    xmlns:java-file="java:java.io.File"
    xmlns:java-uri="java:java.net.URI"
    exclude-result-prefixes="#all" 
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml" 
    xmlns:hcmc="http://hcmc.uvic.ca/ns" 
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Started on:</xd:b> February 22, 2017</xd:p>
            <xd:p><xd:b>Authors:</xd:b> <xd:a href="http://mapoflondon.uvic.ca/HOLM3.htm">mholmes</xd:a>, <xd:a href="http://mapoflondon.uvic.ca/TAKE1.htm">jtakeda</xd:a>.</xd:p>
            <xd:p> 
                This XSLT produces the necessary pages for the diagnostics report. It calls upon
                a statistics module and a diagnostics module. 
            </xd:p>
            <xd:p>
                Note that there are a lot of potential problems surrounding the differences between
                file system paths on *NIX vs Windows platforms. It appears to be the case that on
                Windows, the slash is sometimes omitted after "file:" when you retrieve a document-uri,
                but on *NIX it's not; this seems to be unpredictable, so there are places where a slash
                is added when it's missing. The popup Java dir selector dialog box does not work on 
                Windows, but it's not clear why. If you pass the path to the projectDir at the command
                line as in the instructions, though, it works.
            </xd:p>
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
         omit-xml-declaration="yes" indent="yes" />

    <xsl:param name="projectDirectory"/>
    <xsl:param name="outputDirectory"/>
    <xsl:param name="currDate"/>
    
    
    <!--**************************************************
        *           
        *               Variables           
        *
        **************************************************-->
  
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="projectCollection" type="variable"/>
            <xd:p>We use the project directory to create a collection of all the 
                XML documents in it. We'll process all of those documents.</xd:p></xd:desc>
    </xd:doc>
    <xsl:variable name="projectCollection"
        select="collection(concat('file:///', translate($projectDirectory, '\', '/'), '?select=*.xml;recurse=yes'))"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="teiDocs" type="variable"/>
            <xd:p>All TEI documents, starting at their root. Since TEI
                allows two root elements (TEI and teiCorpus[see <xd:a href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/DS.html">here</xd:a>]), we have to account
                for all.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="teiDocs"
        select="$projectCollection/*[self::TEI | self::teiCorpus]"/>

    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="excludedAtts" type="variable"/>
            <xd:p>Although we basically check all attributes, there are some that we absolutely
                must explicitly exclude because they're bound to look like links and are 
                definitely not; and there are others that are quite common but are not URIs, so 
                we may save time by excluding them.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="excludedAtts" select="('matchPattern', 
        'replacementPattern', 'rend', 'style', 'age',
        'cert', 'cols', 'confidence', 'cRef', 'degree',
        'dim', 'direct', 'discrete', 'dur', 'dur-iso',
        'ed', 'encoding', 'evidence', 'extent', 'from', 'from-custom',
        'from-iso', 'height', 'id','ident', 'key', 'label',
        'lang', 'lemma', 'level', 'lrx', 'lry', 'match', 
        'mimeType', 'n', 'name', 'notAfter', 'notAfter-custom', 
        'notAfter-iso', 'notBefore', 'notBefore-custom', 'notBefore-iso', 'org', 
        'pattern', 'place', 'points', 'precision', 'quantity', 
        'real', 'reason', 'rhyme', 'role', 'rows', 
        'sample', 'scope', 'scribe', 'script', 'sex',
        'size', 'status', 'subtype', 'to', 'to-custom', 'to-iso',
         'type',  'ulx',  'uly',  'unit',  'width',  'when',  
        'when-custom',  'when-iso',  'xml:id', 'id', 'lang',
        'space', 'version', 'xml:lang',  'xml:space')"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="excludedNamespaces" type="variable"/>
            <xd:p>Elements in some namespaces should probably be excluded from
            checking; the obvious example is the tei egXML namespace, which is
            more than likely to include made-up examples of links that do not
            point to anything.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="excludedNamespaces" select="('http://www.tei-c.org/ns/Examples')"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="xmlFileExtensions" type="variable"/>
            <xd:p>When checking the existence of linked files, we need to know which 
            ones can be checked with doc-available() (XML files); other strategies
            are used for other document types. This variable contains only lower-case
            versions of the extensions; lower-case a file's actual extension before
            comparing.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="xmlFileExtensions" select="('xml', 'odd', 'tei', 'xsd', 'rng', 'svg', 'mml')"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="textFileExtensions" type="variable"/>
            <xd:p>When checking the existence of linked files, the existence of text 
                files can be checked using the unparsed-text-available(); other strategies
                are used for other document types. This variable contains only lower-case
                versions of the extensions; lower-case a file's actual extension before
                comparing. We include HTML files because there's no way to know whether 
                HTML is parsable as XML. Obviously this is not a complete list, just a
                sampling of files that might commonly be linked from a TEI document.
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="textFileExtensions" select="('txt', 'text', 'asc', 'htm', 'html', 'css', 'js',
                                                     'rtf', 'dtd', 'log')"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="xmlLangRegex" type="variable"/>
            <xd:p>This ridiculous regex is generated from the <xd:a href="https://www.iana.org/assignments/language-subtag-registry/language-subtag-registry">IANA Language 
                Subtag Registry</xd:a>, and is designed to check for incorrect values
                in @xml:lang. It does not guarantee that values make sense, but 
                it checks that they are constructed correctly from the available
                values for each component of a language subtag. It ignores private
                and extension tags that may appear at the end.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="xmlLangRegex" select="replace(unparsed-text('xmlLangRegex.txt'), '\s+', '')"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="uriSchemeRegex" type="variable"/>
            <xd:p>This (less ridiculous) regex is generated from the <xd:a 
                href="https://www.iana.org/assignments/uri-schemes/uri-schemes.xml">IANA 
                Unified Resource Identifier (URI) Scheme</xd:a>, and is designed to check
                whether an undeclared prefix has a likely canonical reference. 
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="uriSchemeRegex" select="replace(unparsed-text('uriSchemeRegex.txt'),'\s+','')"/>
    
    
    <xd:doc>
        <xd:desc>The IANA Media Types registry changes frequently, so we download the XML file each time
        and then turn it into a Regular Expression</xd:desc>
    </xd:doc>
    <xsl:variable name="ianaMimetypesDoc" select="document('mimeTypes.xml')"/>
    <xd:doc>
        <xd:desc>The distinct mimetypes</xd:desc>
    </xd:doc>
    <xsl:variable name="mimeTypes" select="distinct-values($ianaMimetypesDoc//*:file[@type='template'])" as="xs:string+"/>
 
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="mimeTypeRegex" type="variable"/>
            <xd:p>This (less ridiculous) regex is generated from the <xd:a 
                href="https://www.iana.org/assignments/uri-schemes/uri-schemes.xml">IANA 
                Unified Resource Identifier (URI) Scheme</xd:a>, and is designed to check
                whether an undeclared prefix has a likely canonical reference. 
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="mimeTypeRegex" select="string-join(for $n in $mimeTypes return concat('(',functx:escape-for-regex($n),')'),'|')"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="charsetsRegex" type="variable"/>
            <xd:p>This (medium ridiculous) regex is generated from the <xd:a 
                href="https://www.iana.org/assignments/character-sets/character-sets.xml">IANA 
                Character Sets Registry</xd:a>, and is designed to check whether a declared
                character encoding is valid.
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="charsetsRegex" select="replace(unparsed-text('charsetsRegex.txt'),'\s+','')"/>
    
    <!--**************************************************
        *           
        *                  Keys         
        *
        **************************************************-->
    

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
        <xd:desc>
            <xd:ref name="idMatch" type="key"/>
            <xd:p>This key indexes all @xml:id attributes in a document for
            quick processing of documents that refer to ids internally.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:key name="idMatch" match="*/@xml:id" use="normalize-space(concat('#',.))"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="value-to-atts" type="key"/>
            <xd:p>This key indexes all pointer attributes by their tokenized values
            for faster processing of internal links.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:key name="value-to-atts" 
        match="*[not(namespace-uri(.) = $excludedNamespaces)]/@*[not(local-name(.) = $excludedAtts)]"
        use="tokenize(normalize-space(.),'\s+')"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="prefixDefs" type="key"/>
            <xd:p>This key is used to index all prefixDefs in a project so that 
                their expansion regexes can be retrieved and used easily.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:key name="prefixDefs" match="prefixDef" use="@ident"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="projectDirRel" type="variable"/>
            <xd:p>This variable replaces a '.' step in a
            file path, which causes errors in output when this XSLT
            is applied to the diagnostics/test directory.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="projectDirRel" select="replace($projectDirectory,'/\./','/')"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="allIds" type="variable"/>
            <xd:p>List of all the @xml:id attributes in the document 
            collection; any of these might be targets of a pointer 
            attribute.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="allIds" select="$teiDocs/descendant-or-self::*/@xml:id" as="attribute(xml:id)*"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="idRegex" type="variable"/>
            <xd:p>Constructed regular expression which is used to check the 
            existence of target ids in target documents.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="idRegex" select="
        hcmc:makeRegex((for $a in $allIds
        return normalize-space(concat(document-uri(root($a)),'#',$a))),$projectDirRel)"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="projectFilesRegex" type="variable"/>
            <xd:p>Constructed regular expression which is used to check the 
                existence of documents in the collection which may be 
                pointed at by pointer attributes.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="projectFilesRegex" select="hcmc:makeRegex((for $n in $projectCollection return document-uri($n)),$projectDirRel)"/>
    

    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="docsWithPrefixDefs" type="variable"/>
            <xd:p>Set of all the documents in the collection that contain
            prefixDefs. We don't know exactly where a prefixDef we need
            may be found.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="docsWithPrefixDefs" select="$teiDocs[descendant::prefixDef]"/>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="allPrefixDefs" type="variable"/>
            <xd:p>Set of all the functional prefixDef elements in the collection.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="allPrefixDefs" select="$teiDocs//prefixDef[@matchPattern and @replacementPattern and @ident]"/>
    
    <!--**************************************************
        *           
        *                  Templates         
        *
        **************************************************-->
    
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref type="template"/>
            <xd:p>Root template that runs the whole process.</xd:p>
        </xd:desc>
    </xd:doc> 
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
                        
                    </div>
                    <p class="timestamp">Last generated: <xsl:value-of select="current-dateTime()"/></p>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>
    
    <!--************** STATISTICS ********************-->
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="generateStatistics" type="template"/>
            <xd:p>This template generates a number of statistics about the project.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="generateStatistics">
        <xsl:message>Creating statistics...</xsl:message>
        <xsl:variable name="teiDocCount" select="count($teiDocs)"/>
        <xsl:variable name="teiDocsDeclaredIdsCount" select="count($teiDocs/descendant-or-self::*/@xml:id)"/>
       
        
        <xsl:message>TEI doc count: <xsl:value-of select="$teiDocCount"/>&#x0a;@xml:id count: <xsl:value-of select="$teiDocsDeclaredIdsCount"/></xsl:message>
        
        <div class="showing">
            <h2 onclick="showHide(this)">Statistics</h2>
            <table>
                <tbody>
                    <tr><td>TEI documents</td><td><xsl:value-of select="$teiDocCount"/></td></tr>
                    <tr><td>Declared <span class="attName">xml:id</span>s</td><td><xsl:value-of select="$teiDocsDeclaredIdsCount"/></td></tr>
                </tbody>
            </table>
            <xsl:call-template name="elementsUsed"/>
            <xsl:call-template name="attributesUsed"/>
        </div>
    </xsl:template>
    
    <xd:doc>
        <xd:desc>
            <xd:ref name="elementsUsed" type="template"/>
            <xd:p>This template compiles various statistics about the 
                elements used in the project.</xd:p>
        </xd:desc>
        <xd:return>
            <xd:p>An XHTML &lt;div&gt;.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:template name="elementsUsed" as="element(xh:div)">
        <xsl:message>Listing elements used...</xsl:message>
        <xsl:variable name="allElements" select="$teiDocs/descendant-or-self::*"/>
        <xsl:variable name="allElementsNames" select="for $n in $allElements return local-name($n)"/>
        <xsl:variable name="distinctElements" select="distinct-values($allElementsNames)" as="xs:string+"/>
        <div class="hidden">
            <h3 onclick="showHide(this)">Elements used</h3>
            <table>
                <tbody>
                    <tr>
                        <td>Distinct elements</td>
                        <td><xsl:value-of select="count($distinctElements)"/></td>
                    </tr>
                </tbody>
            </table>
            <table>
                <thead>
                    <tr>
                        <td>Element name</td>
                        <td>Number of times element used</td>
                        <td>Number of documents containing this element</td>
                        <td>Average uses per document</td>
                        <td>TEI Guidelines</td>
                    </tr>
                </thead>
                <tbody>
                    <!--Create a row for each element-->
                    <xsl:for-each select="$distinctElements">
                        <xsl:sort order="ascending" select="lower-case(.)"/>
                        <xsl:variable name="thisElementName" select="."/>
                        
                        <!--Which TEI docs contain this element-->
                        <xsl:variable
                            name="docsContainingThisElement"
                            select="$teiDocs[descendant-or-self::*[local-name()=$thisElementName]]"/>
                        
                        <!--How many documents use this element-->
                        <xsl:variable 
                            name="totalDocs"
                            select="count($docsContainingThisElement)"/>
                        
                        <!--How many times is the element referenced across the project-->
                        <xsl:variable
                            name="totalElement"
                            select="count($teiDocs/descendant-or-self::*[local-name()=$thisElementName])"/>
                        
                        <!--Calculated average of uses per document-->
                        <xsl:variable
                            name="averageUses"
                            select="$totalElement div $totalDocs"/>
                        
                        <tr>
                            <td><span class="xmlTag"><xsl:value-of select="$thisElementName"/></span></td>
                            <td><xsl:value-of select="$totalElement"/></td>
                            <td><xsl:value-of select="$totalDocs"/></td>
                            <td><xsl:value-of select="format-number($averageUses,'#.#')"/></td>
                            <td><a href="http://tei-c.org/release/doc/tei-p5-doc/en/html/ref-{$thisElementName}.html">TEI</a></td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="attributesUsed" type="template"/>
            <xd:p>This template compiles various statistics about the
                attributes used in the project.</xd:p>
        </xd:desc>
        <xd:return>
            <xd:p>An XHTML &lt;div&gt;.</xd:p>
        </xd:return>
    </xd:doc>
    <xsl:template name="attributesUsed" as="element(xh:div)">
        <xsl:message>Listing attributes used...</xsl:message>
        <xsl:variable name="allAttributes" select="$teiDocs/descendant-or-self::*/@*"/>
        <xsl:variable name="allAttributesNames" select="for $n in $allAttributes return local-name($n)"/>
        <xsl:variable name="distinctAttributes" select="distinct-values($allAttributesNames)" as="xs:string+"/>
        <div class="hidden">
            <h3 onclick="showHide(this)">Attributes used</h3>
            <table>
                <tbody>
                    <tr>
                        <td>Distinct attributes</td>
                        <td><xsl:value-of select="count($distinctAttributes)"/></td>
                    </tr>
                </tbody>
            </table>
            <table>
                <thead>
                    <tr>
                        <td>Attribute name</td>
                        <td>Number of times used</td>
                        <td>Number of distinct parent elements</td>
                        <td>Number of distinct attribute values</td>
                        <td>Number of documents containing this attribute</td>
                        <td>Average uses per document</td>
                        <td>TEI Guidelines</td>
                    </tr>
                </thead>
                <tbody>
                    <!--Create rows for each attribute-->
                    <xsl:for-each select="$distinctAttributes">
                        <xsl:sort order="ascending"/>
                        <xsl:variable name="thisAtt" select="."/>
                        
                        <!--Documents containing this attribute-->
                        <xsl:variable 
                            name="docs" 
                            select="$teiDocs[descendant-or-self::*[@*/local-name()=$thisAtt]]"/>
                        
                        <!--Each individual use of this attribute-->
                        <xsl:variable 
                            name="timesUsed" 
                            select="$teiDocs/descendant-or-self::*/@*[local-name()=$thisAtt]"/>
                        
                        <!--Distinct elements that contain this attribute-->
                        <xsl:variable 
                            name="distinctParentElements" 
                            select="distinct-values(for $n in $timesUsed return $n/parent::*/local-name())"/>
                        
                        <!--The distinct attribute values-->
                        <xsl:variable 
                            name="distinctValues" 
                            select="distinct-values(for $t in $timesUsed return tokenize(normalize-space($t),'\s+'))"/>
                        
                        <!--The count of all the above variables-->
                        <xsl:variable name="docsCount" select="count($docs)"/>
                        <xsl:variable name="timesUsedCount" select="count($timesUsed)"/>
                        <xsl:variable name="distinctParentElementsCount" select="count($distinctParentElements)"/>
                        <xsl:variable name="distinctValuesCount" select="count($distinctValues)"/>
                        
                        <!--fn:local-name() strips xml:id, xml:lang, xml:base, and xml:space of their prefix.
                            For ease of viewing, we re-affix the xml prefix if it was stripped from the attribute name. -->
                        <xsl:variable name="thisAttName"
                            select="
                            if ($thisAtt=('id','base','lang','space')) 
                            then concat('xml:',$thisAtt)
                            else $thisAtt"/>
                        
                        <!--Now create the table row-->
                        <tr>
                            <td><span class="xmlAttName"><xsl:value-of select="$thisAttName"/></span></td>
                            <td><xsl:value-of select="$timesUsedCount"/></td>
                            <td><xsl:value-of select="$distinctParentElementsCount"/></td>
                            <td><xsl:value-of select="$distinctValuesCount"/></td>
                            <td><xsl:value-of select="$docsCount"/></td>
                            <td><xsl:value-of select="format-number($timesUsedCount div $docsCount,'#.###')"/></td>
                            <td><a href="http://www.tei-c.org/release/doc/tei-p5-doc/en/html/REF-ATTS.html#{$thisAtt}">TEI</a></td>
                        </tr>
                    </xsl:for-each>
                </tbody>
            </table>
        </div>
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
        <xsl:message>Performing consistency checks...</xsl:message>
        <div>
            <h2>Consistency Checks</h2>
            <!--<xsl:call-template name="badInternalLinks"/>-->
            <xsl:call-template name="badInternalLinksByPointer"/>
            <xsl:call-template name="badXmlLangValues"/>
            <xsl:call-template name="badMimetypes"/>
        </div>
    </xsl:template>

    
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
        <xd:desc>Bad internal links by pointer uses the distinct values
        of pointers in each document and then uses a key to find
        all the attributes that use that pointer.</xd:desc>
    </xd:doc>
    <xsl:template name="badInternalLinksByPointer" as="element(xh:div)">
        <xsl:message>Checking for bad internal links...</xsl:message>
        <xsl:variable name="output" as="element(xh:ul)*">
            <xsl:variable name="docsToCheck" select="$teiDocs[descendant::*[@*]]"/>
            <xsl:variable name="docsToCheckCount" select="count($docsToCheck)"/>
            <xsl:for-each select="$docsToCheck">
                <xsl:variable name="thisDoc" select="."/>
                <xsl:variable name="thisDocUri" select="document-uri(root(.))"/>
                <xsl:variable name="thisDocFileName" select="hcmc:returnFileName(.)"/>
                <xsl:message>Checking <xsl:value-of select="$thisDocFileName"/> (<xsl:value-of
                    select="position()"/>/<xsl:value-of select="$docsToCheckCount"
                    />)</xsl:message>
                <xsl:if test="$thisDoc//*[@xml:base]">
                    <xsl:message>WARNING: @xml:base detected, but currently ignored. See documentation for more detail.</xsl:message>
                </xsl:if>
                <xsl:variable name="temp" as="element()">
                    <xsl:variable name="attsToCheck" select="descendant-or-self::*[not(namespace-uri(.) = $excludedNamespaces)]/@*[not(local-name(.) = $excludedAtts)][string-length(normalize-space(.)) gt 0]"/>
                    <xsl:variable name="distinctAttTokens"
                        select="distinct-values(
                        for $a in $attsToCheck 
                        return tokenize(normalize-space($a),'\s+'))"/>
                    
                    <ul>
                        <!--This is a temp variable to be used later-->
                        <xsl:variable name="checkAtts" as="xs:string*">
                            <xsl:for-each select="$distinctAttTokens">
                                <!-- <xsl:message>Processing <xsl:value-of select="."/></xsl:message>-->
                                <xsl:variable name="tokenOriginal" select="."/>
                                <!-- Is it a private URI scheme? We use the regex from the TEI 
                                         definition of teidata.prefix. If it is one, resolve it 
                                         before continuing. -->
                                <xsl:variable name="prefixRegex" select="'^[a-z][a-z0-9\+\.\-]*:[^/]+'"/>
                                <xsl:variable 
                                    name="thisToken" 
                                    select="if (matches(., $prefixRegex))
                                    then hcmc:resolvePrefixDef(., root($thisDoc))
                                    else ." as="xs:string"/>
                                
                                <!--Test to see if its local to the project and 
                                    not an external URL-->
                               
                                <xsl:if test="hcmc:isLocalPointer($thisToken)">
                                    <xsl:choose>
                                        <!--If this is an in document pointer, then just check this document-->
                                        <xsl:when test="matches($thisToken,'^#')">
                                            <xsl:choose>
                                                <xsl:when test="$thisDoc/key('idMatch',$thisToken)"/>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$tokenOriginal"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        
                                        <!--Otherwise, process through the pipeline-->
                                        <xsl:otherwise>
                                            <xsl:variable name="targetDoc" select="
                                                if (matches($thisToken, '.+#'))
                                                then resolve-uri(substring-before($thisToken, '#'), $thisDocUri)
                                                else if (matches($thisToken, '^#'))
                                                then $thisDocUri 
                                                else if (contains($thisToken,':'))
                                                then $thisToken
                                                else resolve-uri($thisToken, $thisDocUri)"/>
                                            
                                            <!--<xsl:message>$thisToken = <xsl:value-of select="$thisToken"/>; 
                                                $thisDocUri = <xsl:value-of select="$thisDocUri"/>
                                            </xsl:message>-->
                                            
                                            <xsl:variable name="targetId" select="substring-after($thisToken, '#')"/>
                                            <xsl:variable name="fullTarget"
                                                select="if (contains($thisToken, '#')) then concat($targetDoc, '#', $targetId) else $targetDoc"/>
                                            <xsl:variable name="fullTargCanonical" select="replace($fullTarget,'/\./','/')"/>
                                            <xsl:choose>
                                                <xsl:when test="$fullTargCanonical[matches(.,$idRegex)]">
                                                    <!--Do nothing-->
                                                    <!--<xsl:message select="concat('Found match for:', $fullTargCanonical)"/>-->
                                                </xsl:when>
                                               
                                                <xsl:when test="
                                                    not(contains($fullTargCanonical, '#')) and
                                                    not(matches($fullTargCanonical,$prefixRegex)) and
                                                    hcmc:fileExists($fullTarget)">
                                                   <!-- <xsl:message>Found document for <xsl:value-of select="$fullTarget"/>.</xsl:message>-->
                                                </xsl:when>
                                                <xsl:when test="matches($fullTargCanonical,'^[A-Za-z]:[^/\\]')">
                                                    <xsl:message><xsl:value-of select="$fullTargCanonical"/> is an undefined prefix</xsl:message>
                                                    <xsl:value-of select="$tokenOriginal"/>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <xsl:value-of select="$tokenOriginal"/>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:if>
                            </xsl:for-each>
                        </xsl:variable>
                        
                        <xsl:for-each select="$checkAtts">
                            <xsl:variable name="attToken" select="."/>
                            <xsl:for-each select="$thisDoc/key('value-to-atts', $attToken)">
                                <xsl:variable name="thisAtt" select="."/>
                                <xsl:variable name="thisAttName" select="local-name($thisAtt)"/>
                                
                                <li><span class="xmlAttName"><xsl:value-of select="$thisAttName"/></span>: 
                                    <span class="xmlAttVal"><xsl:value-of select="$attToken"/></span>
                                </li>
                            </xsl:for-each>
                        </xsl:for-each>
                    </ul>
                </xsl:variable>

                <xsl:if test="$temp//*:li">
                    <ul>
                        <li><xsl:value-of select="$thisDocUri"/>
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
    </xsl:template>
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="badXmlLangValues" type="template"/>
            <xd:p>template: badXmlLangValues</xd:p>
            <xd:p>This template checks that all @xml:lang attributes have
            values which conform with the permitted values in the IANA
            Language Subtag Registry.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="badXmlLangValues" as="element(xh:div)">
        <xsl:message>Checking for bad XML language values...</xsl:message>
        <xsl:variable name="output" as="element(xh:ul)*">
            <xsl:for-each select="$teiDocs[descendant::*[@xml:lang]]">
                <xsl:variable name="thisDoc" select="."/>
                <xsl:variable name="thisDocUri" select="document-uri(root(.))"/>
                <!--    We can't assume documents have ids on their root elements.        -->
                <!--<xsl:variable name="thisDocId" select="@xml:id"/>-->
                <xsl:variable name="thisDocFileName" select="hcmc:returnFileName(.)"/>
                <xsl:message>Checking <xsl:value-of select="$thisDocFileName"/> (<xsl:value-of
                    select="position()"/>/<xsl:value-of select="count($teiDocs[//@xml:lang])"
                    />)</xsl:message>
                <xsl:variable name="temp" as="element()">
                    <ul>
                        <xsl:for-each select="//@xml:lang">
                            <!--<xsl:message>Checking xml:lang value: <xsl:value-of select="."/></xsl:message>-->
                            <xsl:if test="not(matches(., $xmlLangRegex))">
                                <!--<xsl:message>Found bad xml:lang value: <xsl:value-of select="."/></xsl:message>-->
                                <li><span class="xmlAttName">xml:lang</span>: 
                                    <span class="xmlAttVal"><xsl:value-of select="."/></span>
                                </li>
                            </xsl:if>
                        </xsl:for-each>
                    </ul>
                </xsl:variable>
                <xsl:if test="$temp//*:li">
                    <ul>
                        <li><xsl:value-of select="$thisDocUri"/>
                            <xsl:sequence select="$temp"/>
                        </li>
                    </ul>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>    
        <xsl:call-template name="createDiagnosticsDiv">
            <xsl:with-param name="id" select="'badXmlLangValues'"/>
            <xsl:with-param name="explanation"
                select="'These values for @xml:lang attributes do not 
                conform with those specified in the IANA Language Subtag
                Registry.'"/>
            <xsl:with-param name="title" select="'Bad @xml:lang Values'"/>
            <xsl:with-param name="results" select="$output"/>
            <xsl:with-param name="resultsCount"
                select="count($output//xh:li[ancestor::xh:li])"/>
        </xsl:call-template>
    </xsl:template>
    
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="badMimetypes" type="template"/>
            <xd:p>template: badMimetypes</xd:p>
            <xd:p>This template checks that all @mimeType attributes have
                values which conform with the permitted values in the IANA
                Media Type registry.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:template name="badMimetypes" as="element(xh:div)">
        <xsl:message>Checking for bad mimeTypes...</xsl:message>
        <xsl:variable name="filesToCheck" select="$teiDocs[descendant::*[@mimeType]]"/>
        <xsl:variable name="filesCount" select="count($filesToCheck)"/>
        <xsl:variable name="output" as="element(xh:ul)*">
            <xsl:for-each select="$filesToCheck">
                <xsl:variable name="thisDoc" select="."/>
                <xsl:variable name="thisDocUri" select="document-uri(root(.))"/>
                <xsl:variable name="thisDocFileName" select="hcmc:returnFileName(.)"/>
                <xsl:message>Checking <xsl:value-of select="$thisDocFileName"/> (<xsl:value-of
                    select="position()"/>/<xsl:value-of select="$filesCount"
                    />)</xsl:message>
                <xsl:variable name="temp" as="element()">
                    <ul>
                        <xsl:for-each select="//@mimeType">
                            <xsl:variable name="tokens" select="tokenize(.,';')"/>
                            <xsl:variable name="mime" select="normalize-space($tokens[1])"/>
                            <xsl:variable name="charsetDecl" select="normalize-space($tokens[2])"/>
                            <xsl:variable name="hasCharset" select="count($tokens) gt 1 and starts-with($charsetDecl,'charset')"/>
                            <xsl:variable name="encoding" select="normalize-space(substring-after($charsetDecl,'='))"/>
                            <xsl:if test="not(matches($mime, $mimeTypeRegex))">
                                <!--<xsl:message>Found bad xml:lang value: <xsl:value-of select="."/></xsl:message>-->
                                <li><span class="xmlAttName">mimeType</span>: 
                                    <span class="xmlAttVal"><xsl:value-of select="$mime"/></span>
                                </li>
                            </xsl:if>
                            <xsl:if test="$hasCharset and not(matches($encoding,$charsetsRegex,'i'))">
                                <li><span class="xmlAttName">mimeType</span> (charset value): 
                                    <span class="xmlAttVal"><xsl:value-of select="$encoding"/></span>
                                </li>
                            </xsl:if>
                        </xsl:for-each>
                    </ul>
                </xsl:variable>
                <xsl:if test="$temp//*:li">
                    <ul>
                        <li><xsl:value-of select="$thisDocUri"/>
                            <xsl:sequence select="$temp"/>
                        </li>
                    </ul>
                </xsl:if>
            </xsl:for-each>
        </xsl:variable>    
        <xsl:call-template name="createDiagnosticsDiv">
            <xsl:with-param name="id" select="'badMimetypes'"/>
            <xsl:with-param name="explanation"
                select="'These values for @mimeType attributes do not 
                conform with those specified in the IANA Mimetype registry. Note that this
                diagnostic does not check the accuracy of the mimeType value, but just
                confirms that the mimeType is a legal value.'"/>
            <xsl:with-param name="title" select="'Bad @mimeType Values'"/>
            <xsl:with-param name="results" select="$output"/>
            <xsl:with-param name="resultsCount"
                select="count($output//xh:li[ancestor::xh:li])"/>
        </xsl:call-template>
    </xsl:template>
    
    
    <!--**************************************************
        *           
        *                  Functions
        *
        **************************************************-->
    
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
<!--            <xsl:when test="matches($token, '^[A-Za-z][A-Za-z\d\.\+\-]+://')">
                <xsl:value-of select="false()"/>
            </xsl:when>-->

            <xsl:when test="contains($token,':')">
                <xsl:choose>
                    <!-- Exclude all external schemes-->
                    <xsl:when test="matches($token,concat('^',$uriSchemeRegex,':'))">
                       
                        <xsl:value-of select="false()"/>
                    </xsl:when>
                    <!--But make sure all non-declared internal schemes are caught-->
                    <xsl:otherwise>
                        
                        <xsl:value-of select="true()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            
<!-- Is it a direct link to a document? We assume that a document has
     a name of at least three and an extension of up to six characters. -->
            <xsl:when test="matches($token, '[^\.]{3,}\.[^\.]{1,6}$')">
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
        <xd:param name="sourceDoc">
            <xd:p>The document node of a source document in which a 
            prefix occurs.</xd:p>
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
        <xsl:variable name="prefixDef" select="
            if ($localPrefixDef/@matchPattern) 
            then $localPrefixDef
            else $allPrefixDefs//key('prefixDefs', $prefix)"/>
        <xsl:choose>
            <xsl:when test="$prefixDef">
                <!--<xsl:message>prefixDef: <xsl:value-of select="concat($prefixDef[1]/@ident, ', ', $prefixDef[1]/@matchPattern, ', ', $prefixDef[1]/@replacementPattern)"/></xsl:message>-->
                <xsl:value-of select="replace(substring-after($token, ':'), $prefixDef[@matchPattern][1]/@matchPattern, $prefixDef[@matchPattern][1]/@replacementPattern)"/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="$token"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!--<xd:doc scope="component">
        <xd:desc>
            <xd:ref target="hcmc:fileExists" type="function"/>
            <xd:p>Simple Java-based function based with thanks on an example by 
                Stefan Krause (https://www.oxygenxml.com/archives/xsl-list/201002/msg00179.html)
                to test whether a file exists.
            </xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:function name="hcmc:fileExists" as="xs:boolean">
        <xsl:param name="uri" as="xs:string?"/>
        <xsl:variable name="extension" select="replace($uri, '.+\.([^\./]+)$', '$1')"/>
        <xsl:choose>
            <xsl:when test="$extension = $xmlFileExtensions"><xsl:value-of select="doc-available($uri)"/></xsl:when>
            <xsl:when test="$extension = $textFileExtensions"><xsl:value-of select="unparsed-text-available($uri)"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="java-file:exists(java-file:new(java-uri:new($uri)))"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>-->
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref target="hcmc:fileExists" type="function"/>
            <xd:p>Replacement for above Java-based system, which doesn't work 
                under saxon9he. We may be able to take this approach instead:
                http://saxonica.com/documentation/index.html#!extensibility/integratedfunctions/ext-simple-J
                but for the moment we'll just give up on checking the existence of binaries.
            </xd:p>
        </xd:desc>
        <xd:param name="uri">
            <xd:p>The URI of the document which is being checked.</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:function name="hcmc:fileExists" as="xs:boolean">
        <xsl:param name="uri" as="xs:string?"/>
        <xsl:variable name="extension" select="replace($uri, '.+\.([^\./]+)$', '$1')"/>
       <!-- <xsl:message>Found extensions <xsl:value-of select="$extension"/></xsl:message>-->
        <!--<xsl:message>URI to check is: <xsl:value-of select="$uri"/></xsl:message>-->
        <xsl:choose>
            <xsl:when test="$extension = $xmlFileExtensions">
                <!--<xsl:message>Checking <xsl:value-of select="$uri"/></xsl:message>-->
                <xsl:choose>
                    <xsl:when test="matches($uri,$projectFilesRegex)">
                        <xsl:value-of select="true()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="doc-available($uri)"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$extension = $textFileExtensions"><xsl:value-of select="unparsed-text-available($uri)"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="true()"/></xsl:otherwise>
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
    
    <xd:doc scope="component">
        <xd:desc>
            <xd:ref name="hcmc:makeRegex" type="function"/>
            The hcmc:makeRegex function turns a list of strings 
            (which in this case are paths) into a long regex 
            which can be used to check them quickly.
        </xd:desc>
        <xd:param name="strings">
            <xd:p>Sequence of xs:strings which are paths;
            these are to be turned into a regular expression.</xd:p>
        </xd:param>
        <xd:param name="baseDir">
            <xd:p>The base directory which we expect will be the 
            first part of most of these paths; this can be used to
            create a more efficient regex.</xd:p>
        </xd:param>
    </xd:doc>
    <xsl:function name="hcmc:makeRegex" as="xs:string">
        <xsl:param name="strings"/>
        <xsl:param name="baseDir"/>
        <xsl:variable name="escapedBaseDir" select="replace($baseDir, '\\', '/')"/>
        <!--<xsl:message><xsl:value-of select="string-join($strings, '&#x0a;')"/></xsl:message>
        <xsl:message><xsl:value-of select="$baseDir"/></xsl:message>-->
        <xsl:variable name="collapsedPaths" select="for $s in $strings return replace(replace($s,'/\./','/'),concat('file:', if (starts-with($escapedBaseDir, '/')) then '' else '/', $escapedBaseDir,'/'),'')"/>
        <xsl:variable name="regex" select="replace(concat('^file:', if (starts-with($escapedBaseDir, '/')) then '' else '/', $escapedBaseDir,'/(',string-join(for $s in $collapsedPaths return concat('(',$s,')'),'|'),')$'),'\.','\\.')"/>
        
        <!--<xsl:message select="$regex"/>-->
        <xsl:value-of select="$regex"/>
    </xsl:function>
    
    <xd:doc>
        <xd:desc>
            <xd:p>Taken from http://www.xsltfunctions.com/xsl/functx_escape-for-regex.html. "The functx:escape-for-regex function escapes a string that you wish to be taken literally rather than treated like a regular expression. This is useful when, for example, you are calling the built-in fn:replace function and you want any periods or parentheses to be treated like literal characters rather than regex special characters."</xd:p>
        </xd:desc>
        <xd:param name="arg">the string to escape</xd:param>
        <xd:return>a string</xd:return>
    </xd:doc>
    <xsl:function name="functx:escape-for-regex" as="xs:string">
        <xsl:param name="arg" as="xs:string?"/>
        <xsl:sequence select="
            replace($arg,
            '(\.|\[|\]|\\|\||\-|\^|\$|\?|\*|\+|\{|\}|\(|\))','\\$1')
            "/>
    </xsl:function>
    
    <!--Sample: file:/Users/joeytakeda/projectEndings/diagnostics/\./test/website_structure_standalone_test.xml#clickToZoomCaption-->
    
    
<!--    HTML HEADER VARIABLES (TAKEN FROM THE MAP OF EARLY MODERN LONDON)-->
<!--    Joey to Martin: Should we have a globals module for these sorts of things?
        Martin to Joey: I think we should store these in external CSS and JS 
        files and pull them in with unparsed-text(). That will make it easier
        for people to modify them.
        Joey to Martin: Good call. I've commented out the CDATAs since they
        were breaking the Javascript in the output.
    
    -->
    
    
    <!--**************************************************
        *           
        *             HTML Display Variables         
        *
        **************************************************-->
    <xd:doc>
        <xd:desc>
            <xd:ref name="javascript" type="variable"/>
            <xd:p>The javascript required for functionality on the diagnostics output.
            The content is editable by users in this directory: <xd:a href="script.js">script.js</xd:a>.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="javascript">
        <script type="text/javascript" xmlns="http://www.w3.org/1999/xhtml">
<!--            These CDATAs seem to break the javascript in the XHTML5 output.
                Keeping it simple to avoid issues with browsers on Windows. -->
            <!--<xsl:text disable-output-escaping="yes">//&#x0003C;!CDATA[[</xsl:text>-->
            <!--<xsl:comment>-->
<!--            If we don't do this, we end up with escaped &#XD;s in the JS, which breaks it, 
                on Windows. -->
            <xsl:value-of disable-output-escaping="yes" select="string-join(tokenize(unparsed-text('script.js'), '[&#x0a;&#x0d;]+'), '&#x0a;')"/>
            <!--</xsl:comment>-->
            <!--<xsl:text disable-output-escaping="yes">//]]/&#x0003E;</xsl:text>-->
        </script>
    </xsl:variable>
    
<!-- We should store this externally and pull it in with unparsed-text().   -->
    <xd:doc>
        <xd:desc>
            <xd:ref name="css" type="variable"/>
            <xd:p>The CSS required for styling on the diagnostics output.
                The content is editable by users in this directory: <xd:a href="style.css">style.css</xd:a>.</xd:p>
        </xd:desc>
    </xd:doc>
    <xsl:variable name="css">
        <style type="text/css" xmlns="http://www.w3.org/1999/xhtml">
          <xsl:comment>
            <xsl:value-of select="unparsed-text('style.css')"/>
          </xsl:comment>
        </style>
    </xsl:variable>
    
    


</xsl:stylesheet>
