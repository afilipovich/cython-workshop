import itertools

from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

cdef struct sack_item:
    double cost
    double weight

cdef class CSack:
    cdef sack_item* csack
    cdef int numitems
    cdef double max_capacity

    def __cinit__(self, sack):
        self.numitems = len(sack['items'])
        self.max_capacity = sack['capacity']
        self.csack = <sack_item *>PyMem_Malloc(self.numitems * sizeof(sack_item))
        if not self.csack:
            raise MemoryError()
        cdef i = 0
        for i,item in enumerate(sack['items']):
            self.csack[i].cost = item['cost']
            self.csack[i].weight = item['weight']

    def get_max_capacity(self):
        return self.max_capacity

    def get_numitems(self):
        return self.numitems

    def compute_weight_and_cost(self, combo_num):
        cdef double weight = 0.0
        cdef double cost = 0.0
        cdef int i = 0
        cdef int cn = combo_num
        csack = self.csack

        for i in range(self.numitems):
            if (cn & 1 == 1): # last bit in combo number
                cost += csack[i].cost
                weight += csack[i].weight
            cn >>= 1 # shift combo number bit-by-bit
        return weight, cost

    def __dealloc__(self):
        PyMem_Free(self.csack)


class CBruteSolver:

    '''
    Bruteforce solver for the sack problem
    '''

    def __init__(self, sack):
        self.csack = CSack(sack)

    def int2list(self, n): # calculate this to form the output, less efficient but runs only once
        l = []
        cdef int i = 0
        cdef int cn = n
        for i in range(self.csack.get_numitems()):
            l.append((cn & 1 == 1))
            cn >>= 1
        return l

    def solve(self):
        '''
        Main rutine, solves the problem,
        returns the combination with maximal cost and the cost
        '''
        cdef double maxcost = -1
        cdef double max_capacity = self.csack.get_max_capacity()
        cdef int combo_num = 0
        cdef int max_combo_num = 0

        for combo_num in range(2 ** self.csack.get_numitems()):
            weight, cost = self.csack.compute_weight_and_cost(combo_num)
            if cost > maxcost and weight <= max_capacity:
                maxcost = cost
                max_combo_num = combo_num
        max_combo = self.int2list(max_combo_num)
        return max_combo, maxcost
