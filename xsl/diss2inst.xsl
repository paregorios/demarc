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
    
    <xsl:output encoding="UTF-8" method="xml" indent="no"/>
    
    
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
        <xsl:variable name="eleend" select="$nextbkmk/../preceding-sibling::*[1]"/><xsl:text>
</xsl:text>
        <div type="instance" xml:id="{normalize-space(@text:name)}"><xsl:text>
</xsl:text>
        <idno type="original"><xsl:value-of select="$bkmkstart/@text:name"/></idno><xsl:text>
</xsl:text>
            <xsl:variable name="ns1" select="$elestart/following-sibling::*"/>
            <xsl:variable name="ns2" select="$eleend/preceding-sibling::*"/>
            <xsl:apply-templates select="$elestart | $ns1[count(. | $ns2)=count($ns2)] | $eleend" mode="instance"/>            
        </div><xsl:text>
</xsl:text>
    </xsl:template>
    
    <!-- text:h with style-name treInstance can become a plain head -->
    <xsl:template match="text:h[@text:style-name='treInstance']" mode="instance">
        <head><xsl:apply-templates mode="instance"/></head><xsl:text>
</xsl:text>
    </xsl:template>
    
    <!-- other headings preserve their style -->
    <xsl:template match="text:h" mode="instance">
        <xsl:element name="head">
            <xsl:call-template name="stdattr"/>
            <xsl:apply-templates mode="instance"/>
        </xsl:element><xsl:text>
</xsl:text>
    </xsl:template>

    <!-- capture Burton concordances -->
    <xsl:template match="text:p[starts-with(., 'Burton 2000')]" mode="instance">
        <p><bibl><ptr ref="dbib:burton-2000"/><xsl:text> </xsl:text><xsl:value-of select="normalize-space(substring-after(., 'Burton 2000, '))"/></bibl></p><xsl:text>
</xsl:text>
    </xsl:template>

    <!-- capture dates -->
    <xsl:template match="text:p[starts-with(., 'Date(s):')]" mode="instance">
        <p>Date(s): <date><xsl:value-of select="normalize-space(substring-after(., 'Date(s): '))"/></date></p><xsl:text>
</xsl:text>        
    </xsl:template>
    
    <!-- bold -->
    <xsl:template match="text:span[@text:style-name='treBold']" mode="instance">
        <hi rend="bold"><xsl:apply-templates mode="instance"/></hi>
    </xsl:template>
    
    <!-- foreign -->
    <xsl:template match="text:span[@text:style-name='T36']" mode="instance">
        <foreign rend="italic"><xsl:apply-templates mode="instance"/></foreign>
    </xsl:template>
    <xsl:template match="text:span[@text:style-name='treLatin']" mode="instance">
        <foreign xml:lang="la"><xsl:apply-templates mode="instance"/></foreign>
    </xsl:template>
    <xsl:template match="text:span[@text:style-name='treGreek']" mode="instance">
        <foreign xml:lang="grc"><xsl:apply-templates mode="instance"/></foreign>
    </xsl:template>
    
    <!-- terms -->
    <xsl:template match="text:span[@text:style-name='treTerm']" mode="instance">
        <seg type="term"><xsl:apply-templates mode="instance"/></seg>
    </xsl:template>
    
    <!-- personal names -->
    <xsl:template match="text:span[@text:style-name='trePerson']" mode="instance">
        <persName><xsl:apply-templates mode="instance"/></persName>
    </xsl:template>
    
    <!-- emperor's names -->
    <xsl:template match="text:span[@text:style-name='treEmperor']" mode="instance">
        <persName type="emperor"><xsl:apply-templates mode="instance"/></persName>
    </xsl:template>
    <xsl:template match="text:span[@text:style-name='treEmperorStealth']" mode="instance">
        <persName type="emperor" rend="normal"><xsl:apply-templates mode="instance"/></persName>
    </xsl:template>
    
    
    
    <!-- placenames -->
    <xsl:template match="text:span[@text:style-name='trePlaceAncient']" mode="instance">
        <placeName type="ancient"><xsl:apply-templates mode="instance"/></placeName>
    </xsl:template>
    <xsl:template match="text:span[@text:style-name='trePlaceModern']" mode="instance">
        <placeName type="modern"><xsl:apply-templates mode="instance"/></placeName>
    </xsl:template>
    
    <!-- footnotes -->
    <xsl:template match="text:span[@text:style-name='Footnote_20_Symbol']" mode="instance">
        <xsl:apply-templates mode="instance"/>
    </xsl:template>
    <xsl:template match="text:note" mode="instance">
        <xsl:element name="note">
            <xsl:if test="text:note-citation">
                <xsl:attribute name="n" select="normalize-space(text:note-citation)"/>
            </xsl:if>
            <xsl:apply-templates select="text:note-body" mode="instance"/>
        </xsl:element>        
    </xsl:template>
    <xsl:template match="text:note-body" mode="instance">
        <xsl:apply-templates mode="instance"/>
    </xsl:template>
    <xsl:template match="text:p[@text:style-name='Footnote' ]" mode="instance">
        <xsl:choose>
            <xsl:when test="count(../text:p) &gt; 1">
                <xsl:message>damn</xsl:message>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="instance"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <!-- any other kind of span element -->
    <xsl:template match="text:span" mode="instance">
        <xsl:element name="seg">
            <xsl:call-template name="stdattr"/>
            <xsl:apply-templates mode="instance"/>
        </xsl:element>
    </xsl:template>
    
    
    <!-- suppress everything related to document presentation -->
    <xsl:template match="text:h[@text:style-name='treDocument']" mode="instance"/>
    <xsl:template match="text:p[@text:style-name='treText']" mode="instance"/>
    <xsl:template match="text:p[@text:style-name='treTranslation']" mode="instance"/>
    
    <!-- suppress bookmarks -->
    <xsl:template match="text:bookmark-start | text:bookmark-end" mode="instance"/>
    
    <!-- suppress seg type=40, which was hidden text -->
    <xsl:template match="text:span[@text:style-name='T40']" mode="instance"/>
    
    <!-- regular paragraphs -->
    <xsl:template match="text:p" mode="instance">
        <xsl:element name="p">
            <xsl:call-template name="stdattr"/>
            <xsl:apply-templates mode="instance"/>
        </xsl:element><xsl:text>
</xsl:text>        
    </xsl:template>
    
    
    <!-- traps -->
    
    <xsl:template match="*" mode="instance">
        <ele><xsl:value-of select="name()"/></ele>
    </xsl:template>
    
    <xsl:template match="*"/>
    
    <xsl:template match="text()" mode="instance">
        <xsl:choose>
            <xsl:when test="substring(., 1, 1) = ' ' and substring(., string-length(.), 1) = ' '">
                <xsl:text> </xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text> </xsl:text>
            </xsl:when>
            <xsl:when test="substring(., 1, 1) = ' '">
                <xsl:text> </xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text></xsl:text>
            </xsl:when>
            <xsl:when test="substring(., string-length(.), 1) = ' '">
                <xsl:text></xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text> </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text></xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text></xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="stdattr">
        <xsl:choose>
            <xsl:when test="@text:style-name='treParaIndent'">
                <xsl:attribute name="rend">indent</xsl:attribute>
            </xsl:when>
            <xsl:when test="@text:style-name">
                <xsl:attribute name="type"><xsl:value-of select="normalize-space(@text:style-name)"/></xsl:attribute>
            </xsl:when>        
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>    
    
    
</xsl:stylesheet>