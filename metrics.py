import alfred
import shapepoker
from shapepoker import ShapePoker
import random
import strategy
import time


#this is a client script for shapepoker.

SEEDS = [
	1512398,
	4963463,
	1283218,
	8374263,
	6712362,
	4387523,
	6734345,
	9756767,
	4223432,
	2498375,
	9764687,
	1345323,
	4231178,
	8997675,
	9845743,
	1736432
]

METASEED = 76433423
PLAY_SESSION_LENGTH = 20
SESSIONS_TO_PLAY = 100


def count_stats(game, n=1000): 
	#count number of occurences of certain events in n rounds.
	#this is a quick internal helper function
	#excludes rounds that end in ties.
	vic = {}
	freq = {}
	riverexscore = {}
	riverfreq = {}
	notties = 0
	for i in range(n):
		game.round(i)
		if not game.tie_flag:
			notties += 1
			sp = game.score(game.pevolve)
			sr = game.score_river()
			if sp in freq:
				freq[sp] += 1
			else:
				freq[sp] = 1

			
			if game.last_winner.name == game.pevolve.name:
				if sp in vic:
					vic[sp] += 1
				else:
					vic[sp] = 1
			else:
				if sp not in vic:
					vic[sp] = 0


			if sr in riverfreq:
				riverfreq[sr] += 1
				riverexscore[sr] += sp
			else:
				riverfreq[sr] = 1
				riverexscore[sr] = sp

		game.discard()
	#print(repr(wl_byscore))
	#print (repr(occurrences))
	riverexscore = dict([(k, riverexscore[k]/riverfreq[k]) for k in riverfreq])
	return vic, freq, riverexscore, riverfreq, notties


def frequency_of_hand_score(seeds=SEEDS, n=1000):
	for s in seeds:
		print("\nseed\n", s)
		print("playing", n, "rounds")
		random.seed(s)
		game = ShapePoker(strategy.StaticStrategy(4,5), strategy.StaticStrategy(4,5))
		vic, fre, res, rf, nt = count_stats(game, n)
		d = sorted([(k, fre[k]/nt) for k in fre], key=lambda s: s[0])
		print(d)



def river_score_vs_average_holding_score(seeds=SEEDS, n=1000):
	for s in seeds:
		print("\nseed\n", s)
		print("playing", n, "rounds")
		random.seed(s)
		game = ShapePoker(strategy.StaticStrategy(4,5), strategy.StaticStrategy(4,5))
		vic, fre, res, rf, nt = count_stats(game, n)
		d = sorted(res.items(), key=lambda s: s[1])
		print(d)



def win_rate(seeds=SEEDS, n=1000, strat=strategy.StaticStrategy):
	# Make two random, unchanging `Strategy`s and have them battle a session of `n` rounds
	# What % of the time does the evolving player win?
	for s in seeds:
		print("\nseed\n", s)
		print("win rate after", n, "rounds")
		random.seed(s)
		game = ShapePoker(strategy.StaticStrategy(4,5), strat(4,5))
		vic, fre, res, rf, nt = count_stats(game, n)
		d = sum(vic.values()) / sum(fre.values())
		print(d)
		return d


def money_v_t(game, cycles=100, sessions=None):
	# can run for a certain number of games or a certain number of evolutionary cycles
	mvtevolve = []
	mvtsesh = []
	money_had_last_play_sesh = game.pevolve.money
	money_had_last_evolve = game.pevolve.money
	i = 0
	j = 0
	while (i < cycles if sessions is None else j < sessions):
		game.play(PLAY_SESSION_LENGTH)
		if game.pevolve.strategy.update(game.pevolve.money - money_had_last_play_sesh): # always True for a static strategy
			i += 1
			mvtevolve += [game.pevolve.money - money_had_last_evolve]
			money_had_last_evolve = game.pevolve.money
		mvtsesh += [game.pevolve.money - money_had_last_play_sesh]
		money_had_last_play_sesh = game.pevolve.money
		mvtsesh += []
		j += 1
	if sessions is None:
		for i, x in enumerate(mvtevolve):
			print(repr((i, x)))
	else:
		for j, x in enumerate(mvtsesh):
			print(repr((j,x)))
	print("Evolving player's money:", game.pevolve.money)



def rounds_by_population(game):
	# For each learning model of the evolving strategy,
	# display its win count.
	for s in game.pevolve.strategy.strategies:
		print(s.times, end=" ")
	print()



def compare_vanilla_genetic_search_with_GMAB():
	print("session length:", PLAY_SESSION_LENGTH)
	print("sessions to play for each combine_formula:", SESSIONS_TO_PLAY)
	print()

	# Simulates PLAY_SESSION_LENGTH*SESSIONS_TO_PLAY rounds of Shape Poker and takes data on how much money player `pevolve` earned over time.
	for seed in seeds:
		print("\n\nseed", seed, "\n")
		random.seed(seed)


		gamelin = ShapePoker(strategy.StaticStrategy(4,5), strategy.GeneticSearch(4,5, combine_formula=strategy.linear_combine))
		gameari = ShapePoker(strategy.StaticStrategy(4,5), strategy.GeneticSearch(4,5, combine_formula=strategy.arithmetic_combine))
		gamepyth = ShapePoker(strategy.StaticStrategy(4,5), strategy.GeneticSearch(4,5, combine_formula=strategy.pythagorean_combine))
		# GMAB shines in situations where our computational resources are constrained such that we are afforded only a
		# a certain number of evolution cycles.
		gameGMAB = ShapePoker(strategy.StaticStrategy(4,5), strategy.GMAB(4,5))


		print("linear")
		money_v_t(gamelin, sessions=SESSIONS_TO_PLAY / 3) 
		print("\narithmetic")
		money_v_t(gameari, sessions=SESSIONS_TO_PLAY / 3) 
		print("\npythagorean")
		money_v_t(gamepyth, sessions=SESSIONS_TO_PLAY / 3) 
		print("\nGMAB")
		money_v_t(gameGMAB, sessions=SESSIONS_TO_PLAY) 
		rounds_by_population(gameGMAB)	

def compare_vanilla_genetic_search_with_GMAB2():
	print("session length:", PLAY_SESSION_LENGTH)
	print("sessions to play for each combine_formula:", SESSIONS_TO_PLAY)
	print()

	# Simulates PLAY_SESSION_LENGTH*SESSIONS_TO_PLAY rounds of Shape Poker and takes data on how much money player `pevolve` earned over time.
	for seed in seeds:
		print("\n\nseed", seed, "\n")	
		random.seed(seed)


		gamelin = ShapePoker(strategy.StaticStrategy(4,5), strategy.GeneticSearch(4,5, combine_formula=strategy.linear_combine))
		gameari = ShapePoker(strategy.StaticStrategy(4,5), strategy.GeneticSearch(4,5, combine_formula=strategy.arithmetic_combine))
		gamepyth = ShapePoker(strategy.StaticStrategy(4,5), strategy.GeneticSearch(4,5, combine_formula=strategy.pythagorean_combine))
		# GMAB shines in situations where our computational resources are constrained such that we are afforded only a
		# a certain number of evolution cycles.
		gameGMAB = ShapePoker(strategy.StaticStrategy(4,5), strategy.GMAB(4,5))


		print("linear")
		money_v_t(gamelin, sessions=SESSIONS_TO_PLAY) 
		print("\narithmetic")
		money_v_t(gameari, sessions=SESSIONS_TO_PLAY) 
		print("\npythagorean")
		money_v_t(gamepyth, sessions=SESSIONS_TO_PLAY) 
		print("\nGMAB")
		money_v_t(gameGMAB, sessions=SESSIONS_TO_PLAY) 
		rounds_by_population(gameGMAB)									


def fairness():
	# for 1000 seeds made by METASEED,
	# run a session of 1000 rounds and report the rate the evolving player wins
	random.seed(METASEED) # metaseed to generate seeds
	range_object = range(2**31-1)
	seeds = [random.choice(range_object) for _ in range(1000)]
	winpcnt = []
	for seed in seeds:
		winpcnt += [win_rate(seeds=[seed])]
	print("avg: ", sum(winpcnt) / len(winpcnt)) #fair means 50%

def compare_combine_formulas(seeds=SEEDS):
	# tabulates the final scores of the evolving players using each combine formula
	# plays one session of 100 rounds per seed per formula
	for s in seeds:
		print("\n\nseed",s,"\n")
		random.seed(s)

		gamelin = ShapePoker(strategy.StaticStrategy(4,5), strategy.GeneticSearch(4,5, combine_formula=strategy.linear_combine))
		gameari = ShapePoker(strategy.StaticStrategy(4,5), strategy.GeneticSearch(4,5, combine_formula=strategy.arithmetic_combine))
		gamepyth = ShapePoker(strategy.StaticStrategy(4,5), strategy.GeneticSearch(4,5, combine_formula=strategy.pythagorean_combine))
	
		gamelin.play(100)
		gameari.play(100)
		gamepyth.play(100)
		print (repr(("Linear",gamelin.pevolve.money)))
		print(repr(("Arithmetic",gameari.pevolve.money)))
		print(repr(("Pythagorean",gamepyth.pevolve.money)))

def benchmark_genetic_search_strategy(seeds=SEEDS):
	# For each seed,
	# Pits an evolving player against a non-evolving player.
	# Outputs score and gives the evolving player feedback after each session
	# See example_rounds() to see a sample of what a 'session' of ShapePoker looks like
	print("session length:", PLAY_SESSION_LENGTH)
	print("sessions to play:", SESSIONS_TO_PLAY)
	print()

	# Simulates PLAY_SESSION_LENGTH*SESSIONS_TO_PLAY rounds of Shape Poker and takes data on how much money player `pevolve` earned over time.
	for seed in seeds:
		print("\n\nseed", seed, "\n")	
		random.seed(seed)

		gamelin = ShapePoker(strategy.StaticStrategy(4,5), strategy.GeneticSearch(4,5, combine_formula=strategy.linear_combine))
		
		print("linear")
		money_v_t(gamelin, sessions=SESSIONS_TO_PLAY) 

def example_rounds(seeds=SEEDS):
	# play five rounds of two strategies playing against one another.
	print("seed", seeds[0])
	random.seed(seeds[0])
	alfred.DEBUG = True
	ShapePoker(strategy.StaticStrategy(4,5), strategy.StaticStrategy(4,5)).play(5)
	alfred.DEBUG = False
