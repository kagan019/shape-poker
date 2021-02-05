import alfred
from alfred import log
import enum
import random
from itertools import combinations
import strategy




class Shapes(enum.Enum):
	square = 1
	circle = 2
	triangle = 3
	diamond = 4

class Colors(enum.Enum):
	red = 1
	blue = 2
	green = 3
	lavender = 4

class Card:
	def __init__(self, s: Shapes, c: Colors):
		self.shape = s
		self.color = c

	def __repr__(self):
		return self.shape.name + "(" + self.color.name + ")"

class Deck():
	def __init__(self):
		self.order = []
		for s in Shapes:
			for c in Colors:
				self.order += [Card(s, c) for x in range(4)]

		self.shuffle()

	def shuffle(self):
		random.shuffle(self.order)

	def draw(self):
		x = self.order[0]
		self.order = self.order[1:]
		return x

class Player:
	def __init__(self, name, strat):
		self.hand = []
		self.money = 0 # players bet and win on the margin
		self.name = name
		self.wins = 0
		self.losses = 0
		self.strategy = strat

	def make_move(self, cur_score, river_score, pot, last_bet, can_raise=True):
		# domain-specific part of the action selection process
		w = self.strategy.action_weights([cur_score, river_score, pot, last_bet]) # 4 input dimensions
		betr = max(0, last_bet)
		w = ( w[0:1] +
			[0 for _ in range(betr)] + (
				w[betr + 1:]
				if can_raise else 
				( [w[betr + 1]] + 
					[0 for _ in range(3 - betr)] 
				)
		 	)
		)

		# fold -> -1
		# check -> 0
		# call -> bet_to_match
		# raise -> int > bet_to_match
		possible_bets = [-1, 0, 1, 2, 3] # 5 output dimensions
		bet = -1
		if sum(w) != 0:
			bet = random.choices(possible_bets, weights=w)[0]
		return bet


class ShapePoker:
	def __init__(self, p1strat=strategy.StaticStrategy(4,5), p2strat=strategy.StaticStrategy(4,5)):
		self.p1 = Player("P1", p1strat)
		self.p2 = Player("P2", p2strat)
		self.pstatic = self.p1
		self.pevolve = self.p2
		self.first_player = self.p1
		self.second_player = self.p2
		self.last_winner = self.p1
		self.last_looser = self.p2

		self.river = []
		self.pot = 0
		self.MIN_BET = 1
		self.round_end_flag = False
		self.tie_flag = True
		self.deck = Deck()
		self.consec_ties = 0


	def deal(self):
		self.p1.hand = [self.deck.draw(), self.deck.draw()]
		self.p2.hand = [self.deck.draw(), self.deck.draw()]
		self.river = [self.deck.draw(), self.deck.draw()]

	def flop(self):
		self.river += [self.deck.draw()]

	def discard(self):
		self.deck.order += self.p1.hand + self.p2.hand + self.river
		self.p1.hand = []
		self.p2.hand = []
		self.river = []
		self.deck.shuffle()


	def score_hand(self, holdings):
		if len(holdings) != 4:
			return 0
		ret = 0
		cs = set([x.color for x in holdings])
		ss = set([x.shape for x in holdings])
		if len(ss) == 2: # three of a kind, or two pair
			ret += 1
		if len(ss) == 1: # four kind
			ret += 2
		if len(ss) == 4: # four row
			ret += 2
		if len(cs) == 1: #flush
			ret += 2
		if len(cs) == 4: #rainbow
			ret += 2

		return ret

	def score(self, player):
		return max([self.score_hand(holdings) for holdings in combinations(player.hand + self.river, 4)])

	def score_river(self):
		rs = set([c.shape.value for c in self.river])
		rc = set([c.color.value for c in self.river])

		s = (len(rs), len(rc))
		st = { # These are computed emprircally using a million rounds of simulation 
			(2, 1): 0,
			(1, 1): 1,
			(2, 2): 2,
			(1, 2): 3,
			(3, 2): 4,
			(3, 1): 5,
			(2, 3): 6,
			(3, 3): 7,
			(1, 3): 8
		}
		return st[s]



	def round_outcome(self, winplayer, loseplayer):
		winplayer.wins += self.consec_ties + 1
		loseplayer.losses += self.consec_ties + 1
		log(winplayer.name, "wins!")
		self.last_winner = winplayer
		self.last_looser = loseplayer
		winplayer.money += self.pot
		self.pot = 0
		self.round_end_flag = True
		self.consec_ties = 0

	def make_bets(self):
		def log_bet(player, bet, lastbet=0):
			if bet == -1:
				log(player.name, "folds")	
			elif bet == lastbet:
				if bet == 0:
					log(player.name, "checks")
				else:
					log(player.name, "calls")
			elif bet > lastbet:
				log(player.name, "raises", str(bet - lastbet))

		bet1 = self.first_player.make_move(self.score(self.first_player), self.score_river(), self.pot, -1)
		log_bet(self.first_player, bet1)
		if bet1 == -1:
			self.round_outcome(self.second_player, self.first_player)
			return
		self.first_player.money -= bet1
		self.pot += bet1
		assert bet1 >= 0

		bet2 = self.second_player.make_move(self.score(self.second_player), self.score_river(), self.pot, bet1)
		log_bet(self.second_player, bet2, lastbet=bet1)
		if bet2 == -1:
			self.round_outcome(self.first_player, self.second_player)
			return
		self.second_player.money -= bet2
		self.pot += bet2
		assert bet2 >= bet1

		if bet2 > bet1: #bet2 never < bet1 except for fold, bet1 == bet2 means players are done raising
			#first player gets a chance to match
			bet3 = self.first_player.make_move(self.score(self.first_player), self.score_river(), self.pot, bet2, can_raise=False)
			log_bet(self.first_player, bet3, lastbet=bet2)
			if bet3 == -1:
				self.round_outcome(self.second_player, self.first_player)
				return
			self.first_player.money -= bet3
			self.pot += bet3
			if not bet3 == bet2:
				print(bet2, bet3)
				assert False

		#players have finished raising at this point

	def round(self, n=0): #n should be the round number
		self.tie_flag = False
		self.round_end_flag = False

		def show_round():
			log("R: ", repr(self.river), 
				"\nP1: ", repr(self.p1.hand), "(", str(self.score(self.p1) ), ")", 
				"\nP2: ", repr(self.p2.hand), "(", str(self.score(self.p2) ), ")")
		log("round", str(n), "( P2 has earned", ("+" if self.pevolve.money > 0 else "") + str(self.pevolve.money), ")")
		
		# pay to play
		self.first_player.money -= self.MIN_BET
		self.second_player.money -= self.MIN_BET
		self.pot += self.MIN_BET * 2
		
		self.deal()
		log("deal, pot is", str(self.pot))
		show_round()
		self.make_bets()
		if self.round_end_flag:
			log()
			return

		self.flop()
		log("flop, pot is", str(self.pot))
		show_round()
		self.make_bets()
		if self.round_end_flag:
			log()
			return

		#neither player has folded up until the end
		p1s = self.score(self.p1)
		p2s = self.score(self.p2)

		if p1s > p2s:
			self.round_outcome(self.p1, self.p2)
		elif p2s > p1s:
			self.round_outcome(self.p2, self.p1)
		else:
			#noone wins, so keep playing!
			self.tie_flag = True
			self.consec_ties += 1
			log("tie")
		log()

	def play(self, num_rounds):
		i = 1
		while i <= num_rounds:
			self.round(i)
			self.discard()
			i += 1

		while(self.tie_flag):
			self.round(i)
			self.discard()
			i += 1
