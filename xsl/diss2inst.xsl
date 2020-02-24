<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:xd="http://www.oxygenxml.com/ns/doc/xsl"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xd text"
    version="3.0">
    <xd:doc scope="stylesheet">
        <xd:desc>
            <xd:p><xd:b>Created on:</xd:b> May 23, 2012</xd:p>
            <xd:p><xd:b>Last modified on:</xd:b> May 23, 2012</xd:p>
            <xd:p><xd:b>Author:</xd:b> Tom Elliott</xd:p>
            <xd:p>This stylsheet is intended to extract basic informations about "instances" from the elliottDiss.xml file in such a way that stable URIs and other valuable linked data resources can be generated therefrom (maybe even fully-marked up text in TEI). Note that INST and DOC numbers are primary keys from an old database; they do not reflect the order or numeration in which these "instances" and "documents" were presented in the dissertation. Both sets of identifiers will need to be kept. Right now some of the elements used in serializing the output are stolen from the TEI.</xd:p>
        </xd:desc>
    </xd:doc>
    
    <xsl:output encoding="UTF-8" method="xml" indent="no"/>
    <xsl:output encoding="UTF-8" indent="true" method="xml" name="tei" /> 
    
    <xsl:template match="/">
            <xsl:apply-templates select="//text:bookmark-start[contains(@text:name, 'INST')]">
                <xsl:sort select="substring-after(@text:name, 'INST')" data-type="number"/>
            </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template  match="text:bookmark-start[contains(@text:name, 'INST') and not(contains(@text:name, '_'))]">
        <xsl:variable name="bkmkstart" select="."/>
        <xsl:variable name="bkmkend" select="following::text:bookmark-end[@text:name = $bkmkstart/@text:name]"/>
        <xsl:variable name="nextbkmk" select="$bkmkend/following::text:bookmark-start[contains(@text:name, 'INST') and not(contains(@text:name, '_'))][1]"/>
        <xsl:variable name="elestart" select=".."/>
        <xsl:variable name="eleend" select="$nextbkmk/../preceding-sibling::*[1]"/>
        <xsl:variable name="inumber" select="$bkmkstart/@text:name"/>
        <xsl:result-document format="tei" href="../output/{lower-case($inumber)}.xml">
            <div type="instance" xml:id="{normalize-space(@text:name)}">
                <xsl:variable name="ns1" select="$elestart/following-sibling::*"/>
                <xsl:variable name="ns2" select="$eleend/preceding-sibling::*"/>
                <xsl:apply-templates select="$elestart | $ns1[count(. | $ns2) = count($ns2)] | $eleend" mode="instance"/>
                <xsl:apply-templates select="following::text:bookmark-start[starts-with(@text:name, 'DOC')]" mode="documents">
                    <xsl:with-param name="inumber" select="$inumber"/>
                </xsl:apply-templates>
            </div>
        </xsl:result-document>
    </xsl:template>
    
    <xsl:template match="text:bookmark-start[starts-with(@text:name, 'DOC')]" mode="documents">
        <xsl:param name="inumber"/>
        <xsl:variable name="fudge" select="preceding::text:bookmark-start[contains(@text:name, 'INST')]"/>
        <xsl:if test="contains(preceding::text:bookmark-start[contains(@text:name, 'INST')][1]/@text:name, $inumber)">
            <!-- we are still inside the range for the current instance -->
            <xsl:variable name="bkmkstart" select="."/>
            <xsl:variable name="bkmkend" select="following::text:bookmark-end[@text:name = $bkmkstart/@text:name]"/>
            <xsl:variable name="nextbkmk" select="$bkmkend/following::text:bookmark-start[contains(@text:name, 'DOC')][1]"/>
            <xsl:variable name="elestart" select=".."/>
            <xsl:variable name="eleend" select="$nextbkmk/../preceding-sibling::*[1]"/>
            <xsl:variable name="dnumber" select="$bkmkstart/@text:name"/>
            <div type="document" xml:id="{normalize-space($dnumber)}">
                <xsl:variable name="ns1" select="$elestart/following-sibling::*"/>
                <xsl:variable name="ns2" select="$eleend/preceding-sibling::*"/>
                <xsl:apply-templates select="$elestart | $ns1[count(. | $ns2) = count($ns2)] | $eleend" mode="documents"/>                
            </div>            
        </xsl:if>
    </xsl:template>
    
    <!-- text:h with style-name treInstance can become a plain head -->
    <xsl:template match="text:h[@text:style-name='treInstance']" mode="instance">
        <head><xsl:apply-templates mode="instance"/></head>
    </xsl:template>
    
    <xsl:template match="text:h[@text:style-name='treDocument']" mode="documents">
        <xsl:variable name="refstring" select="normalize-space(string-join(./text()))"/>
        <xsl:comment><xsl:value-of select="$refstring"/></xsl:comment>        
        <head>
            <xsl:value-of select="normalize-space(text:span[@text:style-name='T40'])"/>
            <xsl:text> </xsl:text>
            <xsl:for-each select="$refstring">
                <xsl:call-template name="refstringcleaner"/>
            </xsl:for-each>
            <xsl:text>.</xsl:text>
        </head>
    </xsl:template>
    <xsl:template name="refstringcleaner">
        <xsl:param name="preferred">no</xsl:param>
        <xsl:variable name="refstring" select="normalize-space(.)"/>
        <xsl:if test="$refstring != ''">
            <xsl:choose>
                <xsl:when test="contains($refstring, 'See also')">
                    <xsl:variable name="parts" select="tokenize($refstring, 'See also')"/>
                    <xsl:for-each select="$parts[1]">
                        <xsl:call-template name="refstringcleaner"/>
                    </xsl:for-each>
                    <xsl:text>. See also: </xsl:text>
                    <xsl:for-each select="$parts[2]">
                        <xsl:call-template name="refstringcleaner"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="contains($refstring, ';')">
                    <xsl:for-each select="tokenize($refstring, ';')">
                        <xsl:call-template name="refstringcleaner"/>
                        <xsl:if test="position() != last()">
                            <xsl:text>; </xsl:text>
                        </xsl:if>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="starts-with($refstring, ':')">
                    <xsl:variable name="cleaned" select="replace($refstring, ':', '')"/>
                    <xsl:for-each select="$cleaned">
                        <xsl:call-template name="refstringcleaner"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="ends-with($refstring, '.')">
                    <xsl:variable name="cleaned" select="substring($refstring, 1, string-length($refstring)-1)"/>
                    <xsl:for-each select="$cleaned">
                        <xsl:call-template name="refstringcleaner"/>
                    </xsl:for-each>
                </xsl:when>
                <xsl:when test="starts-with($refstring, '*')">
                    <xsl:variable name="cleaned" select="replace($refstring, '\*', '')"/>
                    <xsl:for-each select="$cleaned">
                        <xsl:call-template name="refstringcleaner">
                            <xsl:with-param name="preferred">yes</xsl:with-param>
                        </xsl:call-template>
                    </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                    <bibl>
                        <xsl:if test="$preferred='yes'">
                            <xsl:attribute name="type">preferred</xsl:attribute>
                        </xsl:if>
                        <xsl:value-of select="$refstring"/>
                    </bibl>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:if>
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
    <xsl:template match="text:p[starts-with(normalize-space(.), 'Burton 2000')]" mode="instance">
        <p><bibl><ptr target="dbib:burton-2000"/><xsl:text> </xsl:text><xsl:value-of select="normalize-space(substring-after(normalize-space(.), 'Burton 2000,'))"/></bibl></p><xsl:text>
</xsl:text>
    </xsl:template>

    <!-- capture dates -->
    <xsl:template match="text:p[starts-with(., 'Date(s):')]" mode="instance">
        <p>Date(s): <date><xsl:value-of select="normalize-space(substring-after(., 'Date(s):'))"/></date></p><xsl:text>
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
            <xsl:if test="@text:id">
                <xsl:attribute name="xml:id" select="@text:id"/>
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
    
    <!-- cross-references -->
    <xsl:template match="text:bookmark-ref[starts-with(@text:ref-name, 'DOC')]" mode="instance">
        <ref target="ddoc:{substring-after(@text:ref-name, 'DOC')}"><bibl><biblScope><xsl:value-of select="."/></biblScope> (<title type="short">Elliott 2004</title>)</bibl></ref>
    </xsl:template>
    <xsl:template match="text:bookmark-ref[starts-with(@text:ref-name, 'INST')]" mode="instance">
        <ref target="#{@text:ref-name}"><bibl><biblScope><xsl:value-of select="."/></biblScope> (<title type="short">Elliott 2004</title>)</bibl></ref>
    </xsl:template>
    <xsl:template match="text:bookmark-ref[starts-with(@text:ref-name, '_Ref')]" mode="instance">
        <bibl><biblScope type="page"><xsl:value-of select="."/></biblScope> (<title type="short">Elliott 2004</title>)</bibl>
    </xsl:template>
    <xsl:template match="text:bookmark-ref" mode="instance">
        <ref type="trouble" target="{@text:ref-name}"><bibl><biblScope><xsl:value-of select="."/></biblScope> (<title type="short">Elliott 2004</title>)</bibl></ref>
    </xsl:template>
    <xsl:template match="text:note-ref" mode="instance">
        <bibl>
            <ptr target="dbib:elliott-2004"/> 
            <biblScope unit="note"><xsl:value-of select="."/></biblScope>
            <biblScope unit="ref-name"><xsl:value-of select="@text:ref-name"/></biblScope>
        </bibl>
    </xsl:template>
    
    <!-- lists -->
    <xsl:template match="text:list" mode="instance">
        <ul><xsl:text>
</xsl:text>
            <xsl:apply-templates mode="instance"/>
        </ul><xsl:text>
</xsl:text>
    </xsl:template>
    <xsl:template match="text:list-item" mode="instance">
        <xsl:choose>
            <xsl:when test="text:p">
                <li><xsl:apply-templates select="text:p/node()" mode="instance"/></li><xsl:text>
</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                OH CRAP
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
    
    
    <!-- suppress everything related to document presentation for instance mode -->
    <xsl:template match="text:h[@text:style-name='treDocument']" mode="instance"/>
    <xsl:template match="text:p[@text:style-name='treText']" mode="instance"/>
    <xsl:template match="text:p[@text:style-name='treBlock']" mode="instance"/>
    <xsl:template match="text:p[@text:style-name='treTranslation']" mode="instance"/>
    
    <!-- suppress bookmarks -->
    <xsl:template match="text:bookmark-start | text:bookmark-end" mode="instance"/>
    
    <!-- suppress seg type=40, which was hidden text -->
    <xsl:template match="text:span[@text:style-name='T40']" mode="instance"/>
    
    <!-- suppress text:s which seems to have been a hack for keeping space between note numbers and note content -->
    <xsl:template match="text:s" mode="instance"/>
    
    <!-- regular paragraphs -->
    <xsl:template match="text:p" mode="instance">
        <xsl:element name="p">
            <xsl:call-template name="stdattr"/>
            <xsl:choose>
                <xsl:when test="@text:style-name = 'treDisputeStatement'">
                    <seg type="instance-description">
                        <xsl:apply-templates mode="instance"/>
                    </seg>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates mode="instance"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    
    <!-- traps -->
    
    <xsl:template match="*" mode="instance">
        <ele><xsl:value-of select="name()"/></ele>
    </xsl:template>
    
    <xsl:template match="*" mode="documents"/>
    
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
            <xsl:when test="@text:style-name='treParaIndent'"/>
            <xsl:when test="@text:style-name='treDisputeStatement'"/>
            <xsl:when test="@text:style-name">
                <xsl:attribute name="type"><xsl:value-of select="normalize-space(@text:style-name)"/></xsl:attribute>
            </xsl:when>        
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>    
    
    
</xsl:stylesheet>