<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    exclude-result-prefixes="xs xd text"
    version="2.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 23, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> Tom Elliott</xd:p>
            <xd:p>This stylsheet is intended to extract basic informations about "instances" and "documents" from the elliottDiss.xml file in such a way that stable URIs and other valuable linked data resources can be generated therefrom. Note that INST and DOC numbers are primary keys from an old database; they do not reflect the order or numeration in which these "instances" and "documents" were presented in the dissertation. Both sets of identifiers will need to be kept.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output encoding="UTF-8" method="xml" indent="yes"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="//text:bookmark-start[contains(@text:name, 'INST')]">
            <xsl:sort select="substring-after(@text:name, 'INST')" data-type="number"/>
        </xsl:apply-templates>    
    </xsl:template>
    
    <xsl:template match="text:bookmark-start[contains(@text:name, 'INST') and not(contains(@text:name, '_'))]">
        <xsl:variable name="bkmkstart" select="."/>
        <xsl:variable name="bkmkend" select="following::text:bookmark-end[@text:name=$bkmkstart/@text:name]"/>
        <xsl:variable name="nextbkmk" select="$bkmkend/following::text:bookmark-start[contains(@text:name, 'INST') and not(contains(@text:name, '_'))][1]"/>        
        <xsl:variable name="elestart" select=".."/>
        <xsl:variable name="eleend" select="$nextbkmk/.."/>
        <div type="instance">
            <idno type="original"><xsl:value-of select="$bkmkstart/@text:name"/></idno>
            <start><xsl:value-of select="local-name(//*[generate-id()=generate-id($elestart)])"/></start>
            <end><xsl:value-of select="local-name(//*[generate-id()=generate-id($eleend)])"/></end>
            <xsl:variable name="ns1" select="$elestart/following-sibling::*"/>
            <xsl:variable name="ns2" select="$eleend/preceding-sibling::*"/>
            <xsl:apply-templates select="$elestart | $ns1[count(. | $ns2)=count($ns2)] | $eleend" mode="instance"/>            
        </div>
    </xsl:template>
    
    <!-- text:h with style-name treInstance can become a plain head -->
    <xsl:template match="text:h[@text:style-name='treInstance']" mode="instance">
        <head><xsl:apply-templates mode="instance"/></head>
    </xsl:template>
    
    <!-- other headings preserve their style -->
    <xsl:template match="text:h" mode="instance">
        <xsl:element name="head">
            <xsl:call-template name="stdattr"/>
            <xsl:apply-templates mode="instance"/>
        </xsl:element>
    </xsl:template>

    <!-- capture Burton concordances -->
    <xsl:template match="text:p[starts-with(., 'Burton 2000')]" mode="instance">
        <p><bibl><ptr ref="dbib:burton-2000"/><xsl:text> </xsl:text><xsl:value-of select="normalize-space(substring-after(., 'Burton 2000, '))"/></bibl></p>
    </xsl:template>
    
    <xsl:template match="text:p" mode="instance">
        <xsl:element name="p">
            <xsl:call-template name="stdattr"/>
            <xsl:apply-templates mode="instance"/>
        </xsl:element>        
    </xsl:template>
    <xsl:template match="text:span" mode="instance">
        <xsl:element name="seg">
            <xsl:call-template name="stdattr"/>
            <xsl:apply-templates mode="instance"/>
        </xsl:element>
    </xsl:template>
    
    <!-- suppress bookmarks -->
    <xsl:template match="text:bookmark-start | text:bookmark-end" mode="instance"/>
    
    <!-- suppress seg type=40, which was hidden text -->
    <xsl:template match="text:span[@text:style-name='T40']" mode="instance"/>
    
    <!-- traps -->
    
    <xsl:template match="*" mode="instance">
        <ele><xsl:value-of select="name()"/></ele>
    </xsl:template>
    
    <xsl:template match="*"/>
    
    <xsl:template name="stdattr">
        <xsl:if test="@text:style-name">
            <xsl:attribute name="type"><xsl:value-of select="normalize-space(@text:style-name)"/></xsl:attribute>
        </xsl:if>        
    </xsl:template>    
</xsl:stylesheet>