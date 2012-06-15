<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:t="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    exclude-result-prefixes="xs"
    version="2.0">
    
    <xsl:output method="text"/>
    <xsl:template match="/">
        <xsl:text>@prefix foaf: &lt;http://xmlns.com/foaf/0.1/&gt; .
</xsl:text>
        <xsl:text>@prefix bio: &lt;http://vocab.org/bio/0.1/olb/&gt; .     
        
</xsl:text>
        <xsl:apply-templates select="//t:div"/>
    </xsl:template>
    
    <xsl:template match="t:div">
        <xsl:text>&lt;http://paregorios.org/demarc/people/</xsl:text>
        <xsl:call-template name="generate-id"/>
        <xsl:text>&gt; a foaf:Person ,
</xsl:text>

        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="t:p[@t:style-name='trePersonEntryHead']">
        <xsl:text>    foaf:name "</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>" ,</xsl:text>
    </xsl:template>
    
    <xsl:template match="t:p[@t:style-name='trePersonEntryBody' and not(preceding-sibling::t:p[@t:style-name='trePersonEntryBody'])]">
        <xsl:text>    bio:olb "</xsl:text><xsl:value-of select="normalize-space(.)"/><xsl:text>" .</xsl:text>
    </xsl:template>
    
    <xsl:template match="*"/>
    
    <xsl:template name="generate-id">
        <xsl:variable name="raw" select="t:p[@t:style-name='trePersonEntryHead']"/>
        <xsl:value-of select="replace(replace(replace(replace(replace(replace(normalize-space(replace(lower-case($raw), '\[(.+)\]', '-')), '/s*\-*/s*', '-'), '[/W\)\(\?,\.]', ''), ' ' , '-'), '^\-+', ''), '\-+$', ''), '\-+', '-')"/>
    </xsl:template>
</xsl:stylesheet>