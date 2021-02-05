import alfred
import random
import math


class Strategy:
	def __init__(self, inputs, outputs):
		pass

	def action_weights(self, env):
		pass

	def update(self, score): # score should be the marginal benefit gained by choosing this strategy for this play session
		return False # returns True at the completion of each evolutionary cycle

	def best_chrom(self):
		pass

	def worst_chrom(self):
		pass

	def refresh_metaparams(self, p):
		pass


# Various formulas to 'combine' Dna with the input dimensions. These are what I call "percept functions" in my paper, 
# because they determine how the agent makes decisions with respect to its environment.

linear_combine = lambda chrom, env: \
	[abs(sum(a*b for a,b in zip(row,env + [1]))) for row in chrom]

arithmetic_combine = lambda chrom, env: \
	[abs(sum(a*b for a,b in zip(row,env + [1])))/len(row) for row in chrom]	

pythagorean_combine = lambda chrom, env: \
	[math.sqrt(abs(sum((a*b)**2 for a,b in zip(row,env + [1])))) for row in chrom]	

class Dna:
	MIN_MUT_RATE = 1
	MAX_MUT_RATE = 50
	MIN_MAX_GENE_VAL = 10
	MAX_MAX_GENE_VAL = 100

	def __init__(self, inputs, outputs, chrom=None, mut_rate=10, max_gene_val=10, combine_formula=lambda c, e: linear_combine(c, e)): 
		# The chromosome will be `inputs` columns and `outputs` rows.
		self.fitness = None
		self.total_score = 0
		self.times = 0
		self.mut_rate = mut_rate
		self.max_gene_val = max_gene_val
		if chrom is None:
			self.chrom =  [ 
				[ random.uniform(-self.max_gene_val, self.max_gene_val) for _ in range(inputs + 1) ] # +1 for the constant bias
					for _ in range(outputs)
			]
		else:
			self.chrom = chrom
		self.inputs = inputs
		self.outputs = outputs
		self.combine_formula = combine_formula
		
	def update(self, score):
		self.total_score += score
		self.times += 1
		self.fitness = self.total_score / self.times

	def combine(self, env): #not quite matrix multiplication
		return self.combine_formula(self.chrom, env)

	def crossover(self, other):
		assert self.inputs == other.inputs
		assert self.outputs == other.outputs

		ret = [[t for t in row] for row in self.chrom]
		col_cross = random.randint(0, self.inputs+1 - 1)
		row_cross = random.randint(0, self.outputs - 1)

		flip1 = random.randint(0, 1)
		r1 = range(row_cross, self.inputs+1)
		if flip1:
			r1 = range(0, row_cross)
		flip2 = random.randint(0, 1)
		r2 = range(col_cross, self.outputs)
		if flip2:
			r2 = range(0, col_cross)

		# splice in other's values after col_cross and row_cross 
		for i in r1:
			for j in r2:
				ret[i][j] = other.chrom[i][j]

		return Dna(self.inputs, self.outputs, chrom=ret, mut_rate=self.mut_rate, max_gene_val=self.max_gene_val, combine_formula=self.combine_formula)

	def mutate(self):
		how_many_times_to_alter = random.randint(0, self.mut_rate)
		for n in range(how_many_times_to_alter):
			col = random.randint(0, self.inputs+1 - 1)
			row = random.randint(0, self.outputs - 1)
			adj = random.uniform(-1,1)
			if self.chrom[row][col] == self.max_gene_val:
				adj = min(adj, 0)
			elif self.chrom[row][col] == -self.max_gene_val:
				adj = max(adj, 0)
			self.chrom[row][col] = self.chrom[row][col] + adj

	def refresh_metaparams(self, p):
		if p > 0:
			self.max_gene_val = min(int(self.max_gene_val * p), Dna.MAX_MAX_GENE_VAL)
			self.mut_rate = max(Dna.MIN_MUT_RATE, int(self.mut_rate / p))
		elif p < 0:
			p = -p 
			self.max_gene_val = max(int(self.max_gene_val / p), Dna.MIN_MAX_GENE_VAL)
			self.mut_rate = min(Dna.MAX_MUT_RATE, int(self.mut_rate * p))


class StaticStrategy(Strategy):
	def __init__(self, inputs, outputs, chrom=None, mut_rate=10, max_gene_val=10):
		self.dna = Dna(inputs, outputs, chrom=chrom, mut_rate=mut_rate, max_gene_val=max_gene_val)

	def action_weights(self, env):
		return self.dna.combine(env)

	def update(self, score):
		return True

	def best_chrom(self):
		return self.dna

	def worst_chrom(self):
		return self.dna

	def refresh_metaparams(self, p):
		self.dna.refresh_metaparams(p)

class GeneticSearch(Strategy):
	POP_SIZE = 30 

	def __init__(self, inputs, outputs, deaths_per_gen=15, mut_rate=10, max_gene_val=10, combine_formula=lambda c, e: linear_combine(c, e)):
		self.inputs = inputs
		self.outputs = outputs
		self.deaths_per_gen = deaths_per_gen
		self.mut_rate = mut_rate
		self.max_gene_val = max_gene_val
		seed = Dna(inputs, outputs, mut_rate=mut_rate, max_gene_val=max_gene_val, combine_formula=combine_formula)
		self.population = [
			Dna(inputs, outputs, chrom=seed.chrom, mut_rate=mut_rate, max_gene_val=max_gene_val, combine_formula=combine_formula) 
				for _ in range(GeneticSearch.POP_SIZE)
		]
		for x in self.population:
			x.mutate()
		self.dna_index = 0
		self.__best_chrom = None
		self.__worst_chrom = None
		self.train_time = 0


	def dna(self):
		return self.population[self.dna_index]

	def rws(self, last=None): # `last` is used so that we guarentee finding two unique parents
		pick_thresh = random.uniform(0, sum(dna.fitness - self.__worst_chrom.fitness for dna in self.population))
		current = 0
		for i, dna in enumerate(self.population):
			current += dna.fitness - self.__worst_chrom.fitness
			if current > pick_thresh:
				if last is None or i != last:
					return i
				else:
					return i + (1 if i < len(self.population) - 1 and (i == 0 or random.randint(0, 1)) else -1)
		return len(self.population) - 1

	def action_weights(self, env): # env = [cur_score, river_score, pot, last_bet]
		assert len(env) == self.inputs
		if self.dna_index >= GeneticSearch.POP_SIZE:
			raise Exception("population empty")
		return self.dna().combine(env)
		

	def update(self, score): 
		self.dna().update(score)
		self.__best_chrom = ( 
			self.dna() if self.__best_chrom is None or self.dna().fitness > self.__best_chrom.fitness
				else self.__best_chrom
		)
		self.__worst_chrom = ( 
			self.dna() if self.__worst_chrom is None or self.dna().fitness < self.__worst_chrom.fitness
				else self.__worst_chrom
		)

		self.dna_index += 1
		if self.dna_index >= GeneticSearch.POP_SIZE:
			self.dna_index = 0
			self.evolve()
			return True
		return False


	def evolve(self):
		assert len(self.population) == GeneticSearch.POP_SIZE
		smallest10_indexes = alfred.nsmallest(self.population, n=self.deaths_per_gen, key=lambda o: o.fitness)
		for i in sorted(smallest10_indexes, reverse=True):
			del self.population[i]
		parent1_ind = self.rws()
		parent2_ind = self.rws(last=parent1_ind)
		assert parent1_ind != parent2_ind
		for i in range(self.deaths_per_gen):
			child = self.population[parent1_ind].crossover(self.population[parent2_ind])
			child.mutate()
			self.population += [child]
		assert len(self.population) == GeneticSearch.POP_SIZE

	def best_chrom(self):
		return self.__best_chrom

	def worst_chrom(self):
		return self.__worst_chrom

	def refresh_metaparams(self, p):
		for dna in self.population:
			dna.refresh_metaparams(p)

class GeneticArmedBandit(Strategy):
	def __init__(self, inputs, outputs, mut_rate=10, max_gene_val=10, combine_formula=lambda c, e: linear_combine(c, e)):
		self.g = GeneticSearch(inputs,outputs,mut_rate=mut_rate, max_gene_val=max_gene_val, combine_formula=combine_formula)
		self.fitness = float("inf")
		self.times = 1

	def ucb(self, time, fitness_sum):
		return self.fitness / fitness_sum + math.sqrt(math.log(2*time)/self.times)

	def update(self, score):
		evolved = self.g.update(score)
		self.times += 1
		self.fitness = self.g.best_chrom().fitness
		return evolved

	def action_weights(self, env):
		return self.g.action_weights(env)

	def best_chrom(self):
		return self.g.best_chrom()

	def worst_chrom(self):
		return self.g.worst_chrom()

	def refresh_metaparams(self, p):
		self.g.refresh_metaparams(p)

class GMAB(Strategy):
	def __init__(self, inputs, outputs, rho=1.1, formulas=[linear_combine, arithmetic_combine, pythagorean_combine]): # rho indicates how aggressively to alter strategies that are performing very well or very poorly
		# We have three combine formulas and do not know beforehand 
		# which is optimal for the current situation; chances are  
		# good that they will not converge to the same global max.
		# So, we allow GMAB to decide which one to use for us.
		self.strategies = [GeneticArmedBandit(inputs, outputs, combine_formula=x) for x in formulas]
		self.strategy_index = 0
		self.times = 1
		self.rho = abs(rho)

	def current_strat(self):
		return self.strategies[self.strategy_index]

	def update(self, score):
		self.times += 1
		evolved = self.current_strat().update(score)
		ftn = sorted(list(range(len(self.strategies))), key=lambda i: self.strategies[i].fitness, reverse=True)
		if ftn[0] != float("inf"):
			self.strategies[ftn[0]].refresh_metaparams(self.rho)
			self.strategies[ftn[-1]].refresh_metaparams(-self.rho)
		sf = sum(ftn)
		self.strategy_index = max(range(len(self.strategies)), key=lambda i: self.strategies[i].ucb(self.times, sf))

		return evolved

	def action_weights(self, env):
		return self.current_strat().action_weights(env)

	def best_chrom(self):
		return max(self.strategies, key=lambda x: x.best_chrom().fitness).best_chrom()

	def worst_chrom(self):
		return min(self.strategies, key=lambda x: x.worst_chrom().fitness).worst_chrom()

	def refresh_metaparams(self, p):
		self.rho = p


		
		
		