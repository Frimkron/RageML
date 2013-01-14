<?xml version="1.0" encoding="utf-8" ?>
<stylesheet version="1.0" 
		xmlns="http://www.w3.org/1999/XSL/Transform" 
		xmlns:svg="http://www.w3.org/2000/svg" 
		xmlns:xlink="http://www.w3.org/1999/xlink"
		xmlns:rg="http://markfrimston.co.uk/rageml">

	<!-- TODO:
		* lone text coordinates need better way to position relative to face
		* hair for forlone and okay
	-->
	
	
	<output method="xml" version="1.0" encoding="utf-8"/>

	<variable name="PANEL_W" select="350" /> <!-- Width of each panel -->
	<variable name="PANEL_H" select="330" /> <!-- Height of each panel -->
	<variable name="BORDER_W" select="20" /> <!-- Width of space around image -->
	<variable name="BORDER_H" select="20" /> <!-- Height of space around image -->
	<variable name="NARRATION_H" select="50" /> <!-- Height of each narration block -->
	<variable name="LABEL_H" select="30" /> <!-- Height reserved for character labels -->
	<variable name="NAMESPACE" select="'http://markfrimston.co.uk/rageml'" /> <!-- Namespace URI -->
	<variable name="WITH_DEF_TEXT" select="'[rage][challenge-accepted][lol][me-gusta][forever-alone][okay]'" /> <!-- Face types with implied dialogue -->
	<variable name="HAIR_SCALE" select="1.15" />
	
	<!-- Root template -->
	<template match="/">
		<svg:svg version="1.1" width="{ $PANEL_W * 2 + $BORDER_W * 2 }" 
				height="{ ceiling(count(rg:comic/rg:panel) div 2) * $PANEL_H + $BORDER_H * 2 }">
			<call-template name="panels">
				<with-param name="panelnode" select="rg:comic/rg:panel[1]" />
			</call-template>
		</svg:svg>		
	</template>

	<!-- Renders panels recursively -->	
	<template name="panels">
	
		<param name="panelnode" />
		<param name="panelnum" select="0"/>
		<!-- default states of characters' faces as of previous panel -->
		<param name="def-faces" select="'[a:derp][b:derp][c:derp][d:derp][e:derp]'" />
		<!-- default sexes of characters as of previous panel -->
		<param name="def-sexes" select="'[a:m][b:m][c:m][d:m][e:m]'" />
		
		<!-- absolute position of panel -->
		<variable name="panelx" select="$BORDER_W + ($panelnum mod 2) * $PANEL_W" />
		<variable name="panely" select="$BORDER_H + floor($panelnum div 2) * $PANEL_H" />
		<!-- nodes representing lines of dialogue in this panel -->
		<variable name="linenodes" select="$panelnode/*[
			namespace-uri()=$NAMESPACE and local-name()!='narration' and ( descendant::text()
				or ( descendant-or-self::*[contains($WITH_DEF_TEXT,concat('[',local-name(),']'))]
					 and not(descendant::rg:silent) ) ) ]" />			
		<!-- nodes representing character presences in this panel -->
		<variable name="charnodes" select="$panelnode/*[namespace-uri()=$NAMESPACE
			and local-name()!='narration' and substring(local-name(),2)!='-reply']" />			
		<!-- current states of characters' faces after being overridden -->
		<variable name="faces">
			<call-template name="make-faces">
				<with-param name="charnodes" select="$charnodes" />
				<with-param name="elements" select="'abcde'" />
				<with-param name="def-faces" select="$def-faces" />
			</call-template>
		</variable>
		<!-- current sexes of characters after being overridden -->
		<variable name="sexes">
			<call-template name="make-sexes">
				<with-param name="charnodes" select="$charnodes" />
				<with-param name="elements" select="'abcde'" />
				<with-param name="def-sexes" select="$def-sexes" />
			</call-template>
		</variable>
		<variable name="topnarration" select="$panelnode/rg:narration[not(preceding-sibling::*)]" />
		<variable name="bottomnarration" select="$panelnode/rg:narration[preceding-sibling::*
				and not(following-sibling::*)]" />
		<!-- position and size of main panel content area, between narration blocks -->
		<variable name="contenty" select="$panely + number(boolean($topnarration)) * $NARRATION_H" /> 
		<variable name="contenth" select="$PANEL_H - ((number(boolean($topnarration))
				+ number(boolean($bottomnarration))) * $NARRATION_H)" />

		<!-- panel border -->
		<svg:rect x="{ $panelx }" y="{ $panely }" 
				width="{ $PANEL_W }" height="{ $PANEL_H }" stroke="black" 
				stroke-width="3" fill="white" fill-opacity="0.75" />
				
		<!-- clip path -->
		<svg:clipPath id="panel{$panelnum}clip">
			<svg:rect x="{$panelx}" y="{$panely}" width="{$PANEL_W}" height="{$PANEL_H}" />
		</svg:clipPath>
				
		<!-- group to clip panel contents -->
		<svg:g clip-path="url(#panel{$panelnum}clip)">
				
			<!-- top narration text -->
			<if test="$topnarration">
				<call-template name="narration-text">
					<with-param name="x" select="$panelx + 10" />
					<with-param name="y" select="$panely + 10" />
					<with-param name="width" select="$PANEL_W" />
					<with-param name="anchor" select="'start'" />
					<with-param name="text" select="string($topnarration)" />
				</call-template>
			</if>
				
			<!-- iterate over character presences, named characters first, in name order
				i.e. the order of their visual positioning -->
			<for-each select="$charnodes">
				<sort select="concat(string(number(string-length(local-name()) &gt; 1)),local-name())" />
				<variable name="elname" select="local-name()" />
				<call-template name="character">
					<!-- placed in panel according to position in ordered set. Give each character 
						a vertical slice of the panel space -->
					<with-param name="x" select="$panelx + $PANEL_W div count($charnodes) * (position() - 1)" />
					<with-param name="y" select="$contenty" />
					<with-param name="width" select="$PANEL_W div count($charnodes)" />
					<with-param name="height" select="$contenth" />
					<!-- direct children of panel representing dialogue lines for character -->
					<with-param name="linenodes" select=". | $linenodes[local-name()=concat($elname,'-reply')]" />
					<with-param name="alllinenodes" select="$linenodes" />
					<with-param name="label" select="@label" />
					<!-- for named characters, look up overidden face. For others, just use face name -->
					<with-param name="face">
						<choose>
							<when test="string-length($elname) = 1">
								<value-of select="substring-before(substring-after(
									$faces,concat('[',$elname,':')),']')" />
							</when>
							<otherwise>
								<value-of select="$elname" />
							</otherwise>
						</choose>
					</with-param>
					<!-- for named characters, look up overridden sex. For others, just default to male -->
					<with-param name="sex">
						<choose>
							<when test="string-length($elname) = 1">
								<value-of select="substring-before(substring-after(
									$sexes,concat('[',$elname,':')),']')" />
							</when>
							<otherwise>
								<value-of select="'m'" />
							</otherwise>
						</choose>
					</with-param>
				</call-template>
			</for-each>
			
			<!-- top narration text -->
			<if test="$bottomnarration">
				<call-template name="narration-text">
					<with-param name="x" select="$panelx + $PANEL_W - 10" />
					<with-param name="y" select="$contenty + $contenth + 10" />
					<with-param name="width" select="$PANEL_W" />
					<with-param name="anchor" select="'end'" />
					<with-param name="text" select="string($bottomnarration)" />
				</call-template>
			</if>
			
		</svg:g>
		
		<!-- recurse to the next panel, if present -->
		<if test="$panelnode/following-sibling::rg:panel">
			<call-template name="panels">
				<with-param name="panelnode" select="$panelnode/following-sibling::rg:panel[1]" />	
				<with-param name="panelnum" select="$panelnum + 1" />
				<!-- pass overidden character properties through to next panel -->
				<with-param name="def-faces" select="$faces" />
				<with-param name="def-sexes" select="$sexes" />
			</call-template>
		</if>
		
	</template>

	<!-- Renders an individual character presence including dialogue and so on.
		Invokes character-impl with face-specific paramters  -->
	<template name="character">
		<param name="x" />
		<param name="y" />
		<param name="width" />
		<param name="height" />
		<param name="linenodes" />
		<param name="alllinenodes" />
		<param name="face" />
		<param name="sex" />		
		<param name="label" />

		<!-- individual face settings -->
		<choose>
			<when test="$face = 'me-gusta'">
				<call-template name="character-impl">
					<with-param name="x" select="$x" />
					<with-param name="y" select="$y" />
					<with-param name="width" select="$width" />
					<with-param name="height" select="$height" />
					<with-param name="linenodes" select="$linenodes" />
					<with-param name="alllinenodes" select="$alllinenodes" />
					<with-param name="label" select="$label" />
					<with-param name="image" select="'me-gusta.png'" />
					<with-param name="hashair" select="$sex = 'f'" />
					<with-param name="hairsize" select="1.1" />
					<with-param name="hairoffx" select="0.05" />
					<with-param name="fontsize" select="30" />
					<with-param name="fontcolour" select="'red'" />
					<with-param name="fontweight" select="'bold'" />
					<with-param name="fontfamily" select="'impact,sans-serif'" />
					<with-param name="defaulttext" select="'ME GUSTA'" />
				</call-template>
			</when>
			<when test="$face = 'lol'">
				<call-template name="character-impl">
					<with-param name="x" select="$x" />
					<with-param name="y" select="$y" />
					<with-param name="width" select="$width" />
					<with-param name="height" select="$height" />
					<with-param name="linenodes" select="$linenodes" />
					<with-param name="alllinenodes" select="$alllinenodes" />
					<with-param name="label" select="$label" />
					<with-param name="image" select="'lol.png'" />
					<with-param name="hashair" select="$sex = 'f'" />
					<with-param name="fontsize" select="40" />
					<with-param name="fontcolour" select="'red'" />
					<with-param name="fontweight" select="'bold'" />
					<with-param name="fontfamily" select="'impact,sans-serif'" />
					<with-param name="defaulttext" select="'LOL'" />
					<with-param name="imgalign" select="'left'" />
					<with-param name="lonefontsize" select="60" />
					<with-param name="lonetextx" select="$width" />
					<with-param name="lonetexty" select="$PANEL_H * 0.6" />
					<with-param name="lonetextalign" select="'right'" />
					<with-param name="hairsize" select="1.05" />
					<with-param name="hairoffx" select="0.05" />
					<with-param name="hairoffy" select="-0.1" />
				</call-template>
			</when>
			<when test="$face = 'challenge-accepted'">
				<call-template name="character-impl">
					<with-param name="x" select="$x" />
					<with-param name="y" select="$y" />
					<with-param name="width" select="$width" />
					<with-param name="height" select="$height" />
					<with-param name="linenodes" select="$linenodes" />
					<with-param name="alllinenodes" select="$alllinenodes" />
					<with-param name="label" select="$label" />
					<with-param name="image" select="'challenge-accepted.png'" />
					<with-param name="hashair" select="$sex = 'f'" />
					<with-param name="fontsize" select="24" />
					<with-param name="fontweight" select="'bold'" />
					<with-param name="fontfamily" select="'impact,sans-serif'" />
					<with-param name="defaulttext" select="'CHALLENGE ACCEPTED'" />
					<with-param name="hairsize" select="0.9" />
					<with-param name="hairoffx" select="0.025" />
					<with-param name="hairoffy" select="-0.15" />
				</call-template>
			</when>
			<when test="$face = 'rage'">
				<call-template name="character-impl">
					<with-param name="x" select="$x" />
					<with-param name="y" select="$y" />
					<with-param name="width" select="$width" />
					<with-param name="height" select="$height" />
					<with-param name="linenodes" select="$linenodes" />
					<with-param name="alllinenodes" select="$alllinenodes" />
					<with-param name="label" select="$label" />
					<with-param name="image" select="'rage.png'" />
					<with-param name="hashair" select="$sex = 'f'" />
					<with-param name="fontsize" select="30" />
					<with-param name="fontcolour" select="'red'" />
					<with-param name="fontweight" select="'bold'" />
					<with-param name="fontfamily" select="'impact,sans-serif'" />
					<with-param name="defaulttext" select="'FFFFFFFFFFUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU'" />
					<with-param name="textalign" select="'left'" />
					<with-param name="textbehind" select="true()" />
					<with-param name="lonetextx" select="$x - 20" />
					<with-param name="lonetexty" select="0" />
					<with-param name="imgalign" select="'left'" />
					<with-param name="hairoffx" select="0.05" />
				</call-template>
			</when>
			<when test="$face = 'forever-alone'">
				<call-template name="character-impl">
					<with-param name="x" select="$x" />
					<with-param name="y" select="$y" />
					<with-param name="width" select="$width" />
					<with-param name="height" select="$height" />
					<with-param name="linenodes" select="$linenodes" />
					<with-param name="alllinenodes" select="$alllinenodes" />
					<with-param name="label" select="$label" />
					<with-param name="image" select="'forever-alone.png'" />
					<with-param name="hashair" select="$sex = 'f'" />
					<with-param name="fontsize" select="24" />
					<with-param name="fontweight" select="'bold'" />
					<with-param name="fontfamily" select="'sans-serif'" />
					<with-param name="defaulttext" select="'forever alone'" />
					<with-param name="hairsize" select="0.9" />
					<with-param name="hairoffy" select="-0.15" />
				</call-template>
			</when>
			<when test="$face = 'okay'">
				<call-template name="character-impl">
					<with-param name="x" select="$x" />
					<with-param name="y" select="$y" />
					<with-param name="width" select="$width" />
					<with-param name="height" select="$height" />
					<with-param name="linenodes" select="$linenodes" />
					<with-param name="alllinenodes" select="$alllinenodes" />
					<with-param name="label" select="$label" />
					<with-param name="image" select="'okay.png'" />
					<with-param name="hashair" select="$sex = 'f'" />
					<with-param name="fontsize" select="24" />
					<with-param name="fontweight" select="'bold'" />
					<with-param name="fontfamily" select="'sans-serif'" />
					<with-param name="defaulttext" select="'okay'" />
					<with-param name="lonetextx" select="10" />
					<with-param name="lonetexty" select="$PANEL_H * 0.8" />
					<with-param name="lonetextalign" select="'left'" />
					<with-param name="lonefontsize" select="18" />
					<with-param name="hairsize" select="0.85" />
					<with-param name="hairoffx" select="0.05" />
					<with-param name="hairoffy" select="-0.1" />
				</call-template>
			</when>
			<otherwise>
				<call-template name="character-impl">
					<with-param name="x" select="$x" />
					<with-param name="y" select="$y" />
					<with-param name="width" select="$width" />
					<with-param name="height" select="$height" />
					<with-param name="linenodes" select="$linenodes" />
					<with-param name="alllinenodes" select="$alllinenodes" />
					<with-param name="label" select="$label" />
					<with-param name="image" select="concat($face,'.png')" />
					<with-param name="hashair" select="$sex = 'f'" />
					<with-param name="textscaled" select="false()" />
				</call-template>
			</otherwise>
		</choose>

	</template>
	
	<!-- Generic rendering of character and accompanying dialogue. Invoked by 
		'character' template with face-specific parameters  -->
	<template name="character-impl">
		<param name="x" />	
		<param name="y" />
		<param name="width" />
		<param name="height" />
		<param name="linenodes" />
		<param name="alllinenodes" />
		<param name="label" />
		<param name="image" />
		<param name="hashair" />
		<param name="fontsize" select="16"/>
		<param name="fontweight" select="'normal'"/>
		<param name="fontcolour" select="'black'"/>
		<param name="fontfamily" select="'courier new,courier,monospace'"/>
		<param name="textalign" select="'center'" />
		<param name="hairsize" select="1.0"/>
		<param name="hairoffx" select="0"/>
		<param name="hairoffy" select="0"/>
		<param name="defaulttext" select="''"/>
		<param name="imgalign" select="'center'" />
		<param name="textbehind" select="false()" />
		<param name="textscaled" select="true()" />
		<param name="lonefontsize" select="$fontsize" />
		<param name="lonefontweight" select="$fontweight" />
		<param name="lonefontcolour" select="$fontcolour" />
		<param name="lonefontfamily" select="$fontfamily" />
		<param name="lonetextalign" select="$textalign" />
		<param name="lonetextx" select="$width div 2" />
		<param name="lonetexty" select="50" />
		
		<!-- prepare sizes -->
		<variable name="imgsize">
			<choose>
				<when test="$width &gt; $height * 0.75">
					<value-of select="$height * 0.75" />
				</when>
				<otherwise>
					<value-of select="$width" />
				</otherwise>
			</choose>
		</variable>
		<variable name="textheight" select="$height - $imgsize - $LABEL_H" />
		<variable name="textsize">
			<choose><when test="$textscaled"><value-of select="0.25 + ($width div $PANEL_W) * 0.75" /></when>
			<otherwise><value-of select="1.0" /></otherwise></choose>
		</variable>
		<variable name="imgx">
			<choose>
				<when test="$imgalign = 'left'"><value-of select="$x" /></when>
				<when test="$imgalign = 'right'"><value-of select="$x + $width - $imgsize" /></when>
				<otherwise><value-of select="$x + $width div 2 - $imgsize div 2" /></otherwise>
			</choose>
		</variable>
		<variable name="imgy" select="$y + $textheight + $LABEL_H" />
		<variable name="islone" select="count($alllinenodes)=1 and count($linenodes)=1" />
		
		<variable name="linefamily">
			<choose><when test="$islone"><value-of select="$lonefontfamily" /></when>
			<otherwise><value-of select="$fontfamily" /></otherwise></choose>
		</variable>
		<variable name="linecolour">
			<choose><when test="$islone"><value-of select="$lonefontcolour" /></when>
			<otherwise><value-of select="$fontcolour" /></otherwise></choose>
		</variable>
		<variable name="lineweight">
			<choose><when test="$islone"><value-of select="$lonefontweight" /></when>
			<otherwise><value-of select="$fontweight" /></otherwise></choose>
		</variable>
		<variable name="linesize">
			<choose><when test="$islone"><value-of select="$lonefontsize" /></when>
			<otherwise><value-of select="$fontsize" /></otherwise></choose>
		</variable>
		<variable name="linealign">
			<choose><when test="$islone"><value-of select="$lonetextalign" /></when>
			<otherwise><value-of select="$textalign" /></otherwise></choose>
		</variable>
		<variable name="lineanchor">
			<choose>
				<when test="$linealign = 'left'"><value-of select="'start'" /></when>
				<when test="$linealign = 'right'"><value-of select="'end'" /></when>
				<otherwise><value-of select="'middle'" /></otherwise>
			</choose>
		</variable>
		<variable name="linex">
			<choose>
				<when test="$islone"><value-of select="$x + $lonetextx" /></when>
				<otherwise>
					<choose>
						<when test="$linealign = 'left'"><value-of select="$x" /></when>
						<when test="$linealign = 'right'"><value-of select="$x + $width" /></when>
						<otherwise><value-of select="$x + $width div 2" /></otherwise>
					</choose>
				</otherwise>
			</choose>
		</variable>
		
		<!-- Render face now if behind text -->
		<if test="not($textbehind)">
			<call-template name="face">
				<with-param name="x" select="$imgx"/>
				<with-param name="y" select="$imgy"/>
				<with-param name="size" select="$imgsize"/>
				<with-param name="name" select="$image"/>
				<with-param name="hashair" select="$hashair"/>
				<with-param name="hairsize" select="$hairsize"/>
				<with-param name="hairx" select="$hairoffx"/>
				<with-param name="hairy" select="$hairoffy"/>
			</call-template>
		</if>
						
		<!-- Render lines of dialogue -->
		<for-each select="$linenodes">
			<variable name="linepos" select="count(preceding-sibling::*[
				count($alllinenodes|.) = count($alllinenodes) ] )" />
			<variable name="liney">
				<choose><when test="$islone"><value-of select="$y + $lonetexty" /></when>
				<otherwise><value-of select="$y + 20 * $textsize 
					+ $textheight div count($alllinenodes) * $linepos" /></otherwise></choose>
			</variable>
			<svg:text font-family="{$linefamily}" fill="{$linecolour}" font-weight="{$lineweight}"
					font-size="{$linesize * $textsize}px"  text-anchor="{$lineanchor}" y="{$liney}">
				<call-template name="wrap-text">
					<with-param name="x" select="$linex" />
					<with-param name="chars" select="$width div ($linesize * 0.75 * $textsize)" />
					<with-param name="lineheight" select="($linesize + 2) * $textsize" />
					<with-param name="text">
						<choose>
							<when test="descendant::text()"><value-of select="descendant::text()" /></when>
							<when test="descendant::rg:silent"></when>
							<otherwise><value-of select="$defaulttext" /></otherwise>
						</choose>
					</with-param>
				</call-template>
			</svg:text>
		</for-each>
				
		<!-- Render face now if in front of text -->
		<if test="$textbehind">
			<call-template name="face">
				<with-param name="x" select="$imgx"/>
				<with-param name="y" select="$imgy"/>
				<with-param name="size" select="$imgsize"/>
				<with-param name="name" select="$image"/>
				<with-param name="hashair" select="$hashair"/>
				<with-param name="hairsize" select="$hairsize"/>
				<with-param name="hairx" select="$hairoffx"/>
				<with-param name="hairy" select="$hairoffy"/>
			</call-template>
		</if>

		<!-- render label -->
		<if test="$label">
			<call-template name="dialogue-text">
				<with-param name="x" select="$x + $width div 2" />
				<with-param name="y" select="$y + $textheight" />
				<with-param name="width" select="$width" />
				<with-param name="text" select="concat('* ',$label)" />
			</call-template>
		</if>
		
	</template>
	
	<!-- Renders the actual face image - invoked by 'character-impl' -->
	<template name="face">
		<param name="x" />
		<param name="y" />
		<param name="size" />
		<param name="name" />
		<param name="hashair" />
		<param name="hairsize" />
		<param name="hairx" />
		<param name="hairy" />

		<!-- hair back -->		
		<if test="$hashair">
			<svg:image x="{$x + $size div 2 - ($size * $HAIR_SCALE * $hairsize) div 2 + $size * $hairx}" 
				y="{$y + $size div 2 - ($size * $HAIR_SCALE * $hairsize) div 2 + $size * $hairy}" 
				width="{$size * $HAIR_SCALE * $hairsize}" height="{$size * $HAIR_SCALE * $hairsize}" 
				xlink:href="images/hair-back.png" />
		</if>
		<!-- face -->
		<svg:image x="{$x}" y="{$y}" width="{$size}" height="{$size}" 
				xlink:href="images/{$name}" />
		<!-- hair front -->
		<if test="$hashair">
			<svg:image x="{$x + $size div 2 - ($size * $HAIR_SCALE * $hairsize) div 2 + $size * $hairx}" 
				y="{$y + $size div 2 - ($size * $HAIR_SCALE * $hairsize) div 2 + $size * $hairy}" 
				width="{$size * $HAIR_SCALE * $hairsize}" height="{$size * $HAIR_SCALE * $hairsize}" 
				xlink:href="images/hair-front.png" />
		</if>
	</template>


	<!-- Prepares character face data for the given named character elements by
		overriding the given defaults with any face change specified in the 
		character nodes -->
	<template name="make-faces">
		<param name="charnodes" />
		<param name="def-faces" />
		<param name="elements" />
		<param name="curr-faces" select="''"/>
		<!-- current named character element name -->
		<variable name="el" select="substring($elements,1,1)" />
		<!-- if character node contains an element, override with this face,
				otherwise look up default -->
		<variable name="faces">
			<value-of select="concat($curr-faces,'[',$el,':')" />
			<choose>
				<when test="$charnodes[local-name()=$el]/*">
					<value-of select="local-name($charnodes[local-name()=$el]/*)" />
				</when>
				<otherwise>
					<value-of select="substring-before(substring-after(
						$def-faces,concat('[',$el,':')),']')" />
				</otherwise>
			</choose>
			<value-of select="']'" />
		</variable>
		<!-- Recurse to process next named character element, or output result if at end -->
		<choose>
			<when test="string-length($elements) &gt; 1">
				<call-template name="make-faces">
					<with-param name="charnodes" select="$charnodes" />
					<with-param name="def-faces" select="$def-faces" />
					<with-param name="elements" select="substring($elements,2)" />
					<with-param name="curr-faces" select="$faces" />
				</call-template>
			</when>
			<otherwise>
				<value-of select="$faces" />
			</otherwise>
		</choose>
	</template>
	
	<!-- Prepares character sex data for the given named character elements by
		overriding the given defaults with any sex specified in the character nodes -->
	<template name="make-sexes">
		<param name="charnodes" />
		<param name="def-sexes" />
		<param name="elements" />
		<param name="curr-sexes" select="''" />
		<!-- current named character element name -->
		<variable name="el" select="substring($elements,1,1)" />
		<!-- if character node has sex attribute, override with this sex,
				otherwise look up default -->
		<variable name="sexes">
			<value-of select="concat($curr-sexes,'[',$el,':')" />
			<choose>
				<when test="$charnodes[local-name()=$el]/@sex">
					<value-of select="$charnodes[local-name()=$el]/@sex" />
				</when>
				<otherwise>
					<value-of select="substring-before(substring-after(
						$def-sexes,concat('[',$el,':')),']')" />
				</otherwise>
			</choose>
			<value-of select="']'" />
		</variable>
		<!-- Recurse to process next named character element, or output result if at end -->
		<choose>
			<when test="string-length($elements) &gt; 1">
				<call-template name="make-sexes">
					<with-param name="charnodes" select="$charnodes" />
					<with-param name="def-sexes" select="$def-sexes" />
					<with-param name="elements" select="substring($elements,2)" />
					<with-param name="curr-sexes" select="$sexes" />
				</call-template>
			</when>
			<otherwise>
				<value-of select="$sexes" />
			</otherwise>	
		</choose>
	</template>
	
	<!-- Renders the given text as narration text, attempting to wrap to the 
		given width -->
	<template name="narration-text">
		<param name="x" />
		<param name="y" />
		<param name="width" />
		<param name="anchor" />
		<param name="text" />
		<svg:text y="{$y}" font-size="16px" font-family="courier new,courier,monospace"
				fill="black" text-anchor="{$anchor}" stroke="none">
			<call-template name="wrap-text">
				<with-param name="x" select="$x" />
				<with-param name="lineheight" select="18" />
				<with-param name="chars" select="round($width div 11)" />
				<with-param name="text" select="normalize-space($text)" />
			</call-template>
		</svg:text>
	</template>
	
	<!-- Renders the given text as character dialogue, attempting to wrap to
		the given width -->
	<template name="dialogue-text">
		<param name="x" />
		<param name="y" />
		<param name="width" />
		<param name="text" />
		<!--<svg:text y="{ $y }" font-size="16px" font-family="courier new,courier,monospace" 
				fill="white" text-anchor="middle" stroke="white" stroke-width="8">
			<call-template name="wrap-text">
				<with-param name="x" select="$x" />
				<with-param name="lineheight" select="18" />
				<with-param name="chars" select="round($width div 11)" />
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
	
	<!-- Renders the given text on multiple lines by limiting each line to the 
		given number of characters. Recurses to handle one token at a time -->
	<template name="wrap-text">
		<param name="x" />
		<param name="chars"/>
		<param name="lineheight" />
		<param name="text" />
		<param name="line" select="''" />
		
		<!-- The next token -->
		<variable name="head">
			<choose><when test="contains($text,' ')"><value-of select="substring-before($text,' ')"/></when>
				<otherwise><value-of select="$text" /></otherwise></choose>
		</variable>
		<!-- The rest of the tokens -->
		<variable name="tail">
			<choose><when test="contains($text,' ')"><value-of select="substring-after($text,' ')"/></when>
				<otherwise><value-of select="''" /></otherwise></choose>
		</variable>
		<!-- The current line with new token added -->
		<variable name="appended">
			<choose><when test="string-length($line) &gt; 0"><value-of select="concat($line,' ',$head)"/></when>
				<otherwise><value-of select="$head" /></otherwise></choose>
		</variable>
		
		<choose>
			<!-- if token alone is larger than the whole line limit, render line 
				with start of token and recurse, starting a new line with remainder 
				of the token, thereby breaking the word over multiple lines  -->
			<when test="string-length($head) &gt; $chars">
				<svg:tspan x="{$x}" dy="{$lineheight}">
					<value-of select="concat($line,' ',substring($head,1,$chars - (string-length($line)+1) + 1))" />
				</svg:tspan>
				<call-template name="wrap-text">
					<with-param name="x" select="$x" />
					<with-param name="chars" select="$chars" />
					<with-param name="lineheight" select="$lineheight" />
					<with-param name="text" select="concat(substring($head,$chars - (string-length($line)+1) + 2),' ',$tail)" />
					<with-param name="line" select="''" />
				</call-template>
			</when>		
			<!-- if token pushes line length over limit when appended to current line, 
				render the line without it and recurse, starting a new line.  -->
			<when test="string-length($appended) &gt; $chars">
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
			<!-- if there are no more tokens, render the remaining line and stop -->
			<when test="string-length($tail) = 0">
				<svg:tspan x="{$x}" dy="{$lineheight}">
					<value-of select="$appended" />
				</svg:tspan>
			</when>
			<!-- Otherwise, recurse to the next token on the current line -->
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
	
	<!-- Find the combined lengths of the text nodes contained in the given nodes -->
	<!--<template name="sum-lengths">
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
	</template>-->
	
</stylesheet>
