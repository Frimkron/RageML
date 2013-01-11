% RageML
% Mark Frimston
% 2012-12-20

An XML markup language describing rage comics. Inspired by a stupid 
conversation over a django developer's rage comic blog post and its 
lack of indexability.

Should describe meaning rather than layout.

To be transformed by XSLT into an image. Raster if possible, svg 
otherwise, or html failing that. Ideally it should be embeddable 
in an img tag.


	<rage-comic>
		<panel>
			<trollface who="friend">Bet you can't drink a whole 
				bottle of tabasco</trollface>
		</panel>
		<panel>
			<challenge-accepted who="me"/>
		</panel>
		<panel>
			<narration>Later...</narration>
		</panel>
		<panel size="large">
			<rage who="me">FUUUUUUUUUU</rage>
		</panel>
	</rage-comic>


Feature TODO:

* "sex" attribute
* "to" attribute (basic direction override)
* Grouped characters
* appearence by number
* closeup panel
			
Layouts
	
	[ narration ]  / blaaaaaaaaa \   
	               \ rage aaaaaa /		             		            
	/   blah    \
	\ trollface /
		
	/   blah    \
	\ challenge /
		
	+- - - - - - -+
	|  narration  |
	|- - - - - - -|
	|+- - - - - -+|
	|| tf  |+- -+||
	||     ||drp|||
	||     |+- -+||
	|+- - - - - -+|
	+- - - - - - -+
		
	( - -)   (0 0 )(0 0 )
	  A talking to B & C
		  		  
	<panel>
		<!-- distinguishing looks generated according to order of 
			appearence and m/f -->
		<!-- "who" attribute used to reference same character to
			get same appearence. Tries to place same character on
			same side of panel  -->
		<derp who="sue" sex="f" />
		<derp who="me" sex="m" />
	</panel>
	<panel>
		<trollface />
	</panel>
		
- - - - - - - - - -
		
	<panel>
		<derp>herp derp</derp>
		<group>
			<trollface>what</trollface>
			<trollface />
			Yes we agree
		</group>
	</panel>
		
	<!-- elements in panel are lines of dialogue. Same character 
		can speak twice in same panel -->
	<panel>
		<derp who="a">knock knock</derp>
		<trollface who="b">who's there</trollface>
		<derp who="a">doctor</derp>
		<trollface who="b">hello doctor!</trollface>
	</panel>
		
- - - - - - - - - - 
		
	<!-- Labels are rendered beside characters and stuff -->
	<panel>
		<derp who="me" label="me derping around">hi</derp>
		<derp who="gf" sex="f" label="my girlfriend">hi</derp>
	</panel>
		
- - - - - - - - - - 
		
	<!-- "to" attribute indicates who character is addressing.
		if omitted, assumes all other characters  -->
	<panel>
		<derp who="me" to="gf">yo</derp>
		<derp who="gf" to="other">Who's he talking to?</derp>
		<derp who="other" />
	</panel>

- - - - - - - - - - -
		
	left 
	aligned
	
	       centre 
	      aligned
		   
	               right 
	             aligned		       		  
	
	( ^^)  ( ^^ )  (^^ )
		
- - - - - - - - - - - -
		
Narration only as first and last
		
- - - - - - - - - - - - 
		
Must allow empty character elements in panel in order to
indicate the presence of a character with no lines
		
What happens if the same character has multiple lines in a 
panel, but using different representations? Shouldn't be 
allowed!

	             [ panel ]
	                 |
	                 ^
	[ face ]--<[ appearence ]--<[ line ]
	                 v
	                 |
	           [ character ]
		   
	           +------------+        
	   line 2 / ...   ...  /|   line should refer to 1 and only
	  line 1 / ...   ...  / |   1 appearence, but currently each
	        +------------+  |   can have its own face
	panel 1 | derp troll |  +
	        |            | /
	panel 2 |srsly dpina |/
	        +------------+
	           me    gf
		           
Ideally lines should be expressed in reading order
		           
	<character name="me" label="le me"/>
	<character name="gf" label="le girlfriend"/>
	<panel>
		<face who="me" which="derp" />            <!-- shouldn't allow multiple -->
		<face who="gf" which="trollface" />       <!-- faces for same character -->
		<line who="me">Look at that thing</line>
		<line who="gf">I don't see it</line>
		<line who="me">It's right there</line>
		<line who="gf">Nope</line>
	</panel>
	<panel>
		<face who="me" which="rage" />
		<line who="me">FFFFFFFFFFFFFFFUUUUUUUUUUUUUUUUUUUUUUUUUUU</line>
	</panel>
		
- - - 
		
	<panel>
		<face who="me" which="derp">
			<line number="1">blah blah</line>
			<line number="3">stuff</line>
		</face>
		<face who="gf" which="trollface">
			<line number="2">yadda yadda</line>
		</face>
	</panel>
	<panel>
		<face who="me" which="rage">
			<line>FFFFFFUUUUUUUUU</line>
		</face>
	</panel>
		
- - - 
		
	<!-- a? b? c? ... panel+ -->
	<a label="le me" />          <!-- Mapping characters to a,b,c -->
	<b label="le girlfriend" />  <!-- is not very intuitive       -->
	<panel>
		<!-- a-face? b-face? c-face? ... (a-line|b-line|c-line|...)* -->
		<a-face face="derp" />
		<b-face face="trollface" />
		<a-line>Hi there</a-line>
		<b-line>Hello mate</b-line>
		<a-line>What</a-line>
		<b-line>lol</b-line>
	</panel>
	<panel>
		<a-face face="rage" />
		<a-line>FFFFUUUUUUUUUUU</a-line>
		<!-- Shorthand: --> 
		<rage>FFFFUUUUUUUUU</rage>
	</panel>
		
- - -
		
	<panel>
		<derp>Hello</derp>            <!-- But here, author can still mistakenly -->
		<trollface>What?</trollface>  <!-- assign multiple faces to same character -->
		<reply who="derp">I said...</reply> <!-- if unspecified, characters      -->
		<reply who="trollface">LOL</reply>  <!-- take name of face with appended -->
		                                    <!-- number if necessary             -->
	</panel>
	<panel>
		<rage />
	</panel>
		
- - - 
		
	<!-- Need to delcare characters up here? Maybe for global 
	    attributes such as appearence  -->
	<panel>
		<!-- ( a? b? c? ... (a-reply|b-reply|c-reply|...)* )
			| rage | challenge-accepted | ... -->
		<a face="derp" label="le me">Hi there</a>
		<b face="trollface" label="le girlfriend">Hi</b>
		<a-reply>What's ur name?</a-reply>
		<b-reply>Adolf</b-reply>
	</panel>

- - - 

	<derp>Blah blah blah</derp>
	
Is this a useful shorthand?	Perhaps for macros that don't require
the character to be identified. But even `<rage />` might need to
declare that the character is a long-haired girl.

But `<d face="rage" />` isn't as funny as `<rage />`

What about `<d><rage /></d>`?

	<panel>
		<a><derp>Hi there</derp></a>
		<b><trollface>Hi</trollface></a>
		<a-reply>What's ur name?</a-reply>
		<b-reply>Adolf</b-reply>
	</panel>
	<panel>
		<rage />
	</panel>
	
This syntax is pretty good --^

	<a label="le boyfriend" sex="m">...</a>
	
`<a>Stuff</a>` To use a default face
`<a><derp>Stuff</derp></a>` To use a specific face

	<panel>
		<narration>Meanwhile...</narration>
		<a to="b"><derp>derp</derp></a>
		<b to="a"><derp>herp</derp></a>
		<a-reply>yup</a-reply>	
		<narration>But then...</narration>
	</panel>
	<panel>
		<a to="b"><derp>harp</derp></a>
		<b to="a"><derp>darp</derp></b>
	</panel>
	<panel>
		<!-- single-character special -->
		<closeup>
			<a><trollface /></a>
		</closeup>
	</panel>

comic: `panel+`
panel: `narration? (`
  `a?b?c?d?e? (a-reply|b-reply|c-reply|d-reply|e-reply|derp|trollface|rage|...)*`
  `| closeup )?`
  `narration?`
a: `text|derp|trollface|rage|...`
b: `text|derp|trollface|rage|...`
a-reply: `text`
b-reply: `text`
derp: `text`
trollface: `text`
closeup: `a|b|c|d|e|derp|trollface|rage|...`

`<a>`, `<b>`, `<c>` etc makes it easy for reader to see which character is 
which. How can this be reflected in the visual representation?
Coloured text? Positioning?

	+----------------+--------------+
	|  A     B    C  |      B    C  |
	|( '')( '' )('' )|    ( '')('' )|
	+----------------+--------------+
	|  A          C  |  A    B      |
	|( '')      ('' )|( '')('' )    |
	+----------------+--------------+

Placing characters in order would be a good start, but unless space is 
preserved, it won't be the whole story.

If labels have been provided, these could be re-stated if the panel is 
determined to be ambiguous

What happens if user redefines a character's attributes?
	
	<panel>
		<a sex="f">hello</a>
	</panel>
	<panel>
		<a sex="m">hello</a>
	</panel>

There *must* be a global definition

	<comic>
		<a-who label="le brother" sex="m" />
		<b-who label="le me" sex="f" />
		<panel>
			<a><trollface/></a>
			<b><derp>hi</derp></b>
		</panel>
	</comic>

Do we need character definitions at all?

* Positioning across panels
* Replies

	<comic>
		<panel>
			<trollface>hi</trollface>
			<derp>meh</derp>
			<trollface>meh?</trollface>
		</panel>
		<panel>
			<derp>Hi, I gues</derp>
			<trollface>yeah</trollface>
		</panel>
	</comic>

If visualisation is going to try to arrange characters to indicate that the 
same character is speaking, then it needs to know when it's the same 
character across panels. Thus, faces have to be identified consistently
between panels	

	<a-who label="le boyfriend" sex="m" attributes="sunglasses,on-phone" />
	
Attributes can be overidden per panel. Well if that's the case, why not just
have changes persist, and forget the global definitions:

	<panel>
		<a label="le dude" attributes="sunglasses" />
	</panel>
	<panel>
		<a label="still le dude" attributes="">
			<mother-of-god />
		</a>
	</panel>

- - - - - - - - - - - - - - - - - 

Issue. User should be allowed to specify up to one of each of a,b,c etc,
*in any order*, followed by the replies. This isn't easily expressible with 
xsd:

sequence
:	Items in order, each 0-many (`a* b* c*`)

choice
:	Exactly 1 item from options (`a | b | c`)

group
:	Simply names a definition for reuse elsewhere

all
:	Items in any order, up to 1 of each. But may only be used as the root 
   of a type definition and may only contain element items.
   
Could put first lines inside a wrapper element:

	<panel>
		<first-lines>
			<e>What's up?</e>
			<b><trollface /></b>
		</first-line>
		<e-reply>meh</e-reply>
	</panel>
	
But this is hideous.

	<panel>
		<a-face>trollface</a-face>
		<b-face>derp</b-face>
		<b-line>Hi</a-line>
		<a-line>What</a-line>
		<b-line>lol</b-line>
	</panel>
	
How is the positioning figured out here anyway:

	<panel>
		<a><trollface>blah</trollface></a>
		<b><derp>meh</derp></b>
		<lol /> <!-- Is this face placed on the right? -->
	</panel>

Unnamed faces are just placed in order of appearence

	<derp who="a">foo</derp>
	<trollface who="a">bar</trollface>

- - - - - - - - - - -

If character tags are to change appearence state for current *and* subsequent
frames until changed, panels will need to be handled by a recursive template,
each passing the previous character states into the next

	<param name="a-face" select="derp" />
	<param name="b-face" select="trollface"/ >
	...
	
I dont think templates can be called by name dynamically - probably have to 
dispatch using a choose statement instead

	<choose>
		<when test="$face = 'derp'">
			<call-template name="derp" />
		</when>
		<when test="$face = 'trollface'">
			<call-template name="trollface" />
		</when>
		...
	</choose>
	
- - - - - - - - - -

Is there an easier way to do *all* of this? One that doesn't require building 
a model of the characters *in frigging XSL*? Is there something that maps more
directly onto the representation?

	+----------------+
	|line a1         |
	|        line b1 |
	|line a2         |
	|+------++------+|
	|| face || face ||
	||  a   ||  b   ||
	|+------++------+|
	+----------------+

	<panel>
		<chr name="me" face="derp" pos="sw" />
		<chr name="gf" face="trollface" pos="se" />
		<line who="me">Hi there</line>
		<line who="gf">Hi</line>
		<line who="me">How's it going?</line>		
	</panel>
	<panel>
		<chr face="rage" pos="c" />
	</panel>
	
It's just not as nice. And it still requires some modelling to place the 
dialogue in the right place, especially if the characters can be positioned
anywhere in the panel

- - - - - - - - - -

Once we have the current apperence attributes for each of the named characters,
we need to establish the faces that appear in the current panel.
	
	d	e	trollface	a	derp

	<variable name="total-chrs" select="count($panelnode/*[name()!='narration'
		and name()!='a-line' and name()!='b-line' and name()!='c-line' 
		and name()!='d-line' and name()!='e-line'])" />	
		
	<variable name="total-lines" select="count($panelnode/*[name()!='narration']/descendant::text())" />
	
Can happily place unnamed characters on the end.

Need to somehow iterate over characters in a,b,c,derp order to render faces,
But then iterate over lines in order of appearence and cross-reference them
with their face to render them at the correct coordinates. And *then* there's
the relative vertical spacing to consider.

Each character can select its dialogue lines. Upon doing this, the position of
each line in the panel's lines can be established by taking the count of 
previous siblings which aren't `<narration>` nodes. Simple.

	<template name="character">
		<param name="panelnode" />
		<param name="linenodes" />
		<param name="face" />
		<param name="sex" />
		<param name="x" />
		<param name="y" />
		<param name="width" />
		<param name="height" />
	</template>

	<for-each select="a|b|c|d|e|derp|trollface|...">
		<order ... />
		<call-template name="character">
		
		</call-template>
	</for-each>

- - - - - - - -

Next challenge, a face with no text *may* imply some text. For example,
`<rage />` implies the dialogue "FFFFFFFFFUUUUUUUUUUUUUUUUUUUUUUUUUUUUU"

- - - - - - - - 

	|- - - - - - - | 
	|  +--------+  | 
	|  |        |  | 
	|  |        |  | 
	|  |        |  | |- - - - - |
	|  +--------+  | |  +----+  |
	+--------------+ |  |    |  |
	                 |  +----+  |
	                 +----------+

- - - - - - - - - - 

	      ( start )
              |
              v        
	     [ new line ]<-----------------<-----------------+
	          |                                          |
	          v                                          |
    +-->< more tokens? >-->[ output ]-->( end )          |
	|         | y                                        ^
	|         v                                          |
	|   [ next token ]                                   |
	|         |                                          |
	|         v       n                  n               |
	^   < token fits? >--->< new line? >--->[ output ]---+
	|         | y                | y
	|         v                  v
	|      [ add ]<-------[ split token ]
    |         |	
	+---<-----+

- - - - - - - - - - - -

Is it a dialogue line?

	                         silent
	      reply?  wrapped?    face?   text?  silent?
	      
	   +---  y  +--- n  +---   n  +---  y  +--- n  O
	   |                          '---  n  +--- n    X
	   '---  n  +--- y  +---   y  +---  y  +--- n  O
	            |       |         '---  n  +--- y    X
	            |       |                  `--- n    X
	            |       '---   n  +---  y  +--- n  O
	            |                 '---  n  +--- y    X
	            |                          `--- n  O
	            '--- n  +---   y  +---  y  +--- n  O
	                    |         '---  n  +--- y    X
	                    |                  `--- n    X
	                    '---   n  +---  y  +--- n  O
	                              '---  n  +--- y    X
	                                       `--- n  O
	                                       
	namespace-uri()=$NAMESPACE
	and local-name != 'narration'
	and (
		descendant::text()
		or (
			not( contains($SILENTS,concat('[',local-name(),']')) )
			not( contains($SILENTS,concat('[',local-name(*),']')) )
			and not( descendant::rg:silent )
		)
	)

	Better:
	
	namespace-uri()=$NAMESPACE
	and local-name() != 'narration'
	and (
		descendant::text()
		or (
			desendant-or-self::*[contains($NONSILENTS,concat('[',local-name(),']'))]
			and not( descendant::rg:silent )
		)
	)

	Later tests:
	
	preceding-sibling::*[ count($alllinenodes|.) = count($alllinenodes) ].

So, how would modifiers like `<closeup>` work?

	<panel>
		<closeup>
			<derp>lol</derp>
		</closeup>
	</panel>
	
Closeup affects the whole panel

	<panel effect="closeup">
		<derp>lol</derp>
	</panel>
	
But you can only have a closeup of a single character

	<closeup-panel>
		<a><derp>lol</derp></a>
	</closeup-panel>
	
This makes sense, but isn't aesthetically pleasing as nesting the closeup tag

	<panel>
		<!-- panel content can either be conversion OR single closeup -->
		<closeup> 
			<!-- closeup may only contain a single character line, either
				wrapped or not -->
			<derp>lol</derp> 
		</closeup>
	</panel>

But what about narration?

	<panel>
		<narration>Then...</narration>
		<closeup>
			<derp>lol</derp>
		</closeup>
		<narration>The End</narration>
	</panel>

Forget closeups. I don't need the feature creep.


