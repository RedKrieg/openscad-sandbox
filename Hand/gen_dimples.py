import math, random, json

def write_dimples(dimple_list, file_name="dimple_vectors.scad"):
    with open(file_name, 'w') as f:
        f.write(f"rotation_vectors = {json.dumps(dimple_list, indent=4).strip()};\n")

def deg(theta):
    return theta/math.pi*180 % 360.0

def golden_spiral(n):
    def phi(m):
        return deg(math.acos(1-2*m/n))
    def theta(m):
        return deg(math.pi * (1 + 5**0.5) * m)
    return [ [ 0, phi(i + 0.5), theta(i + 0.5) ] for i in range(n) ]
write_dimples(golden_spiral(88))
#print(min([phi() for i in range(1000)]))
