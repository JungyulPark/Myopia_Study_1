library(igraph)

# Load the genes and interactions.
# If we don't have the exact edge list locally, we can query STRINGdb or just use the subset
# Actually, we have the exact topological data from Cytoscape if the user saved it, but if not we can approximate with igraph if we have the edges.
# The user said "Cytoscape CytoHubba에서 실제 export한 값 확인".
# Let's check CP1 directory for CytoHubba CSVs.
