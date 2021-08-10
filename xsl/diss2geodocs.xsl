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
    
    <xsl:param name="toponym-type">Ancient</xsl:param>
    <xsl:output encoding="UTF-8" method="text"  />
    <xsl:template match="/">
        <!-- <xsl:apply-templates select="//text:span[contains(@text:style-name, 'Place')]"/> -->
            <xsl:for-each select="//text:span[@text:style-name=concat('trePlace', $toponym-type)]">
                <xsl:variable name="raw" select="normalize-space(text())"/>
                <xsl:variable name="cooked">
                    <xsl:call-template name="clean-toponym">
                        <xsl:with-param name="raw" select="$raw"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:variable name="chapter" select="preceding::text:p[starts-with(@text:style-name, 'P') and starts-with(lower-case(normalize-space(.)), 'chapter')][1]"/>
                <xsl:variable name="chapter-subtitle" select="$chapter/following-sibling::text:p[1]"/>
                <xsl:variable name="subtitle-string" select="normalize-space($chapter-subtitle/text())"/>
                <xsl:if test="contains(lower-case($subtitle-string), 'evidentiary catalog')">
                    <xsl:message><xsl:value-of select="$raw"/>: evidentiary</xsl:message>
                    <xsl:variable name="instance-heading" select="(self::text:h[@text:style-name='treInstance']|preceding::text:h[@text:style-name='treInstance'][1])"/>
                    <xsl:variable name="instance-key" select="$instance-heading/text:bookmark-start[contains(@text:name, 'INST')]/@text:name"/>
                    <xsl:variable name="document-heading" select="(self::text:h[@text:style-name='treDocument' and preceding::text:h[@text:style-name='treInstance'][1]/text:bookmark-start/@text:name=$instance-key]|preceding::text:h[@text:style-name='treDocument' and preceding::text:h[@text:style-name='treInstance'][1]/text:bookmark-start/@text:name=$instance-key])[1]"/>
                    <xsl:variable name="document-key" select="$document-heading/text:bookmark-start[contains(@text:name, 'DOC')]/@text:name"/>
                    <xsl:if test="$instance-key">
                        <xsl:message><xsl:text>    </xsl:text>instance key: <xsl:value-of select="$instance-key"/></xsl:message>
                        <xsl:text></xsl:text><xsl:value-of select="$raw"/><xsl:text></xsl:text>
                        <xsl:if test="not($raw = $cooked)">
                            <xsl:text> = </xsl:text>
                            <xsl:text></xsl:text><xsl:value-of select="$cooked"/><xsl:text></xsl:text>
                        </xsl:if>
                        <xsl:text>
</xsl:text>
                        <xsl:text>Instance Key: </xsl:text><xsl:value-of select="$instance-key"/><xsl:text>
</xsl:text>
                    </xsl:if>
                </xsl:if>
            </xsl:for-each>
            

    </xsl:template>
    
    <xsl:template match="text:span[@text:style-name]">
        <xsl:param name="raw-toponym"/>
        <xsl:param name="cooked-toponym"/>
        <xsl:variable name="ancestry">
            <xsl:for-each select="ancestor-or-self::*">
                <xsl:value-of select="name(.)"/><xsl:text> | </xsl:text>
            </xsl:for-each>
        </xsl:variable>
        <xsl:variable name="chapter" select="preceding::text:p[starts-with(@text:style-name, 'P') and starts-with(lower-case(normalize-space(.)), 'chapter')][1]"/>
        <xsl:variable name="chapter-subtitle" select="$chapter/following-sibling::text:p[1]"/>
        <xsl:variable name="subtitle-string" select="normalize-space($chapter-subtitle/text())"/>
        <xsl:if test="contains(lower-case($subtitle-string), 'evidentiary catalog')">
            <xsl:variable name="instance-heading" select="(self::text:h[@text:style-name='treInstance']|preceding::text:h[@text:style-name='treInstance'][1])"/>
            <xsl:variable name="instance-key" select="$instance-heading/text:bookmark-start[contains(@text:name, 'INST')]/@text:name"/>
            <xsl:variable name="document-heading" select="(self::text:h[@text:style-name='treDocument']|preceding::text:h[@text:style-name='treDocument'][1])"/>
            <xsl:variable name="document-key" select="$document-heading/text:bookmark-start[contains(@text:name, 'DOC')]/@text:name"/>
            Toponym: <xsl:value-of select="normalize-space(.)"/>
            Ancestry: <xsl:value-of select="$ancestry"/><xsl:text>
</xsl:text>
            Instance Heading: <xsl:value-of select="normalize-space(substring-after(normalize-space($instance-heading), concat($instance-key, ':')))"/>
            Instance Key: <xsl:value-of select="$instance-key"/>
            Instance Number: <xsl:value-of select="count(preceding::text:h[@text:style-name='treInstance'])"/>
            Document Heading: <xsl:value-of select="normalize-space(substring-after(normalize-space($document-heading), concat($document-key, ':')))"/>
            Document Key: <xsl:value-of select="$document-key"/>
            Chapter Title: <xsl:value-of select="normalize-space($chapter)"/>: <xsl:value-of select="$subtitle-string"/>
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
                <xsl:value-of select="$raw"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>