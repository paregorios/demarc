TODO
====

I was thinking I should export ODT to XHTML and then use that as the basis for chunking the catalog, creating RDF, burning URIs and so forth, but the LibreOffice basic export doesn't seem to have preserved cross-references, which seem to have made it through the conversion from Word to ODT ok. So we need to figure out how to preserve these on export to XHTML, otherwise the narrative completely falls apart structurally. Or ... I note that opening the ODT file in Oxygen and saving off the "content.xml" file as original-xml/elliottDiss.xml does seem to have preserved actionable cross-referencing. These are in the form of references like:

    <text:bookmark-ref text:reference-format="chapter" text:ref-name="INST87">81</text:bookmark-ref> 

which refers to markup like:

    <text:h text:style-name="treInstance" text:outline-level="3"><text:bookmark-start
    text:name="INST87"/><text:span text:style-name="T40">INST87:
    </text:span>Boundary Demarcations between <text:span
    text:style-name="trePlaceAncient">Cirta</text:span> and its Neighbors</text:h>
    <text:p text:style-name="treParaIndent_20_Char"><text:bookmark-end text:name="INST87"
    />Burton 2000, nos. 54 and 57</text:p>
    
Note that <text:bookmark-start> and <text:bookmark-end> are milestone elements.

Maybe on the basis of the above, I could work from the XML to generate stuff, rather than going all the way to HTML. It may be that the XML preserves some of the pseudo-semantics I shoehorned into the Word files with styles and so forth that might not make it in HTML via LibreOffice export.

