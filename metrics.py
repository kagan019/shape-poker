import alfred
import shapepoker
from shapepoker import ShapePoker
import random
import strategy


#this is a client script for shapepoker.


def count_stats(game, n=1000): 
	#count number of occurences of certain events in n rounds.
	#exclude rounds that end in ties.
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


def frequency_of_hand_score(n=1000):
	for s in seeds:
		print("\nseed\n", s)
		print("playing", n, "rounds")
		random.seed(s)
		game = ShapePoker(strategy.StaticStrategy(4,5), strategy.StaticStrategy(4,5))
		vic, fre, res, rf, nt = count_stats(game, n)
		d = sorted([(k, fre[k]/nt) for k in fre], key=lambda s: s[0])
		print(d)



def river_score_vs_average_holding_score(n=1000):
	for s in seeds:
		print("\nseed\n", s)
		print("playing", n, "rounds")
		random.seed(s)
		game = ShapePoker(strategy.StaticStrategy(4,5), strategy.StaticStrategy(4,5))
		vic, fre, res, rf, nt = count_stats(game, n)
		d = sorted(res.items(), key=lambda s: s[1])
		print(d)



def win_rate(n=1000):
	for s in seeds:
		print("\nseed\n", s)
		print("playing", n, "rounds")
		random.seed(s)
		game = ShapePoker(strategy.StaticStrategy(4,5), strategy.StaticStrategy(4,5))
		vic, fre, res, rf, nt = count_stats(game, n)
		d = sum(vic.values()) / sum(fre.values())
		print(d)


def money_v_t(game, cycles=100, sessions=None):
	mvtevolve = []
	money_had_last_play_sesh = game.pevolve.money
	money_had_last_evolve = game.pevolve.money
	i = 0
	j = 0
	while (i if sessions is None else j) < (cycles if sessions is None else sessions):
		game.play(PLAY_SESSION_LENGTH)
		if game.pevolve.strategy.update(game.pevolve.money - money_had_last_play_sesh):
			i += 1
		mvtevolve += [game.pevolve.money - money_had_last_evolve]
		money_had_last_evolve = game.pevolve.money
		money_had_last_play_sesh = game.pevolve.money
		j += 1
			
	for i, x in enumerate(mvtevolve):
		print(repr((i, x)))
	print(game.pevolve.money)



def rounds_by_population(game):
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


def example_rounds():
	print("seed", seeds[0])
	random.seed(seeds[0])
	alfred.DEBUG = True
	ShapePoker(strategy.StaticStrategy(4,5), strategy.StaticStrategy(4,5)).play(5)
	alfred.DEBUG = False

seeds = [
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
]

PLAY_SESSION_LENGTH = 20
SESSIONS_TO_PLAY = 3000
compare_vanilla_genetic_search_with_GMAB2()


#river_score_vs_average_holding_score(n=10000)
#win_rate(n=10000)
#example_rounds()
