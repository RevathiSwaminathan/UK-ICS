<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="2.0">

    <xsl:template match="table | tbody">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="@* | node()"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="table/@*[not(name()='frame')] | row/@*"/>
    
    <xsl:template match="table/@frame">
        <xsl:choose>
            <xsl:when test="$selectorID='dictionary'"/>
            <xsl:otherwise>
                <xsl:attribute name="frame" select="'all'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="tgroup">
        <!--<xsl:variable name="cols">
            <xsl:for-each-group select="self::tgroup//row" group-by="entry">
                <xsl:value-of select="count(current-group()/entry/node())"/>
                <xsl:text>,</xsl:text>
            </xsl:for-each-group>
        </xsl:variable>-->
        
        <!-- To find which entries has content. Because colspec is created for the active entries only. And the empty entries are suppressed in LA output file.-->
        <xsl:variable name="active_entries">
            <xsl:for-each-group select="self::tgroup//row" group-adjacent="self::row">
                <xsl:for-each select="current-group()/entry">
                    <xsl:if test="self::entry != ''">
                        <xsl:value-of select="position()"/>
                        <xsl:text>,</xsl:text>
                    </xsl:if>
                </xsl:for-each>

            </xsl:for-each-group>
        </xsl:variable>

        <!-- The $active_entries has all the active entry count for all the rows. So to get the distinct values of the active entries the below $distinct_entries is created.-->
        <xsl:variable name="distinct_entries">
            <xsl:value-of select="distinct-values(tokenize($active_entries, ','))"/>
        </xsl:variable>
        

        <!-- To find the number of active entries-->
        <xsl:variable name="Maxcols">
            <!--<xsl:value-of select="max(tokenize(substring-after($cols, ','), ','))"/>-->
            <!-- A empty space is created as the last content of $distinct_entries because of this we are getting the actual count + 1. so we are reducing the count by 1  -->
            <xsl:value-of select="count(tokenize($distinct_entries, ' ')) - 1"/>
        </xsl:variable>

        <xsl:element name="{name()}">
            <xsl:attribute name="cols">
                <xsl:value-of select="$Maxcols"/>
            </xsl:attribute>
            <xsl:attribute name="colsep" select="1"/>
            <xsl:attribute name="rowsep" select="1"/>

            <!-- To create colspec element based on the cols count -->
            <xsl:variable name="colspec_type">
                
                <xsl:choose>
                    <xsl:when test="substring(child::colspec[1]/@colwidth,string-length(child::colspec[1]/@colwidth),1)='*'">
                        <xsl:value-of select="'*'"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="'in'"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>

            <!-- In input, the colspec/@colwidth is in inches, to convert this into pixel, multiply the value with 1440 and append * in the end  -->
            <xsl:variable name="colspec">
                <xsl:choose>
                    <xsl:when test="$selectorID='dictionary'">
                        <xsl:for-each select="self::tgroup/colspec">
                            <xsl:if test="position() &lt;= $Maxcols">
                                <xsl:variable name="count" select="position()" as="xs:integer"/>
                                <!-- To calculate pixel value - Strip the 'in' in the end of colspec/@colwidth value and multiply it by 1440 and append * in the end -->
                                <xsl:value-of
                                    select="concat(number(replace(parent::tgroup/colspec[number(tokenize($distinct_entries, ' ')[$count])]/@colwidth, 'in', '')) * 1440, '*')"/>
                                <xsl:text>,</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:for-each select="self::tgroup/colspec">
                            <xsl:if test="position() &lt;= $Maxcols">
                                <xsl:variable name="count" select="position()" as="xs:integer"/>
                                <!-- To calculate pixel value - Strip the 'in' in the end of colspec/@colwidth value and multiply it by 1440 and append * in the end -->
                                <xsl:choose>
                                    <xsl:when test="$colspec_type='*'">
                                        <xsl:value-of
                                            select="parent::tgroup/colspec[number(tokenize($distinct_entries, ' ')[$count])]/@colwidth"/> 
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <xsl:value-of
                                            select="concat(number(replace(parent::tgroup/colspec[number(tokenize($distinct_entries, ' ')[$count])]/@colwidth, 'in', '')) * 1440, '*')"/>
                                    </xsl:otherwise>
                                </xsl:choose>
                                
                                
                                <xsl:text>,</xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                    </xsl:otherwise>
                </xsl:choose>
               
            </xsl:variable>

            <!-- To create colspec element based on the cols count -->
            <xsl:for-each select="1 to $Maxcols">
                <colspec colname="{current()}" colwidth="{tokenize($colspec,',')[current()]}"/>
            </xsl:for-each>

            <!-- To create thead -->
            <xsl:for-each-group select="self::tgroup//row" group-adjacent="self::row">
                <xsl:for-each select="current-group()">
                    <xsl:if test="current-group()/entry/text() = 'TABLE'">
                        <thead>
                            <xsl:apply-templates select="." mode="thead"/>

                        </thead>
                    </xsl:if>
                </xsl:for-each>
            </xsl:for-each-group>

            <xsl:apply-templates select="node()"/>

        </xsl:element>
    </xsl:template>

    <xsl:template match="colspec"/>

    <xsl:template match="row" mode="thead">
        <xsl:element name="{name()}">
            <xsl:apply-templates select="node()" mode="thead"/>
        </xsl:element>
    </xsl:template>

    <xsl:template match="entry" mode="thead">
        <xsl:variable name="active_entries">
            <xsl:for-each-group select="ancestor::table//row" group-adjacent="self::row">
                <xsl:for-each select="current-group()/entry">
                    <xsl:if test="self::entry != ''">
                        <xsl:value-of select="position()"/>
                        <xsl:text>,</xsl:text>
                    </xsl:if>
                </xsl:for-each>

            </xsl:for-each-group>
        </xsl:variable>

        <!-- The $active_entries has all the active entry count for all the rows. So to get the distinct values of the active entries the below $distinct_entries is created.-->
        <xsl:variable name="distinct_entries">
            <xsl:value-of select="distinct-values(tokenize($active_entries, ','))"/>
        </xsl:variable>

        <!-- To find the number of active entries-->
        <xsl:variable name="Maxcols">
            <!--<xsl:value-of select="max(tokenize(substring-after($cols, ','), ','))"/>-->
            <!-- A empty space is created as the last content of $distinct_entries because of this we are getting the actual count + 1. so we are reducing the count by 1  -->
            <xsl:value-of select="count(tokenize($distinct_entries, ' ')) - 1"/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="self::entry/node()">
                <xsl:element name="{name()}">
                    <xsl:attribute name="namest" select="1"/>
                    <xsl:attribute name="nameend" select="$Maxcols"/>
                    <xsl:attribute name="colsep" select="'0'"/>
                    <xsl:attribute name="rowsep" select="'0'"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="row">

        <xsl:choose>
            <xsl:when test="self::row//entry/text() = 'TABLE'"/>
            <xsl:when test="self::row//entry/node()">
                <xsl:element name="{name()}">
                    <xsl:variable name="count_of_valid_entry" as="xs:integer">
                        <xsl:value-of select="count(self::row//entry/node())"/>
                    </xsl:variable>

                    <xsl:variable name="active_entries">
                        <xsl:for-each-group select="ancestor::table//row" group-adjacent="self::row">
                            <xsl:for-each select="current-group()/entry">
                                <xsl:if test="self::entry != ''">
                                    <xsl:value-of select="position()"/>
                                    <xsl:text>,</xsl:text>
                                </xsl:if>
                            </xsl:for-each>

                        </xsl:for-each-group>
                    </xsl:variable>

                    <!-- The $active_entries has all the active entry count for all the rows. So to get the distinct values of the active entries the below $distinct_entries is created.-->
                    <xsl:variable name="distinct_entries">
                        <xsl:value-of select="distinct-values(tokenize($active_entries, ','))"/>
                    </xsl:variable>

                    <!-- To find the number of active entries-->
                    <xsl:variable name="count_of_max_entry" as="xs:integer">
                        <!-- A empty space is created as the last content of $distinct_entries because of this we are getting the actual count + 1. so we are reducing the count by 1  -->
                        <xsl:value-of select="count(tokenize($distinct_entries, ' ')) - 1"/>
                    </xsl:variable>

                    <!-- Calculate count of empty entries to be created to tally the cols count (This is to ensure proper alignment of all the rows inside table) -->
                    <xsl:variable name="diff_count" as="xs:integer"
                        select="$count_of_max_entry - $count_of_valid_entry"/>

                    <xsl:choose>
                        <xsl:when test="$diff_count > 0">
                            <xsl:for-each select="1 to $diff_count">
                                <entry>
                                    <xsl:if test="$selectorID='dictionary' or $docinfo.selector='Transcripts'">
                                        <xsl:attribute name="colsep" select="'0'"/>
                                        <xsl:attribute name="rowsep" select="'0'"/>
                                    </xsl:if>
                                </entry>
                            </xsl:for-each>
                        </xsl:when>
                    </xsl:choose>


                    <xsl:apply-templates select="@* | node()"/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="entry">
        <xsl:choose>
            <xsl:when test="self::entry/node()">
                <xsl:element name="{name()}">
                    <xsl:if test="$selectorID = 'dictionary' or $docinfo.selector='Transcripts'">
                        <xsl:attribute name="colsep" select="'0'"/>
                        <xsl:attribute name="rowsep" select="'0'"/>
                    </xsl:if>
                    <xsl:apply-templates select="node()"/>
                </xsl:element>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


</xsl:stylesheet>