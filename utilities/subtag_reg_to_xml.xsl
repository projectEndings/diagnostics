<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xmlns="http://hcmc.uvic.ca/ns"
    xmlns:hcmc="http://hcmc.uvic.ca/ns"
    xpath-default-namespace="http://hcmc.uvic.ca/ns"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> Mar 6, 2017</xd:p>
            <xd:p><xd:b>Author:</xd:b> mholmes</xd:p>
            <xd:p>Quick transformer to generate XML from the 
            IANA Language Subtag Registry, so we can do stuff
            with it.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output method="xml" encoding="UTF-8" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:variable name="regString" select="unparsed-text('language-subtag-registry.txt')"/>
        
        <xsl:variable name="entries">
            <xsl:for-each select="tokenize($regString, '\s*%+\s*')[starts-with(., 'Type')]">
                <xsl:variable name="commentsCollapsed" select="replace(., '\n\s+', ' ')"/>
                <entry>
                    <xsl:for-each select="tokenize($commentsCollapsed, '\s*\n\s*')[contains(., ':')]">
                        <xsl:element name="{normalize-space(substring-before(., ':'))}"><xsl:value-of select="normalize-space(substring-after(., ':'))"/></xsl:element>
                    </xsl:for-each>
                </entry>
            </xsl:for-each>
        </xsl:variable>
        
        <xsl:variable name="registry">
            <registry>
                <xsl:for-each select="distinct-values($entries//Type)">
                    <xsl:variable name="thisType" select="."/>
                    <xsl:element name="{concat(., 's')}">
                        <xsl:copy-of select="$entries//entry[Type = $thisType]"/>
                    </xsl:element>
                </xsl:for-each>
            </registry>
        </xsl:variable>
        
        <langInfo>
            <xmlLangRegex><xsl:value-of select="hcmc:createXmlLangRegex($registry)"/></xmlLangRegex>
            <xsl:copy-of select="$registry"/>
        </langInfo>
    </xsl:template>
    
    <xsl:function name="hcmc:createXmlLangRegex" as="xs:string">
        <xsl:param name="registry" as="node()"/>
<!--   First concat all the possible language values.     -->
        <xsl:variable name="lang" select="concat('^((', string-join($registry//entry[Type='language']/Subtag, ')|('), '))')"/>
        <xsl:variable name="extLang" select="concat('(\-((', string-join($registry//entry[Type='extlang']/Subtag, ')|('), ')))?')"/>
        <xsl:variable name="script" select="concat('(\-((', string-join($registry//entry[Type='script']/Subtag, ')|('), ')))?')"/>
        <xsl:variable name="region" select="concat('(\-((', string-join($registry//entry[Type='region']/Subtag, ')|('), ')))?')"/>
        <xsl:variable name="variant" select="concat('(\-((', string-join($registry//entry[Type='variant']/Subtag, ')|('), ')))?')"/>
        <xsl:value-of select="concat($lang, $extLang, $script, $region, $variant, '($|\-)')"/>
    </xsl:function>
    
</xsl:stylesheet>