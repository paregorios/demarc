# Geography processing notes 2020


- some specific steps will be different for you, but key takeaways:
  - get comfortable with using different data formats for different stages of the process
    - why? because you want to use different tools or look at data in different ways
- get a list of toponyms and dump to CSV
  - used xslt to pull them out of word xml
  - cleaned strings and got unique list
    - look at all the spelling errors! Elaine Matthews about migration and data cleaning; maybe compare with Reynolds
  - why CSV? because geocollider
  - made two lists: ancient and modern because different lookups probably
  - used xslt: diss2toponyms.xsl
  - geocollider and the problem of duplicates
  - open refine
    - open file
    - add reconciliation service URI
    - select matches
    - column -> reconcile -> add entity identifiers column (name pids)
    - pids -> edit column -> add column by fetching URLs (pjson)
    - get representative point coordinates
      - Longitude: pjson -> edit column -> add column based on this column -> value.parseJson()['reprPoint'][0]
      - Latitude: pjson -> edit column -> add column based on this column -> value.parseJson()['reprPoint'][1]
      - (maybe get types or other things on second pass)
  - make map in QGIS
  - show data in excel
  - show data in google sheets
  
