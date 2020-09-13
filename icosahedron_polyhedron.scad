phi=(1+sqrt(5))/2;

// these are for side length 2
function vertices(r) = 
[
    [0, r, r*phi],
    [0, -r, r*phi],
    [0, r, -r*phi],
    [0, -r, -r*phi],
    [r*phi, 0, r],
    [-r*phi, 0, r],
    [r*phi, 0, -r],
    [-r*phi, 0, -r],
    [r, r*phi, 0],
    [-r, r*phi, 0],
    [r, -r*phi, 0],
    [-r, -r*phi, 0]
];

/* I cheated really hard here.  No doubt.
#!python
import math
phi=(1+math.sqrt(5))/2
vertices = [
    [0, 1, phi],
    [0, -1, phi],
    [0, 1, -phi],
    [0, -1, -phi],
    [phi, 0, 1],
    [-phi, 0, 1],
    [phi, 0, -1],
    [-phi, 0, -1],
    [1, phi, 0],
    [-1, phi, 0],
    [1, -phi, 0],
    [-1, -phi, 0]
]
def dist(p1, p2):
    x1, y1, z1 = p1
    x2, y2, z2 = p2
    return math.sqrt((x2-x1)**2+(y2-y1)**2+(z2-z1)**2)
def unfloat(p1, p2):
    return 1.98<=dist(p1, p2)<=2.02
faces = set()
for i1, p1 in enumerate(vertices):
    for i2, p2 in enumerate(vertices):
        for i3, p3 in enumerate(vertices):
            if unfloat(p1, p2) and unfloat(p1, p3) and unfloat(p2, p3):
                faces.add(tuple(sorted((i1, i2, i3))))
print [list(face) for face in faces]
*/
faces = [
    [5, 7, 9],
    [2, 8, 9],
    [0, 5, 9],
    [3, 6, 10],
    [2, 3, 6],
    [2, 7, 9],
    [2, 6, 8],
    [1, 5, 11],
    [1, 10, 11],
    [4, 6, 8],
    [3, 7, 11],
    [5, 7, 11],
    [0, 1, 4],
    [0, 4, 8],
    [3, 10, 11],
    [2, 3, 7],
    [0, 8, 9],
    [0, 1, 5],
    [1, 4, 10],
    [4, 6, 10]
];

module icosahedron(s)
{
    polyhedron(vertices(s/2), faces);
}

icosahedron(120);