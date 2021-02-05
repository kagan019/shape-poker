import math
import random

# this is a helper script for functions that are 
# used by the EMAB simulation but are of less interest
# to the research

DEBUG = False


def log(*args):
	if len(args) == 0:
		if DEBUG:
			print()
		return ""
	if DEBUG:
		print(*args)
	return args[0]

def nsmallest(l, n=1, key=lambda x: x):
	assert len(l) >= n
	small = sorted(list(range(n)), key=lambda h: key(l[h]))
	for j, x in ((a + n, b) for a,b in enumerate(l[n:])):
		for i, k in enumerate(small):
			if key(x) < key(l[k]):
				small.insert(i, j)
				small = small[:-1]
				break

	return small