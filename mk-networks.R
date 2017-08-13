# load libraries. "install.packages()" if not loaded
library(igraph)
library(networkD3)
library(readr)
library(tidyr)


# hoards <-> mints via SPARQL
library(SPARQL)
endpoint <- "http://nomisma.org/query"


# CREATE all-hoards.html
query <-"PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nmo: <http://nomisma.org/ontology#> 
PREFIX void: <http://rdfs.org/ns/void#> 

SELECT DISTINCT ?hoard ?mint WHERE {
 {
 ?hoard a nmo:Hoard ;
       dcterms:tableOfContents [ nmo:hasMint ?mint ]
 }
UNION
 { ?hoard a nmo:Hoard ;
    dcterms:tableOfContents [ nmo:hasTypeSeriesItem ?tsi ] .
  ?tsi nmo:hasMint ?mint .
 }
}"

# gather two-column data.frame of hoards and mints
qd <- SPARQL(endpoint,query)
nomisma.edges <- qd$results

# turn data.frame into an igraph network
graph.data.frame(nomisma.edges) -> nomisma.igraph

# add vertex attribute indicating if hoard or mint.
grouped.igraph <- set.vertex.attribute(nomisma.igraph,
                                       name = "group",
                                       index = V(nomisma.igraph),
                                       value = ifelse(grepl("chrr|igch",V(nomisma.igraph)$name, perl = TRUE),'hoard','mint')) 

# turn igraph into a networkD3 object for rendering in html
nomisma.d3 = igraph_to_networkD3(grouped.igraph, group=V(grouped.igraph)$group)

# render as network viz and save to index.html
forceNetwork(Links = nomisma.d3$links, Nodes = nomisma.d3$nodes, NodeID = 'name',
             Group = 'group', zoom = TRUE, opacity = 1,fontSize=24, colourScale = JS("d3.scaleOrdinal(d3.schemeCategory10);"))  %>% saveNetwork(file = 'all-hoards.html')


# CREATE chrr-hoards.html
query <-"PREFIX dcterms: <http://purl.org/dc/terms/>
PREFIX nmo: <http://nomisma.org/ontology#> 
PREFIX void: <http://rdfs.org/ns/void#> 

SELECT DISTINCT ?hoard ?mint WHERE {
  ?hoard void:inDataset <http://numismatics.org/chrr/> ;
  dcterms:tableOfContents/nmo:hasTypeSeriesItem/nmo:hasMint ?mint .
}"

# gather two-column data.frame of hoards and mints
qd <- SPARQL(endpoint,query)
nomisma.edges <- qd$results

# turn data.frame into an igraph network
graph.data.frame(nomisma.edges) -> nomisma.igraph

# add vertex attribute indicating if hoard or mint.
grouped.igraph <- set.vertex.attribute(nomisma.igraph,
                                       name = "group",
                                       index = V(nomisma.igraph),
                                       value = ifelse(grepl("chrr",V(nomisma.igraph)$name, perl = TRUE),'hoard','mint')) 

# turn igraph into a networkD3 object for rendering in html
nomisma.d3 = igraph_to_networkD3(grouped.igraph, group=V(grouped.igraph)$group)

# render as network viz and save to index.html
forceNetwork(Links = nomisma.d3$links, Nodes = nomisma.d3$nodes, NodeID = 'name',
             Group = 'group', zoom = TRUE, opacity = 1,fontSize=24, colourScale = JS("d3.scaleOrdinal(d3.schemeCategory10);"))  %>% saveNetwork(file = 'chrr-hoards.html')

