import random


NUMBER_OF_MAPS = 5
#'plain': 'P', 'grass': 'G', 'tree': 'T', 'mountain': 'M', 'volcano': 'V', 'water': 'W', 'lava': 'L', 'floor': 'F', 'hole': 'H'
MAP_TYPES   = ['P', 'G', 'T', 'M', 'W']
MAP_WEIGHTS = [10,   4,   3,   1,   2]
#'none': '0', 'tree': 'T', 'mountain': 'M', 'volcano': 'V',  'sign': 'S', 'indicator-special-cross': 'I', 'house': 'H'
ASS_TYPES = ['0', 'T', 'M']


def generate_map():
    map = list('%' * 8*8)
    ass = list('%' * 8*8)

    weighted_map_choices = []
    for i in range(len(MAP_TYPES)):
        weight_i = MAP_WEIGHTS[i]
        while weight_i > 0:
            weighted_map_choices.append(MAP_TYPES[i])
            weight_i -= 1

    for i in range(8*8):
        available_indices = get_available_indices(map)
        curr_i = random.choice(available_indices)
        choices = weighted_map_choices.copy()
        for j in range(8*8):
            if map[j] != '%' and is_adjacent(curr_i+1, j+1):
                #print(str(j+1) + ' is adjecent to ' + str(curr_i+1))
                choices.append(map[j])
                choices.append(map[j])
        map[curr_i] = random.choice(choices)
        print(str(curr_i+1) + ': ' + str(choices) + ' -> ' + map[curr_i])
    
    assi = 0
    for el in map:
        if el in ASS_TYPES:
            ass[assi] = el
        else:
            ass[assi] = '0'
        assi += 1
    
    if len(map) != 64 or len(ass) != 64:
        print('WRONG SIZE!!!')
    
    print('MAP: ' + '\n' + ''.join(map))
    types_counters = ''
    for type in MAP_TYPES:
        types_counters += type + '=' + str(type_counter(map, type)) + '   '
    print(types_counters)
    print('ASS: ' + '\n' + ''.join(ass))


def get_available_indices(map):
    available_indices = []
    for i in range(8*8):
        if map[i] == '%':
             available_indices.append(i)
    return available_indices


def is_adjacent(origin, target):
    #left side
    if origin % 8 == 1:
        return origin + 1 == target or abs(origin - target) == 8
    #right side
    if origin % 8 == 0:
        return origin - 1 == target or abs(origin - target) == 8
    #top side
    if origin > 1 and origin < 8:
        return abs(origin - target) == 1 or origin + 8 == target
    #bottom side
    if origin > 57 and origin < 64:
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
