<?xml version="1.0" encoding="utf-8" ?>
<stylesheet version="1.0" xmlns="http://www.w3.org/1999/XSL/Transform" 
		xmlns:svg="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">

	<output method="xml" version="1.0" encoding="utf-8"/>

	<variable name="PANEL_W" select="350" />
	<variable name="PANEL_H" select="330" />
	<variable name="BORDER_W" select="20" />
	<variable name="BORDER_H" select="20" />
	
	<!-- Root template -->
	<template match="/">
		<svg:svg version="1.1" width="{ $PANEL_W * 2 + $BORDER_W * 2 }" 
				height="{ ceiling(count(/rage-comic/panel) div 2) * $PANEL_H + $BORDER_H * 2}">
			<!--<apply-templates select="/rage-comic/panel" />-->
		</svg:svg>
	</template>
	
	<template name="test">
		<param name="data" />
		<svg:text x="20" y="20">
			<value-of select="$data" />
		</svg:text>
		
		<!--<for-each select="$data">
			<svg:text x="{@x}" y="{@y}">
				<value-of select="@text" />
			</svg:text>
		</for-each>-->
		
	</template>	
	
	
	<template name="panels">
	
		<param name="panelnode" />
		<param name="panelnum" />
		<param name="df-a-face" select="derp" /> <param name="df-a-sex" select="m" />
		<param name="df-b-face" select="derp" /> <param name="df-b-sex" select="m" />
		<param name="df-c-face" select="derp" /> <param name="df-c-sex" select="m" />
		<param name="df-d-face" select="derp" /> <param name="df-d-sex" select="m" />
		<param name="df-e-face" select="derp" /> <param name="df-e-sex" select="m" />
		
		<variable name="panelx" select="TODO" />
		<variable name="panely" select="TODO" />
		<variable name="charnodes" select="$panelnode/*[name()!='narration'
			and name()!='a-reply' and name()!='b-reply' and name()!='c-reply' 
			and name()!='d-reply' and name()!='e-reply']" />

		<for-each select="$charnodes">
			<sort select="concat(string(number(string-length(name()) &gt; 1)),name())" />
			<!-- character nodes with a-e first -->
			<!-- now position() should be ok for x positioning -->
			<!-- how to get face and sex of character? -->
			<!-- could use a string as a map, using substring-before/after:
				'|a:derp|b:trollface|c:rage|'
				substring-before(substring-after(s,'a:'),'|')  -->
		</for-each>

		<if test="$panelnode/a">
			<call-template name="character">
				<with-param name="x" select="$panelx + $PANEL_W div count($charnodes) * 0" />
				<with-param name="y" select="$panely" />
				<with-param name="width" select="$PANEL_W div count($charnodes)" />
				<with-param name="height" select="$PANEL_H" />
				<with-param name="lines" select="" />
				<with-param name="face"><choose>
					<when test="$panelnode/a/*"><value-of select="$panelnode/a/*/name()" /></when>
					<otherwise><value-of select="$def-a-face" /></otherwise></choose></with-param>
				<with-param name="sex" select="a-sex"><choose>
					<when test="$panelnode/a/@sex"><value-of select="$panelnode/a/@sex"/></when>
					<otherwise><value-of select="$def-a-sex" /></otherwise></choose></with-param>
			</call-template>			
		</if>
		<if test="$panelnode/b">
		
		</if>
		<if test="$panelnode/c">
		
		</if>
		<if test="$panelnode/d">
		</if>
		<if test="$panelnode/e">
		
		</if>
	
		<if test="$panelnode::following-sibling">
			<call-template name="panels">
				<with-param name="panelnode" select="$panelnode::following-sibling[1]" />	
				<with-param name="panelnum" select="$panelnum + 1" />
				<with-param name="df-a-face" select="$a-face" />
				<with-param name="df-a-sex" select="$a-sex" />
				<with-param name="df-b-face" select="$b-face" />
				<with-param name="df-b-sex" select="$b-sex" />
				<with-param name="df-c-face" select="$c-face" />
				<with-param name="df-c-sex" select="$c-sex" />
				<with-param name="df-d-face" select="$d-face" />
				<with-param name="df-d-sex" select="$d-sex" />
				<with-param name="df-e-face" select="$e-face" />
				<with-param name="df-e-sex" select="$e-sex" />
			</call-template>
		</if>
				
	</template>
	
	<!--<template name="character">
		<param name="x" />
		<param name="y" />
		<param name="width" />
		<param name="height" />
		<param name="lines" />
		<param name="face" />
		<param name="sex" />
		
		
	</template>-->
	
	<!-- Renders a single panel -->
	<!--<template match="panel">
		<variable name="panelnum" select="position() - 1" />
		<variable name="panelx" select="($panelnum mod 2) * $PANEL_W + $BORDER_W" />
		<variable name="panely" select="floor($panelnum div 2) * $PANEL_H + $BORDER_H" />
		<variable name="charnodes" select="derp|trollface" />
		<variable name="startnarrnode" select="*[position()=1 and name()='narration']" />
		<variable name="endnarrnode" select="*[position()=last() and name()='narration']" />
		<variable name="startnarrheight" select="boolean($startnarrnode) * 50" />
		<variable name="endnarrheight" select="boolean($endnarrnode) * 50" />
		<variable name="chartextlen">
			<call-template name="sum-lengths">
				<with-param name="nodes" select="$charnodes" />
			</call-template>
		</variable>
		<svg:rect x="{ $panelx }" y="{ $panely }" 
				width="{ $PANEL_W }" height="{ $PANEL_H }" stroke="black" 
				stroke-width="3" fill="white" fill-opacity="0.75"/>
		<if test="$startnarrnode">
			<call-template name="narration-text">
				<with-param name="x" select="$panelx + 10" />
				<with-param name="y" select="$panely + 10" />
				<with-param name="width" select="$PANEL_W - 20" />
				<with-param name="text" select="$startnarrnode/text()" />
			</call-template>
		</if>
		<call-template name="panel-characters">
			<with-param name="nodes" select="$charnodes" />
			<with-param name="numchars" select="count($charnodes)" />
			<with-param name="textlen" select="$chartextlen" />			
			<with-param name="x" select="$panelx" />
			<with-param name="y" select="$panely + $startnarrheight" />
			<with-param name="width" select="$PANEL_W" />
			<with-param name="height" select="$PANEL_H - $startnarrheight - $endnarrheight" />
		</call-template>
		<if test="$endnarrnode">
			<call-template name="narration-text">
				<with-param name="x" select="$panelx + 10" />
				<with-param name="y" select="$panely + $PANEL_H - $endnarrheight + 10" />
				<with-param name="width" select="$PANEL_W - 20" />
				<with-param name="text" select="$endnarrnode/text()" />
			</call-template>
		</if>
	</template>-->
	
	<!-- Invoked recursively to render characters in panel -->
	<!--<template name="panel-characters">
		<param name="nodes" />
		<param name="numchars" />
		<param name="textlen" />
		<param name="x" />
		<param name="y" />
		<param name="width" />
		<param name="height" />
		<param name="accum-len" select="0"/>
		
		<variable name="currnode" select="$nodes[1]" />
		
		<apply-templates select="$currnode">
			<with-param name="x" select="$x" />
			<with-param name="y" select="$y" />
			<with-param name="textfrac" select="$accum-len div $textlen" />
			<with-param name="width" select="$width div $numchars" />
			<with-param name="height" select="$height" />
		</apply-templates>
		
		<if test="count($nodes) &gt; 1">
			<call-template name="panel-characters">
				<with-param name="nodes" select="$nodes[position() &gt; 1]" />
				<with-param name="numchars" select="$numchars" />
				<with-param name="textlen" select="$textlen" />
				<with-param name="x" select="$x + $width div $numchars" />
				<with-param name="y" select="$y" />
				<with-param name="width" select="$width" />
				<with-param name="height" select="$height" />
				<with-param name="accum-len" select="$accum-len + string-length($currnode/text())" />
			</call-template>
		</if>
	</template>-->
	
	<!-- Renders a trollface dialogue line -->
	<!--<template match="trollface">
		<param name="x" />
		<param name="y" />
		<param name="width" />
		<param name="height" />
		<param name="textfrac" />
		<svg:image x="{ $x }" y="{ $y + $height * 0.5 }"
				width="{ $width }" height="{ $height * 0.5 }"
				xlink:href="images/trollface.png" />
		<call-template name="dialogue-text">
			<with-param name="x" select="$x + $width * 0.5" />
			<with-param name="y" select="$y + 25 + $height * 0.5 * $textfrac" />
			<with-param name="width" select="$width" />
			<with-param name="text" select="text()" />
		</call-template>
	</template>-->
	
	<!-- Renders a derpy guy dialogue line -->
	<!--<template match="derp">
		<param name="x" />
		<param name="y" />
		<param name="width" />
		<param name="height" />
		<param name="textfrac" />
		<svg:image x="{ $x }" y="{ $y + $height * 0.5 }"
				width="{ $width }" height="{ $height * 0.5 }"
				xlink:href="images/derp.png" />
		<call-template name="dialogue-text">
			<with-param name="x" select="$x + $width * 0.5" />
			<with-param name="y" select="$y + 25 + $height * 0.5 * $textfrac" />
			<with-param name="width" select="$width" />
			<with-param name="text" select="text()" />
		</call-template>
	</template>-->
	
	<!--<template match="challenge-accepted">
		<variable name="panelnum" select="count(ancestor::panel/preceding-sibling::*)" />
		<variable name="panelx" select="($panelnum mod 2) * $PANEL_W + $BORDER_W" />
		<variable name="panely" select="floor($panelnum div 2) * $PANEL_H + $BORDER_H" />
		<variable name="content">
			<choose>
				<when test="text()"><value-of select="text()" /></when>
				<otherwise><value-of select="'CHALLENGE ACCEPTED'" /></otherwise>
			</choose>
		</variable>
		<svg:image x="{ $panelx }" y="{ $panely + $PANEL_H * 0.25 }" 
				width="{ $PANEL_W }" height="{ $PANEL_H * 0.75 }" 
				xlink:href="images/challenge_accepted.png"/>
		<svg:text y="{$panely + 40}"
				font-family="impact,sans-serif" font-weight="bold" fill="black" 
				font-size="19pt" text-anchor="middle">
			<call-template name="wrap-text">
				<with-param name="x" select="$panelx + $PANEL_W div 2" />
				<with-param name="lineheight" select="20" />
				<with-param name="chars" select="18" />
				<with-param name="text" select="normalize-space($content)" />
			</call-template>
		</svg:text>
	</template>-->
	
	<!--<template match="rage">
		<variable name="panelnum" select="count(ancestor::panel/preceding-sibling::*)" />
		<variable name="panelx" select="($panelnum mod 2) * $PANEL_W + $BORDER_W" />
		<variable name="panely" select="floor($panelnum div 2) * $PANEL_H + $BORDER_H" />
		<variable name="content">
			<choose>
				<when test="text()"><value-of select="text()" /></when>
				<otherwise><value-of select="'FFFFFFUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU'" /></otherwise>
			</choose>
		</variable>
		<variable name="pathid" select="generate-id(.)" />
		<svg:image x="{ $panelx }" y="{ $panely + $PANEL_H * 0.25 }"
				width="{ $PANEL_W * 0.75 }" height="{ $PANEL_H * 0.75 }"
				xlink:href="images/rage.png" />
		<svg:path d="M{$panelx+10},{$panely+30} L{$panelx+$PANEL_W -10},{$panely+30} 
					M{$panelx+10},{$panely+60} L{$panelx+$PANEL_W -10},{$panely+60}  
					M{$panelx+10},{$panely+90}  L{$panelx+$PANEL_W -10},{$panely+90}
					M{$panelx+$PANEL_W*0.75},{$panely+120} L{$panelx+$PANEL_W -10},{$panely+120}
					M{$panelx+$PANEL_W*0.75},{$panely+150} L{$panelx+$PANEL_W -10},{$panely+150}
					M{$panelx+$PANEL_W*0.75},{$panely+180} L{$panelx+$PANEL_W -10},{$panely+180}
					M{$panelx+$PANEL_W*0.75},{$panely+210} L{$panelx+$PANEL_W -10},{$panely+210}
					M{$panelx+$PANEL_W*0.75},{$panely+240} L{$panelx+$PANEL_W -10},{$panely+240}
					M{$panelx+$PANEL_W*0.75},{$panely+270} L{$panelx+$PANEL_W -10},{$panely+270}
					M{$panelx+$PANEL_W*0.75},{$panely+300} L{$panelx+$PANEL_W -10},{$panely+300}"
				stroke="none" fill="none" id="{$pathid}" />
		<svg:text font-family="impact,sans-serif" font-weight="bold" fill="red" font-size="20pt">
			<svg:textPath xlink:href="#{$pathid}">
				<value-of select="$content" />
			</svg:textPath>
		</svg:text>
	</template>-->
	
	<!--<template match="narration">
		<variable name="panelnum" select="count(ancestor::panel/preceding-sibling::*)" />
		<variable name="panelx" select="($panelnum mod 2) * $PANEL_W + $BORDER_W" />
		<variable name="panely" select="floor($panelnum div 2) * $PANEL_H + $BORDER_H" />
		<svg:text y="{ $panely + $PANEL_H *0.33 }"
				font-size="14pt" font-family="courier new,courier,monospace" text-anchor="middle">
			<call-template name="wrap-text">
				<with-param name="x" select="$panelx + $PANEL_W div 2" />
				<with-param name="lineheight" select="20" />
				<with-param name="chars" select="30" />
				<with-param name="text" select="normalize-space(text())" />
			</call-template>
		</svg:text>
	</template>-->
	
	<!--<template match="closeup">
		<variable name="panelnum" select="count(ancestor::panel/preceding-sibling::*)" />
		<variable name="panelx" select="($panelnum mod 2) * $PANEL_W + $BORDER_W" />
		<variable name="panely" select="floor($panelnum div 2) * $PANEL_H + $BORDER_H" />
		<variable name="clipid" select="generate-id(.)" />
		<svg:clipPath id="{ $clipid }">
			<svg:rect x="{ $panelx }" y="{ $panely }" width="{ $PANEL_W }" height="{ $PANEL_H }"/>
		</svg:clipPath>
		<svg:image x="{ $panelx - $PANEL_W*0.5}" y="{ $panely - $PANEL_H*0.5}" 
				width="{ $PANEL_W * 2 }" height="{ $PANEL_H * 2 }" clip-path="url(#{$clipid})">
			<attribute name="xlink:href">
				<choose>
					<when test="trollface"><value-of select="'images/trollface.png'" /></when>
					<when test="challenge-accepted"><value-of select="'images/challenge_accepted.png'"/></when>
					<when test="rage"><value-of select="'images/rage.png'"/></when>
				</choose>
			</attribute>
		</svg:image>
	</template>-->
	
	<!--<template name="narration-text">
		<param name="x" />
		<param name="y" />
		<param name="width" />
		<param name="text" />
		<svg:text y="{ $y }" font-size="16px" font-family="courier new,courier,monospace" 
				fill="black" text-anchor="left" stroke="none">
			<call-template name="wrap-text">
				<with-param name="x" select="$x" />
				<with-param name="lineheight" select="18" />
				<with-param name="chars" select="round($width div 11)" />
				<with-param name="text" select="normalize-space($text)"/>
			</call-template>
		</svg:text>
	</template>-->
	
	<template name="dialogue-text">
		<param name="x" />
		<param name="y" />
		<param name="width" />
		<param name="text" />
		<!--<svg:text y="{ $y }" font-size="18px" font-family="courier new,courier,monospace" 
				fill="white" text-anchor="middle" stroke="white" stroke-width="6">
			<call-template name="wrap-text">
				<with-param name="x" select="$x" />
				<with-param name="lineheight" select="20" />
				<with-param name="chars" select="round($width div 12)" />
				<with-param name="text" select="normalize-space($text)"/>
			</call-template>
		</svg:text>-->
		<svg:text y="{ $y }" font-size="16px" font-family="courier new,courier,monospace" 
				fill="black" text-anchor="middle" stroke="none">
			<call-template name="wrap-text">
				<with-param name="x" select="$x" />
				<with-param name="lineheight" select="18" />
				<with-param name="chars" select="round($width div 11)" />
				<with-param name="text" select="normalize-space($text)"/>
			</call-template>
		</svg:text>
	</template>
	
	<template name="wrap-text">
		<param name="x" />
		<param name="chars"/>
		<param name="lineheight" />
		<param name="text" />
		<param name="line" select="''" />
		
		<variable name="head">
			<choose><when test="contains($text,' ')"><value-of select="substring-before($text,' ')"/></when>
				<otherwise><value-of select="$text" /></otherwise></choose>
		</variable>
		<variable name="tail">
			<choose><when test="contains($text,' ')"><value-of select="substring-after($text,' ')"/></when>
				<otherwise><value-of select="''" /></otherwise></choose>
		</variable>
		<variable name="appended">
			<choose><when test="string-length($line) &gt; 0"><value-of select="concat($line,' ',$head)"/></when>
				<otherwise><value-of select="$head" /></otherwise></choose>
		</variable>
		
		<choose>
			<when test="string-length($appended) &gt; $chars and string-length($line) &gt; 0">
				<svg:tspan x="{$x}" dy="{$lineheight}">
					<value-of select="$line" />
				</svg:tspan>
				<call-template name="wrap-text">
					<with-param name="x" select="$x" />
					<with-param name="chars" select="$chars" />
					<with-param name="lineheight" select="$lineheight" />
					<with-param name="text" select="$text" />
					<with-param name="line" select="''" />
				</call-template>
			</when>
			<when test="string-length($tail) = 0">
				<svg:tspan x="{$x}" dy="{$lineheight}">
					<value-of select="$appended" />
				</svg:tspan>
			</when>
			<otherwise>
				<call-template name="wrap-text">
					<with-param name="x" select="$x" />
					<with-param name="chars" select="$chars" />
					<with-param name="lineheight" select="$lineheight" />
					<with-param name="text" select="$tail" />
					<with-param name="line" select="$appended" />
				</call-template>
			</otherwise>
		</choose>
	</template>
	
	<template name="sum-lengths">
		<param name="nodes" />
		<param name="accumulated" select="0"/>
		<variable name="val" select="$accumulated + string-length($nodes/text())" />
		<choose>
			<when test="$nodes/following-sibling::*">
				<call-template name="sum-lengths"> 
					<with-param name="nodes" select="$nodes/following-sibling::*" />
					<with-param name="accumulated" select="$val" />
				</call-template>
			</when>
			<otherwise>
				<value-of select="$val" />
			</otherwise>
		</choose>
	</template>
	
</stylesheet>
