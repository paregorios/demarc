demarc
======

This repository contains an open-access and slowly refactored and enhanced version of [Tom Elliott's](http://isaw.nyu.edu/people/staff/tom-elliott) 2004 Ph.D. dissertation (Ancient History, Chapel Hill) entitled "Epigraphic Evidence for Boundary Disputes in the Early Roman Empire." The original "dead tree" dissertation was completed under the direction of [Richard J.A. Talbert](http://en.wikipedia.org/wiki/Richard_Talbert). At present, the repository contains the [PDF versions of the main content of the dissertation](https://github.com/paregorios/demarc/blob/master/original-pdf/BoundaryDisputes.pdf) as prepared for final printing and submission, as well as [Open Document Text (ODT) format exports](https://github.com/paregorios/demarc/tree/master/original-odt) of the corresponding Microsoft Word files in which the dissertation was originally created and edited.

The following other files may be of interest:

* [original-xml/elliottDiss.xml](https://github.com/paregorios/demarc/blob/master/original-xml/elliottDiss.xml) : I opened original-odt/elliottDiss.odt in the OxygenXML editor and exported the content.xml file to this file

* [xsl/diss2inst.xsl](https://github.com/paregorios/demarc/blob/master/xsl/diss2inst.xsl) : an XSLT file whose purpose in life is to extract information about the "instances of boundary demarcation and dispute" that I identified in the dissertation from the elliottDiss.xml and serialize it to a more tractable XML form on the basis of which subsequent work can continue. Possible eventual products include: standalone files (XML:TEI, HTML) for each instance, stable URIs for each instance, RDF for each instance.

* [xml/instances.xml](https://github.com/paregorios/demarc/blob/master/xml/instances.xml) : output from running diss2inst.xsl against elliottDiss.xml (i.e., an xmlized list of each "instance" identified in the dissertation, with some amount of markup of the content ... some content hasn't come through successfully yet) 

You may get some further idea of where I think I'm going next by looking at what's in [TODO.md](https://github.com/paregorios/demarc/blob/master/TODO.md).

For questions, comments, or critiques, please email me at tom.elliott@nyu.edu.
  
All content copyright Thomas R. Elliott, 2004-2012.

<a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/us/"><img alt="Creative Commons License" style="border-width:0" src="http://i.creativecommons.org/l/by-sa/3.0/us/88x31.png" /></a><br /><span xmlns:dct="http://purl.org/dc/terms/" href="http://purl.org/dc/dcmitype/Dataset" property="dct:title" rel="dct:type">Epigraphic Evidence for Boundary Disputes in the Early Roman Empire</span> by <a xmlns:cc="http://creativecommons.org/ns#" href="http://isaw.nyu.edu/people/staff/tom-elliott" property="cc:attributionName" rel="cc:attributionURL">Tom Elliott</a> is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/3.0/us/">Creative Commons Attribution-ShareAlike 3.0 United States License</a>.

[LICENSE.md](https://github.com/paregorios/demarc/blob/master/LICENSE.md) contains a copy of the above license information.
