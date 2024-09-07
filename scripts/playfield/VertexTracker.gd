class_name VertexTracker
extends Object

var vertex: Vertex

func _init(p_vertex: Vertex):
    vertex = p_vertex
    vertex.trackers.append(self)

func switchVertex(newVertex: Vertex):
    vertex.trackers.erase(self)
    if newVertex != null:
        newVertex.trackers.append(self)
    vertex = newVertex

func nullify():
    vertex.trackers.erase(self)
    vertex = null