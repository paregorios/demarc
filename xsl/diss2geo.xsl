<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math"
    xmlns:text="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    xmlns:t="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs math text"
    version="3.0">
    
    <xsl:template match="/">
        <!-- <xsl:apply-templates select="//text:span[contains(@text:style-name, 'Place')]"/> -->
        <xsl:variable name="toponyms">
            <xsl:for-each select="//text:span[contains(@text:style-name, 'Place')]">
                <xsl:variable name="raw" select="normalize-space(text())"/>
                <xsl:call-template name="clean-toponym">
                    <xsl:with-param name="raw" select="$raw"/>
                </xsl:call-template>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values(tokenize($toponyms, ','), 'http://www.w3.org/2013/collation/UCA?strength=primary;normalization=yes')">
            <xsl:sort/> "<xsl:value-of select="."/>"<xsl:text>
</xsl:text>
        </xsl:for-each>
        <!-- 
        <xsl:variable name="toponyms">
            <xsl:for-each select="$place-strings">
                <xsl:message><xsl:value-of select="."/></xsl:message>
                <xsl:choose>
                    <xsl:when test="count(.)=1">
                        <xsl:value-of select="normalize-space(.)"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:message><xsl:value-of select="normalize-space(.)"/></xsl:message>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>
        <xsl:for-each select="distinct-values($toponyms)">
            <xsl:sort></xsl:sort>
            <xsl:value-of select="."/><xsl:text> 
</xsl:text>
        </xsl:for-each> -->
    </xsl:template>
    
    <xsl:template match="text:span[@text:style-name]">
        Toponym: <xsl:value-of select="normalize-space(.)"/>
        <xsl:variable name="ancestry">
            <xsl:for-each select="ancestor-or-self::*">
                <xsl:value-of select="name(.)"/><xsl:text> | </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        Ancestry: <xsl:value-of select="$ancestry"/><xsl:text>
</xsl:text>
        <xsl:variable name="chapter" select="preceding::text:p[starts-with(@text:style-name, 'P') and starts-with(lower-case(normalize-space(.)), 'chapter')][1]"/>
        <xsl:variable name="chapter-subtitle" select="$chapter/following-sibling::text:p[1]"/>
        <xsl:variable name="subtitle-string" select="normalize-space($chapter-subtitle/text())"/>
        Chapter Title: <xsl:value-of select="normalize-space($chapter)"/>: <xsl:value-of select="$subtitle-string"/>
        <xsl:if test="contains(lower-case($subtitle-string), 'evidentiary catalog')">
            <xsl:variable name="instance-heading" select="(self::text:h[@text:style-name='treInstance']|preceding::text:h[@text:style-name='treInstance'][1])"/>
            <xsl:variable name="instance-key" select="$instance-heading/text:bookmark-start[contains(@text:name, 'INST')]/@text:name"/>
            Instance Heading: <xsl:value-of select="normalize-space(substring-after(normalize-space($instance-heading), concat($instance-key, ':')))"/>
            Instance Key: <xsl:value-of select="$instance-key"/>
            Instance Number: <xsl:value-of select="count(preceding::text:h[@text:style-name='treInstance'])"/>
            <xsl:variable name="document-heading" select="(self::text:h[@text:style-name='treDocument']|preceding::text:h[@text:style-name='treDocument'][1])"/>
            <xsl:variable name="document-key" select="$document-heading/text:bookmark-start[contains(@text:name, 'DOC')]/@text:name"/>
            Document Heading: <xsl:value-of select="normalize-space(substring-after(normalize-space($document-heading), concat($document-key, ':')))"/>
            Document Key: <xsl:value-of select="$document-key"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="clean-toponym">
        <xsl:param name="raw"/>
        <xsl:variable name="apos">$apos;</xsl:variable>
        <xsl:choose>
            <xsl:when test="contains($raw, ',')">
                <xsl:for-each select="tokenize($raw, ',')">
                    <xsl:call-template name="clean-toponym">
                        <xsl:with-param name="raw" select="normalize-space(.)"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:when test="ends-with($raw, '.') and not(ends-with($raw, '...'))">
                <xsl:call-template name="clean-toponym">
                    <xsl:with-param name="raw" select="substring($raw, 1, string-length($raw)-1)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="ends-with($raw, '?') or ends-with($raw, $apos) or ends-with($raw, '’')">
                <xsl:call-template name="clean-toponym">
                    <xsl:with-param name="raw" select="substring($raw, 1, string-length($raw)-1)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="ends-with($raw, concat($apos, 's')) or ends-with($raw, '’s')">
                <xsl:call-template name="clean-toponym">
                    <xsl:with-param name="raw" select="substring($raw, 1, string-length($raw)-2)"/>
                </xsl:call-template>
            </xsl:when> 
            <xsl:when test="contains($raw, '[') or contains($raw, '(')">
                <xsl:call-template name="clean-toponym">
                    <xsl:with-param name="raw" select="replace($raw, '[\[\]\()]', '')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="starts-with($raw, '*')">
                <xsl:call-template name="clean-toponym">
                    <xsl:with-param name="raw" select="substring($raw, 2, string-length($raw)-1)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$raw"/><xsl:text>,</xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>