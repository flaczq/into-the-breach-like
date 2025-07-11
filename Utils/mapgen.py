import random
from datetime import datetime


NUMBER_OF_MAPS = 5
#'plain': 'P', 'grass': 'G', 'tree': 'T', 'mountain': 'M', 'volcano': 'V', 'water': 'W', 'lava': 'L', 'floor': 'F', 'hole': 'H'
MAP_TYPES   = ['P', 'G', 'T', 'M', 'W']
MAP_WEIGHTS = [10,   4,   2,   1,   2]
#'none': '0', 'tree': 'T', 'mountain': 'M', 'volcano': 'V',  'sign': 'S', 'indicator-special-cross': 'I', 'house': 'H'
ASS_TYPES = ['0', 'T', 'M']


def generate_map():
    map = list('%' * 8*8)
    ass = list('%' * 8*8)

    for i in range(8*8):
        real_map_weights = MAP_WEIGHTS.copy()
        available_indices = get_available_indices(map)
        curr_i = random.choice(available_indices)
        #T, M, W at the edges
        if is_at_the_edge(curr_i):
            #print(str(curr_i) + ' is at the edge')
            currindex = MAP_TYPES.index('T')
            real_map_weights[currindex] += 5
            currindex = MAP_TYPES.index('M')
            real_map_weights[currindex] += 5
            currindex = MAP_TYPES.index('W')
            real_map_weights[currindex] += 5
        else:
            #print(str(curr_i) + ' is NOT at the edge')
            currindex = MAP_TYPES.index('P')
            real_map_weights[currindex] += 5
            currindex = MAP_TYPES.index('G')
            real_map_weights[currindex] += 5
        
        #same type close to each other
        for j in range(8*8):
            if map[j] != '%' and is_adjacent(curr_i, j):
                #print(str(curr_i) + ' is adjecent to ' + str(map[j]) + '[' + str(j) + ']')
                jndex = MAP_TYPES.index(map[j])
                real_map_weights[jndex] += 5

        #print(real_map_weights)
        weighted_map_choices = []
        for i in range(len(MAP_TYPES)):
            weight_i = real_map_weights[i]
            while weight_i > 0:
                weighted_map_choices.append(MAP_TYPES[i])
                weight_i -= 1

        map[curr_i] = random.choice(weighted_map_choices)
        #print(str(curr_i) + ': ' + str(weighted_map_choices) + ' -> ' + map[curr_i])
    
    assi = 0
    for el in map:
        if el in ASS_TYPES:
            ass[assi] = el
        else:
            ass[assi] = '0'
        assi += 1
    
    if '%' in map:
        print('INCOMPLETE MAP!!!')
        return
    
    if len(map) != 64 or len(ass) != 64:
        print('WRONG SIZE!!!')
        return
    
    print('MAP: ' + '\n' + ''.join(map))
    types_counters = ''
    for type in MAP_TYPES:
        types_counters += type + '=' + str(type_counter(map, type)) + '   '
    print(types_counters)
    print('ASS: ' + '\n' + ''.join(ass))

    with open('generated_levels_ ' + str(random.randint(1, 999999)) + '.txt', 'a') as f:
        f.write('MAP: ' + ''.join(map) + '\n')
        f.write('ASS: ' + ''.join(ass) + '\n')


def get_available_indices(map):
    available_indices = []
    for i in range(8*8):
        if map[i] == '%':
             available_indices.append(i)
    return available_indices


def is_at_the_edge(origin):
    #left side
    if origin % 8 == 0:
        return True
    #right side
    if origin % 8 == 7:
        return True
    #top side
    if origin > 0 and origin < 7:
        return True
    #bottom side
    if origin > 56 and origin < 63:
        return True
    #middle
    return False


def is_adjacent(origin, target):
    #left side
    if origin % 8 == 0:
        return origin + 1 == target or abs(origin - target) == 8
    #right side
    if origin % 8 == 7:
        return origin - 1 == target or abs(origin - target) == 8
    #top side
    if origin > 0 and origin < 7:
        return abs(origin - target) == 1 or origin + 8 == target
    #bottom side
    if origin > 56 and origin < 63:
        return abs(origin - target) == 1 or origin - 8 == target
    #middle
    return abs(origin - target) == 1 or abs(origin - target) == 8


def type_counter(list, type):
    counter = 0
    for el in list:
        if el == type:
            counter += 1
    return counter


index = 1
for i in range(NUMBER_OF_MAPS):
    print('#' + str(index))
    generate_map()
    index += 1
    print('\n')
