import json
from munkres import Munkres, print_matrix, make_cost_matrix

def split(info):
    committees = ['CompServ','Tutoring','Indrel','Activities','StudRel','Bridge','Service']
    for cid in info['data']:
        prefs = info['data'][cid]
        for committee in committees:
            start = prefs.find(committee)
            prefs = prefs[:start] + committee + " " + prefs[start + len(committee):]
        info['data'][cid] = prefs[:len(prefs)-1]
    return info

def parse(jsonInfo):
    return json.loads(jsonInfo)

#data format:
#{data: {id: prefs...}, spots: {"compserv":3...}}
def solve(info):
    matrix = [] #'profit matrix'
    #sorted list of all candidate ids
    candidates = sorted([cid for cid in info['data']])
    #map candidates to a list of their preferences
    c_prefs = {cid:info['data'][cid].split(" ") for cid in info['data']}
    length = len(c_prefs[0]) #number of choices
    #sorted list of all committee spots
    c_spots = sorted([name for name in info['spots']
        for _ in range(info['spots'][name])])

    #building the matrix, each represents a candidate
    for cid in candidates:
        prefs_matrix = []
        for spot in c_spots:
            #first in preference list given highest weight
            prefs_matrix.append((length - c_prefs[cid].index(spot)))
        matrix.append(prefs_matrix)
        
    #turn 'profit matrix' into 'cost matrix' by subtracting from a
    #sufficiently large ceiling, in this case: 100
    cost_matrix = make_cost_matrix(matrix, lambda cost: 100 - cost) 

    m = Munkres()
    indexes = m.compute(cost_matrix)
    for row, column in indexes:
        print('{0} : {1}'.format(row, c_spots[column]))