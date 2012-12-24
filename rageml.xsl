<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:template match="/">
		<svg version="1.1" xmlns="http://www.w3.org/2000/svg">
			<rect fill="none" fill-opacity="1.0" height="48" stroke="rgb(0,0,0)" 
				stroke-opacity="1.0" stroke-width="2.5" width="36" x="6" y="12"></rect>
			<xsl:for-each select="rage-comic/panel">
				<rect x="10" y="10" width="48" height="36" fill="red" stroke="black" />
			</xsl:for-each>
			<!--<xsl:apply-templates />-->
		</svg>
	</xsl:template>
	<!--<xsl:template match="panel">
		<rect x="10" y="10" width="48" height="36" fill="none" stroke="rgb(0,255,0)"
			fill-opacity="1.0" stroke-opacity="1.0" />
	</xsl:template>-->
</xsl:stylesheet>
