<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet
  xmlns:Exslt.ExsltCommon="urn:Exslt.ExsltCommon"
  xmlns:Exslt.ExsltDatesAndTimes="urn:Exslt.ExsltDatesAndTimes"
  xmlns:Exslt.ExsltMath="urn:Exslt.ExsltMath"
  xmlns:Exslt.ExsltRegularExpressions="urn:Exslt.ExsltRegularExpressions"
  xmlns:Exslt.ExsltStrings="urn:Exslt.ExsltStrings"
  xmlns:Exslt.ExsltSets="urn:Exslt.ExsltSets" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                version="1.0"
  >

  <xsl:output method="text"/>
  <xsl:template match="/">
    <xsl:for-each select="bibliography/entry">
      <xsl:choose>
        <xsl:when test="@type='ARTICLE'">
          <xsl:call-template name="article">
            <xsl:with-param name="entryNode" select="."/>
          </xsl:call-template>    
        </xsl:when>
      </xsl:choose>
      <xsl:text>&#10;</xsl:text>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="article">
    <xsl:param name="entryNode"/>

    <xsl:text>\bibitem{</xsl:text>
    <xsl:call-template name="author">
      <xsl:with-param name="authorNode" select="$entryNode/authors/author[1]"/>
    </xsl:call-template>
    <xsl:text> et al.(</xsl:text>
    <xsl:value-of select="$entryNode/year"/>
    <xsl:text>)}&#10;</xsl:text>

    <!-- 作者名 -->

    <xsl:text>\textsc{</xsl:text>
    <xsl:for-each select="$entryNode/authors/author[position() &lt; 3]">
      <xsl:call-template name="author">
        <xsl:with-param name="authorNode" select="."/>
      </xsl:call-template>
      <xsl:if test="position()!=last()">
        <xsl:text>, </xsl:text>  
      </xsl:if>
      <xsl:if test="position()=last()">
        <xsl:text>} </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <!-- 作者数是否超过3个而要加上et al. -->

    <xsl:if test="count($entryNode/authors/author) &gt; 3">
      <xsl:text> et al.</xsl:text>
    </xsl:if>
    <xsl:text>&#10;</xsl:text>
    <!-- 标题与文献类型标识 -->
    <xsl:text>\newblock </xsl:text>
    <xsl:value-of select="$entryNode/title"/>
    <xsl:text>[J].&#10;</xsl:text>
    <!-- 杂志名 -->
    <xsl:text>\newblock </xsl:text>
    <xsl:value-of select="$entryNode/journal"/>
    <xsl:text>, </xsl:text>
    <!-- 日期 -->
    <xsl:value-of select="$entryNode/year"/>
    <xsl:text>, </xsl:text>
    <!-- 卷号 -->
    <xsl:value-of select="$entryNode/volume"/>
    <!-- 期号 -->
    <xsl:if test="$entryNode/number">
      <xsl:text>(</xsl:text>
      <xsl:text>)</xsl:text>
    </xsl:if>
    <!-- 页码 -->
    <xsl:text>:</xsl:text>
    <xsl:value-of select="$entryNode/pages"/>
    <xsl:text>&#10;</xsl:text>
  </xsl:template>
  
  <xsl:template name="author">
    <xsl:param name="authorNode"/>
    <xsl:value-of select="$authorNode/last"/>
    <xsl:text> </xsl:text>
    <xsl:value-of select="$authorNode/first/@short"/>
  </xsl:template>

  
 
</xsl:stylesheet>
