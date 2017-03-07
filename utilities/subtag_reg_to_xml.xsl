<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    exclude-result-prefixes="#all"
    xmlns="http://hcmc.uvic.ca/ns"
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
                <entry>
                    <xsl:for-each select="tokenize(., '\s*\n\s*')[contains(., ':') and not(matches(., '^Comments:'))]">
                        <xsl:element name="{substring-before(., ':')}"><xsl:value-of select="substring-after(., ':')"/></xsl:element>
                    </xsl:for-each>
                </entry>
            </xsl:for-each>
        </xsl:variable>
        
        <registry>
            <xsl:for-each select="distinct-values($entries//Type)">
                <xsl:element name="{concat(., 's')}">
                    <xsl:copy-of select="$entries//entry[Type=.]"/>
                </xsl:element>
            </xsl:for-each>
        </registry>
    </xsl:template>
    
</xsl:stylesheet>