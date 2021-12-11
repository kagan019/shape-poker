### A Pluto.jl notebook ###
# v0.17.2

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
end

# ╔═╡ 2ec90f9f-d92d-45c6-8d15-e0153259c7c5
using PlutoUI, HypertextLiteral, Dates, Plots

# ╔═╡ 91de6368-6e15-42d9-8fff-e0b3a4a162f2
begin
md"_press ctrl+./ctrl+, to advance/rewind the presentation_"
nothing
end

# ╔═╡ 26440e94-9ae4-4845-a733-b752233a5a34
begin
	psdiv = @htl("<div>
	<script>
	let div = currentScript.parentElement;
	let downevt = (e) => {
	   if (e.code == 'Period') { if (document.alt_down) {
		div.value = div.value + 1;
	    div.dispatchEvent(new CustomEvent('input'));
	   } }
	   if (e.code == 'Comma') {
			if (document.alt_down) {
				div.value = (
					(div.value > 0) 
						? div.value - 1 
						: 0
				);
	            div.dispatchEvent(new CustomEvent('input'));
			}
	        
	   }
	   if (e.code == 'ControlRight') {document.alt_down = true}
	}
	let upevt = (e) => {
		if (e.code == 'ControlRight') {document.alt_down = false}
	}
	div.value = 0;
	document.alt_down = false
	document.onkeydown = downevt
	document.onkeyup = upevt
	
	
	
	</script>
	</div>
	")
	@bind pres_state psdiv
end

# ╔═╡ ed957203-dd59-464c-937e-0b4f135216bf
begin
plotly()
nothing
end

# ╔═╡ d3ab82e2-525d-11ec-2828-4da3904be0ee
md"# shape poker
© 2021 Thomas Kagan"

# ╔═╡ 8114c5a1-958c-4343-8375-e069563ca2be
md"[on github](https://github.com/kagan019/shape-poker)"

# ╔═╡ f9952443-595c-4af8-afcb-7ca7e7ce0aa7
begin
learns = (pres_state < 1) ? "learns" : "_learns_"
Markdown.parse("""## goal
make a program that automatically $learns to improve at a computer game
""")
end

# ╔═╡ 6bba50da-156f-4548-951e-f4efe989063d
md"what game should it play?"

# ╔═╡ e8c1daaf-73f8-4f3e-bf39-70315098d661
begin
boring_mc_house = md"![](https://lh5.googleusercontent.com/proxy/Hkct3vVf4opVe7H37wQY_hdkoxk27Sq6pdKRh-rjxdDxHtteDfPFN7ExCHzovns4Mj-_OSwAVY-Y911rTeua4UlsJoQ5reJr26Rl6Z7E-4U=w1200-h630-p-k-no-nu)"
cool_mc_house = md"![](https://i.ytimg.com/vi/xTFHsKbzpsw/mqdefault.jpg)"
md"**Minecraft**? $boring_mc_house
vs $cool_mc_house"
end

# ╔═╡ 947bcedd-8064-4cdf-a252-591580a0e57e
begin
minesweeper = md"![](https://stuffprime.com/unblocked-games/minesweeper-unblocked-online/)"
ms_youtube = LocalResource(abspath("minesweeper_youtube_vid.png"))
md"Mine**sweeper**? $minesweeper
hold on... $ms_youtube"
end

# ╔═╡ c7ce6d21-a013-4a24-a4d3-548ea9b8277c
md"**Dark Souls II** ![](https://cdn-products.eneba.com/resized-products/9FxUfM08nYDUI22EKofNTpE5L_r_NgIO4vLHDe9g9dA_350x200_3x-0.jpg)"

# ╔═╡ 849bad17-9f2c-416e-ad05-c59901865080
md"... ![](https://i.ytimg.com/vi/DPtpJizECDE/maxresdefault.jpg)"

# ╔═╡ 8bba398a-03de-4312-9f9f-00b49ee70d65
begin
goodparts = Markdown.parse("""![](https://www.pokerlistings.com/wp-content/uploads/2019/09/UltimateTexasHoldem5.jpg) 

Bingo!
* zero-sum
* imperfect information
* easy to score
* simple
""")
badpart = md"* computationally large"
@htl("""
$goodparts
<span style='color:red'>$badpart</span>
""")
end

# ╔═╡ cd782adf-44a5-4c76-b5ba-8baaac598c21
begin
newgoal = @htl("<h2>goal <span style='position: relative; font-size:0.4em;'>1.1.0</span></h2>
make a program that automatically learns to improve at <strike>a computer game</strike>")
atsp = html"<span style='color:blue'><em>shape poker</em></span>"
added_goal = @htl("""<span style='font-size:.9em;'>$(md"* study local minimums and how to avoid them")</span>""")
@htl("""$newgoal $atsp $added_goal""")
end

# ╔═╡ 8688a097-8583-4c53-8b8d-8d77df23dd82
md"## success!"

# ╔═╡ 8c0c1f32-e051-43a0-b3e0-cab4a44b4f3b
function plot_success_data(data :: String)
	seeds = eachmatch(r"seed ([0-9]+) $"m, data) |> 
		Base.Fix1(map,m->parse(Int,m.captures[1])) |> collect
	scores = eachmatch(r"^Evolving player's money: ([-]?[0-9]+)$"m,data) |> 
		Base.Fix1(map,m->parse(Int,m.captures[1])) |> collect
	scatter(seeds,scores)
	scatter!(xlabel="seed", ylabel="won money")
end

# ╔═╡ b4136155-3afe-4a98-bbc2-ab6ac7c88a8c
function run_metric(command_name)
	# Make a fresh analysis for today
	# Dated so I don't redo work
	fname = "$(Dates.today()) $command_name.txt"
	if fname ∉ readdir("../out")
		# no metric for today? good, let's make a new one.
		cd("..") do
			pipeline(`python -c "from metrics import *; $command_name()"`; 
				stdout="out/$fname",
			) |> run
		end
	end
	"../out/$fname"
end


# ╔═╡ ba5b6b87-9d60-40db-afcd-0e2398a70667
begin
k=1
# find the indexes between studies
lines = split(read(run_metric("benchmark_genetic_search_strategy"),String),"\n")
v = map(enumerate(lines)) do (i,s)
	if !isnothing(match(r"linear"m, s))
		i
	end
end |> Base.Fix1(filter, (!) ∘ isnothing)

# extract all the points of the study
p = map(eachmatch(
	r"\(([0-9]*), ([-]?[0-9]*)\)"m, 
	foldl((*),lines[v[k]:v[k+1]])
)) do m
	parse(Int,m.captures[1]),parse(Int,m.captures[2])
end
scatter(p)
scatter!(xlabel="round", ylabel="money won")
end

# ╔═╡ 858f96ef-f482-45d5-a5c6-bc1e8944d894
md"## project"

# ╔═╡ b6c0532f-b9ae-4d8a-8a8e-0116c598ce9a
md"
* the game - components, rules, simulation
* the player - perception, interpretation, decision making
* the learning algorithm - feedback, learning
"

# ╔═╡ 50feddb8-86dd-40a7-b576-aa381b75d29a
md"*my contributions"

# ╔═╡ 38cd6518-7966-424e-98ed-9d0facf86a76
md"##### features"

# ╔═╡ f409b036-2c71-4b25-9fa1-4054b82037df
md"_The composition of the meanings is the meaning of the composition_"

# ╔═╡ 288f9a63-9397-4443-b0d6-3b7684da4946
md"
* self-contained
* modular
* reproducible
"

# ╔═╡ 560ed0fd-734f-4344-8cca-8c9b2cf1b919
md"## game"

# ╔═╡ b6ce4b17-d46c-48bf-8137-3b869774eed8
md"##### fairness"

# ╔═╡ e0e24b9a-088e-46c3-b15e-0ea07b3c09b4
md"have two NON evolving players duke it out"

# ╔═╡ bc05f3b0-e828-44a6-8f62-c4c7aba5377a
frns = read(run_metric("fairness"), String) 

# ╔═╡ 8f969c1b-1c72-45f2-a0fd-6615507bd1fa
frns_winpcnt = map(eachmatch(r"rounds\n(0\.[0-9]+)\n", frns)) do m
	parse(Float64,m.captures[1])
end

# ╔═╡ 04332b21-2f2b-424c-8c3a-4b7dc7157ecd
split(frns,"\n")[end-1]

# ╔═╡ 5f29f0dd-8b3a-4fd8-95f3-ad4e01de2afd
md"- Either player equally likely to win *for any two random players
- Some players are not as good against others"

# ╔═╡ 846de6c4-bfc5-4613-9b29-2f459838b5ae
split(read(run_metric("frequency_of_hand_score"),String), "\n")

# ╔═╡ 3ed04359-e6d0-446d-a894-d59c5eaa2181
md"_how often the score of a (nonevolving) player's hand wins the round_"

# ╔═╡ 8e113861-2578-4c65-b03b-f51f947cdfd1
md"##### components"

# ╔═╡ 3b150a37-e32c-420a-aa80-509402b8cb3e
@htl("""
<svg width="440" height = "110">
	<rect width="100" height="100" stroke-width="none" fill="rgb(250,0,0)"/>
	<circle cy="50" cx="160" r="50" fill="rgb(0,0,250)"/>
	<polygon points="220,100 320,100 270,0" fill="rgb(0,240,0)" />
	<polygon points="330,50 380,100 430,50 380,0" fill="rgb(220,0,250)">
</svg>
""")

# ╔═╡ 8ecd9a0b-16d4-4c45-949a-1d077ba1f12e
md"
- a card for every combination of shape x color
- cards appear 4 times each
- 2 players dealt 2 cards
- 2-3 cards on table, \"river\"
"

# ╔═╡ 336f28e5-4664-48ec-93b4-975ef05d6f26
md"##### example"

# ╔═╡ 8f75bd2c-2dd2-4c52-b4f9-248a1eed5262
read(run_metric("example_rounds"), String) |> 
	Base.Fix2(split,"\n")

# ╔═╡ e9bf6cc4-809f-4d94-8e41-35a385df6b5b
md"##### rules"

# ╔═╡ 3fef783d-b2d6-4713-bf14-4a130368ce21
md"
1. deck is shuffled
2. each player draws 2 cards, and 2 cards are placed in the river
3. P1 makes a bet. 
4. P2 can match it (call), fold, or raise
5. P1 can call, fold, raise
6. a third card is placed in the river
7. players take turns betting again
8. scores are tallied
7. if theres a tie, the pot carries over to the next round
8. restart at 1. for the next round
"

# ╔═╡ 043df08b-d08e-4d52-bcf9-863b97985c04
md"##### scoring"

# ╔═╡ 2136c3c5-5e5d-4844-9dd7-3a920b86935a
md"
```python
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
```
"

# ╔═╡ d87dd601-5779-4255-97c3-7caf7e636437
@htl("""<span>$(md"_shapepoker.py_")</span>""")

# ╔═╡ 24e33672-4d56-4c54-8cad-53623476d507
md"## player"

# ╔═╡ 6a9ede18-486c-4e20-9b86-cd8d1d938ca5
begin
env_emoji = Resource("https://uc-emoji.azureedge.net/orig/d8/9d88bc13d3d806848be21727dbae7f.png", :width => 25, :height => 25)
act_emoji = Resource("https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/google/313/man-lifting-weights_1f3cb-fe0f-200d-2642-fe0f.png", :width => 25, :height => 25)
strat_emoji = Resource("https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/google/313/brain_1f9e0.png", :width=>25, :height=>25)
perc_emoji = Resource("https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/google/313/eye_1f441-fe0f.png", :width=>25, :height=>25)
md"""
- "action weights" $(act_emoji)
- "environment" $(env_emoji)
- "strategy representations" $(strat_emoji)
- "percept functions" $(perc_emoji)
 $perc_emoji ( $env_emoji , $strat_emoji ) = $act_emoji
"""
end

# ╔═╡ 56314477-9691-4628-befb-50581877e166
md"##### \"environment\" $env_emoji"

# ╔═╡ 87769b77-5a94-472a-8145-2add1b935ec0
md"![](https://www.mdpi.com/symmetry/symmetry-12-01789/article_deploy/html/images/symmetry-12-01789-g001.png)"

# ╔═╡ 12c95972-9a31-4cf7-882d-47e59e28569d
md"""
```python
w = self.strategy.action_weights([cur_score, river_score, pot, last_bet]) 
									# 4 input dimensions
```
"""

# ╔═╡ c1a897f7-acc4-4d35-b58c-4ecf19cb9e9a
md"""
```python
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
```
"""

# ╔═╡ 99524729-bab2-48d9-9b0f-e7d1453d229b
read(run_metric("river_score_vs_average_holding_score"),String) |>
	Base.Fix2(split,"\n")

# ╔═╡ 8f3f2c72-3103-49ca-a0fe-c7698ad5a126
md"##### \"action weights\" $act_emoji"

# ╔═╡ 4d5577c6-a50e-4e40-b50f-86975a0a7824
begin
md"""
```python
# w is a list of weights, like `[.10, .25, 0, .25, .40]` (unnormalized)

# fold -> -1
# check -> 0
# call -> bet_to_match
# raise -> int > bet_to_match
possible_bets = [-1, 0, 1, 2, 3] # 5 output dimensions
bet = -1
if sum(w) != 0:
	bet = random.choices(possible_bets, weights=w)[0]
return bet
```
"""
end

# ╔═╡ 5f6d8439-f6c7-4c89-96de-58ba956a63bf
md"_shapepoker.py_"

# ╔═╡ 477354cf-34dc-4ebb-907f-3563fb455023
md"in context,"

# ╔═╡ cf3ad448-27b7-4093-b920-147aec20db08
md"""```python
def make_move(self, cur_score, river_score, pot, last_bet, can_raise=True):
		# domain-specific part of the action selection process
		w = self.strategy.action_weights([cur_score, river_score, pot, last_bet]) # 4 input dimensions
		betr = max(0, last_bet)
		w = ( w[0:1] +
			[0 for _ in range(betr)] + ( # have to bet at least as much as opponent
				w[betr + 1:]             # keep the remaining weights
				if can_raise else 
				( [w[betr + 1]] +        # after P2 bets, P2 can only call or fold.
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
```"""

# ╔═╡ 1edf7e9e-2bc6-4e30-ba56-3f89c9b64ef1
md"##### \"strategy representations\" $strat_emoji"

# ╔═╡ 21a65132-756c-4754-b939-3c5ee4e45a7f
md"""
```python
w = self.strategy.action_weights([cur_score, river_score, pot, last_bet]) 
   # 4 input dimensions + 1
```
```python
possible_bets = [-1, 0, 1, 2, 3] # 5 output dimensions
```
"""

# ╔═╡ bfc6a235-2e09-4b5c-870d-948da20ef0bb
begin
money_emoji = Resource("https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/microsoft/310/money-bag_1f4b0.png", :width=>25, :height=>25)
sad_emoji = Resource("https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/google/313/pensive-face_1f614.png", :width=>25, :height=>25)
ok_emoji = Resource("https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/joypixels/291/ok-hand_1f44c.png", :width=>25, :height=>25)
bank_emoji = Resource("https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/google/313/bank_1f3e6.png",  :width=>25, :height=>25)
river_emoji = Resource("https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/samsung/312/water-wave_1f30a.png", :width=>25, :height=>25)
pot_of_gold_emoji = Resource("https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/htc/37/honey-pot_1f36f.png", :width=>25, :height=>25)
time_emoji = Resource("https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/microsoft/310/hourglass-done_231b.png", :width=>25, :height=>25)
mtx = md"""
$\begin{bmatrix}
• & • & • & • & •\\
• & • & • & • & •\\
• & • & • & • & •\\
• & • & • & • & •\\
• & • & • & • & •\\
\end{bmatrix}$
"""
@htl """
<div>
<span style="position: absolute; left:16.8em; top:-.5em;">$bank_emoji</span>
<span style="position: absolute; left:18.4em; top:-.5em;">$river_emoji</span>
<span style="position: absolute; left:19.9em; top:-.5em;">$pot_of_gold_emoji</span>
<span style="position: absolute; left:21.4em; top:-.5em;">$time_emoji</span>
<span style="position: absolute; left:23.5em; top:-.5em;">1</span>
<span style="position: absolute; left: 14.8em; top: .5em;">$sad_emoji</span>
<span style="position: absolute; left: 14.8em; top: 2em;">$ok_emoji</span>
<span style="position: absolute; left: 14.8em; top: 3.5em;">1 $money_emoji</span>
<span style="position: absolute; left: 14.8em; top: 5em;">2 $money_emoji</span>
<span style="position: absolute; left: 14.8em; top: 6.5em;">3 $money_emoji</span>
</div>
$mtx

"""
end

# ╔═╡ f5a6edb2-dc2d-4bc2-915c-bdbb9338e3ae
md"""$
\begin{bmatrix}
0 & 0 & 0 & 0 & 1\\
0 & 0 & 0 & 0 & 0\\
0 & 0 & 0 & 0 & 0\\
0 & 0 & 0 & 0 & 0\\
0 & 0 & 0 & 0 & 0\\
\end{bmatrix}$
$
\begin{bmatrix}
1 & 0 & 0 & 0 & 1\\
1 & 0 & 0 & 0 & 1\\
1 & 0 & 0 & 0 & 1\\
1 & 0 & 0 & 0 & 1\\
1 & 0 & 0 & 0 & 1\\
\end{bmatrix}$
"""

# ╔═╡ 62fe15fc-652c-4df1-9c25-756c27b4043e
md"##### \"percept functions\" $perc_emoji"

# ╔═╡ 7e59354b-f77a-46e6-b414-eaa74ef633b7
md"```python
linear_combine = lambda chrom, env: \
	[abs(sum(a*b for a,b in zip(row,env + [1]))) for row in chrom]

arithmetic_combine = lambda chrom, env: \
	[abs(sum(a*b for a,b in zip(row,env + [1])))/len(row) for row in chrom]	

pythagorean_combine = lambda chrom, env: \
	[math.sqrt(abs(sum((a*b)**2 for a,b in zip(row,env + [1])))) for row in chrom]
```"

# ╔═╡ 1c3aabbf-15e7-4074-ac8f-14da8970b73d
begin
data = read(run_metric("compare_combine_formulas"),String)

function fetch_seeds()
	matches = eachmatch(r"seed ([0-9]*)"m, data)
	map(matches) do m
		parse(Int,m.captures[1])
	end
end
	
seeds= fetch_seeds()
	
function fetch_combine_stats(frmla_name :: String)
	matches = eachmatch(Regex("'$frmla_name', (.*)\\)", "m"), data)
	map(matches) do m
		parse(Int,m.captures[1])
	end
end
lin = fetch_combine_stats("Linear")
arith = fetch_combine_stats("Arithmetic")
pyth = fetch_combine_stats("Pythagorean")
scatter(zip(seeds, lin) |> collect, label="linear")
scatter!(zip(seeds,arith) |> collect, label="arithmetic")
scatter!(zip(seeds, pyth) |> collect, label="pythagorean")
end

# ╔═╡ 9a657c77-ae73-4b7f-98dd-29dd658bdb3e
md"## learning algorithm"

# ╔═╡ ab48307d-f7d6-447f-a792-cddc2f520d38
LocalResource("../presentation_assets/rws.png", :width => 600, :height => 1200)

# ╔═╡ 7aaa144f-2091-4c56-901e-2819778318d8
begin
dna_emoji = Resource("https://uc-emoji.azureedge.net/orig/f6/827423e093ddfdeacbe9ca96e94ed4.png", :width=>25, :height=>25)
md"
 $strat_emoji = $dna_emoji
"
end

# ╔═╡ 86731b90-b54d-4329-8d5f-f5aedb959607
md"
```python
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
```
"

# ╔═╡ 9d499ead-2706-4c56-a532-61430a149abb
md"
```python
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
```
"

# ╔═╡ 0c5e1f17-222a-4280-b9f3-7c07ca80ae2a
md"## voila!"

# ╔═╡ 52d753cd-5fa9-4067-875a-48c1ad09b048
md"![](https://www.2025ad.com/hs-fs/hubfs/how%20close%20are%20we%202025ad.png?width=602&height=338&name=how%20close%20are%20we%202025ad.png)"

# ╔═╡ 62b20983-592e-412e-8e4f-d90b7f7a6175
md"[https://defensemaven.io/warriormaven/air/why-an-air-force-6th-gen-stealth-fighter-is-here-almost-10-years-early-Q9gApEljfk-3iXPKqvmH5Q](https://defensemaven.io/warriormaven/air/why-an-air-force-6th-gen-stealth-fighter-is-here-almost-10-years-early-Q9gApEljfk-3iXPKqvmH5Q)"

# ╔═╡ 9845cc46-f565-4fef-8781-ed02c646d15c
md"## future"

# ╔═╡ 71664389-7bee-400d-9554-7c56988bb566
md"
> Genetic algorithms are simple to implement, but their behavior is difficult to understand. In particular, it is difficult to understand why these algorithms frequently succeed at generating solutions of high fitness when applied to practical problems.
"

# ╔═╡ 935e6d2e-f1d0-4ea4-afa0-25168031cd93
md"[https://en.wikipedia.org/wiki/Genetic_algorithm#The_building_block_hypothesis](https://en.wikipedia.org/wiki/Genetic_algorithm#The_building_block_hypothesis)"

# ╔═╡ feabf101-5e5d-4b7b-945e-74c4666d3811
md"
> In his Algorithm Design Manual, Skiena advises against genetic algorithms for any task:
>> [I]t is quite unnatural to model applications in terms of genetic operators like mutation and crossover on bit strings. The pseudobiology adds another level of complexity between you and your problem. Second, genetic algorithms take a very long time on nontrivial problems. [...] [T]he analogy with evolution—where significant progress require [sic] millions of years—can be quite appropriate.
>> [...]
>> I have never encountered any problem where genetic algorithms seemed to me the right way to attack it. Further, I have never seen any computational results reported using genetic algorithms that have favorably impressed me. Stick to simulated annealing for your heuristic search voodoo needs.
> — Steven Skiena[31]: 267 

"

# ╔═╡ e3f47f60-4ff9-4a78-af19-a3f33b956965
@htl """
<iframe width="560" height="315" src="https://www.youtube.com/embed/YZUNRmwoijw" title="YouTube video player" frameborder="0" allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
"""

# ╔═╡ d9a282b7-d11b-4d5b-8724-37b541e643d9
md"![](https://images.immediate.co.uk/production/volatile/sites/4/2018/08/GettyImages-85757595-97ef2bc.jpg?quality=90&crop=6px,33px,928px,399px&resize=960,413)"

# ╔═╡ b9dd27ef-01c0-4e87-a7a4-af230846922a
md"
- compare with other symmetric emergent optimization algorithms
- enable a more sophisticated tournament setup for transfer
- require the `Strategy`™ grok how to play the game by itself
"

# ╔═╡ 8a1cd3b2-a68d-4e8b-9603-5e752ac9111c
md"## enhancements"

# ╔═╡ 529c90bf-d1e7-4cbd-a1ee-1f8d7146220f
md"
- clean up frontend so more metrics can be added easily (variances, realtime perf)
- try more processing power; graphics, vcs, etc for end behavior
- refine the game
"

# ╔═╡ c6edb03f-8bee-42e7-9f72-8931f3161d0e
md"# thanks!"

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
Dates = "ade2ca70-3891-5945-98fb-dc099432e06a"
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
Plots = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"

[compat]
HypertextLiteral = "~0.9.3"
Plots = "~1.25.1"
PlutoUI = "~0.7.21"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

[[AbstractPlutoDingetjes]]
deps = ["Pkg"]
git-tree-sha1 = "abb72771fd8895a7ebd83d5632dc4b989b022b5b"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.1.2"

[[Adapt]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "84918055d15b3114ede17ac6a7182f68870c16f7"
uuid = "79e6a3ab-5dfb-504d-930d-738a2a938a0e"
version = "3.3.1"

[[ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"

[[Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"

[[Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"

[[Bzip2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "19a35467a82e236ff51bc17a3a44b69ef35185a2"
uuid = "6e34b625-4abd-537c-b88f-471c36dfa7a0"
version = "1.0.8+0"

[[Cairo_jll]]
deps = ["Artifacts", "Bzip2_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "JLLWrappers", "LZO_jll", "Libdl", "Pixman_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "f2202b55d816427cd385a9a4f3ffb226bee80f99"
uuid = "83423d85-b0ee-5818-9007-b63ccbeb887a"
version = "1.16.1+0"

[[ChainRulesCore]]
deps = ["Compat", "LinearAlgebra", "SparseArrays"]
git-tree-sha1 = "4c26b4e9e91ca528ea212927326ece5918a04b47"
uuid = "d360d2e6-b24c-11e9-a2a3-2a2ae2dbcce4"
version = "1.11.2"

[[ChangesOfVariables]]
deps = ["LinearAlgebra", "Test"]
git-tree-sha1 = "9a1d594397670492219635b35a3d830b04730d62"
uuid = "9e997f8a-9a97-42d5-a9f1-ce6bfc15e2c0"
version = "0.1.1"

[[ColorSchemes]]
deps = ["ColorTypes", "Colors", "FixedPointNumbers", "Random"]
git-tree-sha1 = "a851fec56cb73cfdf43762999ec72eff5b86882a"
uuid = "35d6a980-a343-548e-a6ea-1d62b119f2f4"
version = "3.15.0"

[[ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "024fe24d83e4a5bf5fc80501a314ce0d1aa35597"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.0"

[[Colors]]
deps = ["ColorTypes", "FixedPointNumbers", "Reexport"]
git-tree-sha1 = "417b0ed7b8b838aa6ca0a87aadf1bb9eb111ce40"
uuid = "5ae59095-9a9b-59fe-a467-6f913c188581"
version = "0.12.8"

[[Compat]]
deps = ["Base64", "Dates", "DelimitedFiles", "Distributed", "InteractiveUtils", "LibGit2", "Libdl", "LinearAlgebra", "Markdown", "Mmap", "Pkg", "Printf", "REPL", "Random", "SHA", "Serialization", "SharedArrays", "Sockets", "SparseArrays", "Statistics", "Test", "UUIDs", "Unicode"]
git-tree-sha1 = "dce3e3fea680869eaa0b774b2e8343e9ff442313"
uuid = "34da2185-b29b-5c13-b0c7-acf172513d20"
version = "3.40.0"

[[CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"

[[Contour]]
deps = ["StaticArrays"]
git-tree-sha1 = "9f02045d934dc030edad45944ea80dbd1f0ebea7"
uuid = "d38c429a-6771-53c6-b99e-75d170b6e991"
version = "0.5.7"

[[DataAPI]]
git-tree-sha1 = "cc70b17275652eb47bc9e5f81635981f13cea5c8"
uuid = "9a962f9c-6df0-11e9-0e5d-c546b8b5ee8a"
version = "1.9.0"

[[DataStructures]]
deps = ["Compat", "InteractiveUtils", "OrderedCollections"]
git-tree-sha1 = "7d9d316f04214f7efdbb6398d545446e246eff02"
uuid = "864edb3b-99cc-5e75-8d2d-829cb0a9cfe8"
version = "0.18.10"

[[DataValueInterfaces]]
git-tree-sha1 = "bfc1187b79289637fa0ef6d4436ebdfe6905cbd6"
uuid = "e2d170a0-9d28-54be-80f0-106bbe20a464"
version = "1.0.0"

[[Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"

[[DelimitedFiles]]
deps = ["Mmap"]
uuid = "8bb1440f-4735-579b-a4ab-409b98df4dab"

[[Distributed]]
deps = ["Random", "Serialization", "Sockets"]
uuid = "8ba89e20-285c-5b6f-9357-94700520ee1b"

[[DocStringExtensions]]
deps = ["LibGit2"]
git-tree-sha1 = "b19534d1895d702889b219c382a6e18010797f0b"
uuid = "ffbed154-4ef7-542d-bbb7-c09d3a79fcae"
version = "0.8.6"

[[Downloads]]
deps = ["ArgTools", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"

[[EarCut_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "3f3a2501fa7236e9b911e0f7a588c657e822bb6d"
uuid = "5ae413db-bbd1-5e63-b57d-d24a61df00f5"
version = "2.2.3+0"

[[Expat_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b3bfd02e98aedfa5cf885665493c5598c350cd2f"
uuid = "2e619515-83b5-522b-bb60-26c02a35a201"
version = "2.2.10+0"

[[FFMPEG]]
deps = ["FFMPEG_jll"]
git-tree-sha1 = "b57e3acbe22f8484b4b5ff66a7499717fe1a9cc8"
uuid = "c87230d0-a227-11e9-1b43-d7ebe4e7570a"
version = "0.4.1"

[[FFMPEG_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "JLLWrappers", "LAME_jll", "Libdl", "Ogg_jll", "OpenSSL_jll", "Opus_jll", "Pkg", "Zlib_jll", "libass_jll", "libfdk_aac_jll", "libvorbis_jll", "x264_jll", "x265_jll"]
git-tree-sha1 = "d8a578692e3077ac998b50c0217dfd67f21d1e5f"
uuid = "b22a6f82-2f65-5046-a5b2-351ab43fb4e5"
version = "4.4.0+0"

[[FixedPointNumbers]]
deps = ["Statistics"]
git-tree-sha1 = "335bfdceacc84c5cdf16aadc768aa5ddfc5383cc"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.4"

[[Fontconfig_jll]]
deps = ["Artifacts", "Bzip2_jll", "Expat_jll", "FreeType2_jll", "JLLWrappers", "Libdl", "Libuuid_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "21efd19106a55620a188615da6d3d06cd7f6ee03"
uuid = "a3f928ae-7b40-5064-980b-68af3947d34b"
version = "2.13.93+0"

[[Formatting]]
deps = ["Printf"]
git-tree-sha1 = "8339d61043228fdd3eb658d86c926cb282ae72a8"
uuid = "59287772-0a20-5a39-b81b-1366585eb4c0"
version = "0.4.2"

[[FreeType2_jll]]
deps = ["Artifacts", "Bzip2_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "87eb71354d8ec1a96d4a7636bd57a7347dde3ef9"
uuid = "d7e528f0-a631-5988-bf34-fe36492bcfd7"
version = "2.10.4+0"

[[FriBidi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "aa31987c2ba8704e23c6c8ba8a4f769d5d7e4f91"
uuid = "559328eb-81f9-559d-9380-de523a88c83c"
version = "1.0.10+0"

[[GLFW_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libglvnd_jll", "Pkg", "Xorg_libXcursor_jll", "Xorg_libXi_jll", "Xorg_libXinerama_jll", "Xorg_libXrandr_jll"]
git-tree-sha1 = "0c603255764a1fa0b61752d2bec14cfbd18f7fe8"
uuid = "0656b61e-2033-5cc2-a64a-77c0f6c09b89"
version = "3.3.5+1"

[[GR]]
deps = ["Base64", "DelimitedFiles", "GR_jll", "HTTP", "JSON", "Libdl", "LinearAlgebra", "Pkg", "Printf", "Random", "Serialization", "Sockets", "Test", "UUIDs"]
git-tree-sha1 = "30f2b340c2fff8410d89bfcdc9c0a6dd661ac5f7"
uuid = "28b8d3ca-fb5f-59d9-8090-bfdbd6d07a71"
version = "0.62.1"

[[GR_jll]]
deps = ["Artifacts", "Bzip2_jll", "Cairo_jll", "FFMPEG_jll", "Fontconfig_jll", "GLFW_jll", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Libtiff_jll", "Pixman_jll", "Pkg", "Qt5Base_jll", "Zlib_jll", "libpng_jll"]
git-tree-sha1 = "fd75fa3a2080109a2c0ec9864a6e14c60cca3866"
uuid = "d2c73de3-f751-5644-a686-071e5b155ba9"
version = "0.62.0+0"

[[GeometryBasics]]
deps = ["EarCut_jll", "IterTools", "LinearAlgebra", "StaticArrays", "StructArrays", "Tables"]
git-tree-sha1 = "58bcdf5ebc057b085e58d95c138725628dd7453c"
uuid = "5c1252a2-5f33-56bf-86c9-59e7332b4326"
version = "0.4.1"

[[Gettext_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "9b02998aba7bf074d14de89f9d37ca24a1a0b046"
uuid = "78b55507-aeef-58d4-861c-77aaff3498b1"
version = "0.21.0+0"

[[Glib_jll]]
deps = ["Artifacts", "Gettext_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Libiconv_jll", "Libmount_jll", "PCRE_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "74ef6288d071f58033d54fd6708d4bc23a8b8972"
uuid = "7746bdde-850d-59dc-9ae8-88ece973131d"
version = "2.68.3+1"

[[Graphite2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "344bf40dcab1073aca04aa0df4fb092f920e4011"
uuid = "3b182d85-2403-5c21-9c21-1e1f0cc25472"
version = "1.3.14+0"

[[Grisu]]
git-tree-sha1 = "53bb909d1151e57e2484c3d1b53e19552b887fb2"
uuid = "42e2da0e-8278-4e71-bc24-59509adca0fe"
version = "1.0.2"

[[HTTP]]
deps = ["Base64", "Dates", "IniFile", "Logging", "MbedTLS", "NetworkOptions", "Sockets", "URIs"]
git-tree-sha1 = "0fa77022fe4b511826b39c894c90daf5fce3334a"
uuid = "cd3eb016-35fb-5094-929b-558a96fad6f3"
version = "0.9.17"

[[HarfBuzz_jll]]
deps = ["Artifacts", "Cairo_jll", "Fontconfig_jll", "FreeType2_jll", "Glib_jll", "Graphite2_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg"]
git-tree-sha1 = "129acf094d168394e80ee1dc4bc06ec835e510a3"
uuid = "2e76f6c2-a576-52d4-95c1-20adfe4de566"
version = "2.8.1+1"

[[Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "8d511d5b81240fc8e6802386302675bdf47737b9"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.4"

[[HypertextLiteral]]
git-tree-sha1 = "2b078b5a615c6c0396c77810d92ee8c6f470d238"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "0.9.3"

[[IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "f7be53659ab06ddc986428d3a9dcc95f6fa6705a"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "0.2.2"

[[IniFile]]
deps = ["Test"]
git-tree-sha1 = "098e4d2c533924c921f9f9847274f2ad89e018b8"
uuid = "83e8ac13-25f8-5344-8a64-a9f2b223428f"
version = "0.5.0"

[[InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"

[[InverseFunctions]]
deps = ["Test"]
git-tree-sha1 = "a7254c0acd8e62f1ac75ad24d5db43f5f19f3c65"
uuid = "3587e190-3f89-42d0-90ee-14403ec27112"
version = "0.1.2"

[[IrrationalConstants]]
git-tree-sha1 = "7fd44fd4ff43fc60815f8e764c0f352b83c49151"
uuid = "92d709cd-6900-40b7-9082-c6be49f344b6"
version = "0.1.1"

[[IterTools]]
git-tree-sha1 = "fa6287a4469f5e048d763df38279ee729fbd44e5"
uuid = "c8e1da08-722c-5040-9ed9-7db0dc04731e"
version = "1.4.0"

[[IteratorInterfaceExtensions]]
git-tree-sha1 = "a3f24677c21f5bbe9d2a714f95dcd58337fb2856"
uuid = "82899510-4779-5014-852e-03e436cf321d"
version = "1.0.0"

[[JLLWrappers]]
deps = ["Preferences"]
git-tree-sha1 = "642a199af8b68253517b80bd3bfd17eb4e84df6e"
uuid = "692b3bcd-3c85-4b1f-b108-f13ce0eb3210"
version = "1.3.0"

[[JSON]]
deps = ["Dates", "Mmap", "Parsers", "Unicode"]
git-tree-sha1 = "8076680b162ada2a031f707ac7b4953e30667a37"
uuid = "682c06a0-de6a-54ab-a142-c8b1cf79cde6"
version = "0.21.2"

[[JpegTurbo_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "d735490ac75c5cb9f1b00d8b5509c11984dc6943"
uuid = "aacddb02-875f-59d6-b918-886e6ef4fbf8"
version = "2.1.0+0"

[[LAME_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "f6250b16881adf048549549fba48b1161acdac8c"
uuid = "c1c5ebd0-6772-5130-a774-d5fcae4a789d"
version = "3.100.1+0"

[[LZO_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "e5b909bcf985c5e2605737d2ce278ed791b89be6"
uuid = "dd4b983a-f0e5-5f8d-a1b7-129d4a5fb1ac"
version = "2.10.1+0"

[[LaTeXStrings]]
git-tree-sha1 = "f2355693d6778a178ade15952b7ac47a4ff97996"
uuid = "b964fa9f-0449-5b57-a5c2-d3ea65f4040f"
version = "1.3.0"

[[Latexify]]
deps = ["Formatting", "InteractiveUtils", "LaTeXStrings", "MacroTools", "Markdown", "Printf", "Requires"]
git-tree-sha1 = "a8f4f279b6fa3c3c4f1adadd78a621b13a506bce"
uuid = "23fbe1c1-3f47-55db-b15f-69d7ec21a316"
version = "0.15.9"

[[LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"

[[LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "MbedTLS_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"

[[LibGit2]]
deps = ["Base64", "NetworkOptions", "Printf", "SHA"]
uuid = "76f85450-5226-5b5a-8eaa-529ad045b433"

[[LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "MbedTLS_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"

[[Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"

[[Libffi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "0b4a5d71f3e5200a7dff793393e09dfc2d874290"
uuid = "e9f186c6-92d2-5b65-8a66-fee21dc1b490"
version = "3.2.2+1"

[[Libgcrypt_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgpg_error_jll", "Pkg"]
git-tree-sha1 = "64613c82a59c120435c067c2b809fc61cf5166ae"
uuid = "d4300ac3-e22c-5743-9152-c294e39db1e4"
version = "1.8.7+0"

[[Libglvnd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll", "Xorg_libXext_jll"]
git-tree-sha1 = "7739f837d6447403596a75d19ed01fd08d6f56bf"
uuid = "7e76a0d4-f3c7-5321-8279-8d96eeed0f29"
version = "1.3.0+3"

[[Libgpg_error_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "c333716e46366857753e273ce6a69ee0945a6db9"
uuid = "7add5ba3-2f88-524e-9cd5-f83b8a55f7b8"
version = "1.42.0+0"

[[Libiconv_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "42b62845d70a619f063a7da093d995ec8e15e778"
uuid = "94ce4f54-9a6c-5748-9c1c-f9c7231a4531"
version = "1.16.1+1"

[[Libmount_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "9c30530bf0effd46e15e0fdcf2b8636e78cbbd73"
uuid = "4b2f31a3-9ecc-558c-b454-b3730dcb73e9"
version = "2.35.0+0"

[[Libtiff_jll]]
deps = ["Artifacts", "JLLWrappers", "JpegTurbo_jll", "Libdl", "Pkg", "Zlib_jll", "Zstd_jll"]
git-tree-sha1 = "340e257aada13f95f98ee352d316c3bed37c8ab9"
uuid = "89763e89-9b03-5906-acba-b20f662cd828"
version = "4.3.0+0"

[[Libuuid_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7f3efec06033682db852f8b3bc3c1d2b0a0ab066"
uuid = "38a345b3-de98-5d2b-a5d3-14cd9215e700"
version = "2.36.0+0"

[[LinearAlgebra]]
deps = ["Libdl"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"

[[LogExpFunctions]]
deps = ["ChainRulesCore", "ChangesOfVariables", "DocStringExtensions", "InverseFunctions", "IrrationalConstants", "LinearAlgebra"]
git-tree-sha1 = "be9eef9f9d78cecb6f262f3c10da151a6c5ab827"
uuid = "2ab3a3ac-af41-5b50-aa03-7779005ae688"
version = "0.3.5"

[[Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"

[[MacroTools]]
deps = ["Markdown", "Random"]
git-tree-sha1 = "3d3e902b31198a27340d0bf00d6ac452866021cf"
uuid = "1914dd2f-81c6-5fcd-8719-6d5c9610ff09"
version = "0.5.9"

[[Markdown]]
deps = ["Base64"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"

[[MbedTLS]]
deps = ["Dates", "MbedTLS_jll", "Random", "Sockets"]
git-tree-sha1 = "1c38e51c3d08ef2278062ebceade0e46cefc96fe"
uuid = "739be429-bea8-5141-9913-cc70e7f3736d"
version = "1.0.3"

[[MbedTLS_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "c8ffd9c3-330d-5841-b78e-0817d7145fa1"

[[Measures]]
git-tree-sha1 = "e498ddeee6f9fdb4551ce855a46f54dbd900245f"
uuid = "442fdcdd-2543-5da2-b0f3-8c86c306513e"
version = "0.3.1"

[[Missings]]
deps = ["DataAPI"]
git-tree-sha1 = "bf210ce90b6c9eed32d25dbcae1ebc565df2687f"
uuid = "e1d29d7a-bbdc-5cf2-9ac0-f12de2c33e28"
version = "1.0.2"

[[Mmap]]
uuid = "a63ad114-7e13-5084-954f-fe012c677804"

[[MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"

[[NaNMath]]
git-tree-sha1 = "bfe47e760d60b82b66b61d2d44128b62e3a369fb"
uuid = "77ba4419-2d1f-58cd-9bb1-8ffee604a2e3"
version = "0.3.5"

[[NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"

[[Ogg_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "7937eda4681660b4d6aeeecc2f7e1c81c8ee4e2f"
uuid = "e7412a2a-1a6e-54c0-be00-318e2571c051"
version = "1.3.5+0"

[[OpenSSL_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "15003dcb7d8db3c6c857fda14891a539a8f2705a"
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "1.1.10+0"

[[Opus_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "51a08fb14ec28da2ec7a927c4337e4332c2a4720"
uuid = "91d4177d-7536-5919-b921-800302f37372"
version = "1.3.2+0"

[[OrderedCollections]]
git-tree-sha1 = "85f8e6578bf1f9ee0d11e7bb1b1456435479d47c"
uuid = "bac558e1-5e72-5ebc-8fee-abe8a469f55d"
version = "1.4.1"

[[PCRE_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b2a7af664e098055a7529ad1a900ded962bca488"
uuid = "2f80f16e-611a-54ab-bc61-aa92de5b98fc"
version = "8.44.0+0"

[[Parsers]]
deps = ["Dates"]
git-tree-sha1 = "ae4bbcadb2906ccc085cf52ac286dc1377dceccc"
uuid = "69de0a69-1ddd-5017-9359-2bf0b02dc9f0"
version = "2.1.2"

[[Pixman_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "b4f5d02549a10e20780a24fce72bea96b6329e29"
uuid = "30392449-352a-5448-841d-b1acce4e97dc"
version = "0.40.1+0"

[[Pkg]]
deps = ["Artifacts", "Dates", "Downloads", "LibGit2", "Libdl", "Logging", "Markdown", "Printf", "REPL", "Random", "SHA", "Serialization", "TOML", "Tar", "UUIDs", "p7zip_jll"]
uuid = "44cfe95a-1eb2-52ea-b672-e2afdf69b78f"

[[PlotThemes]]
deps = ["PlotUtils", "Requires", "Statistics"]
git-tree-sha1 = "a3a964ce9dc7898193536002a6dd892b1b5a6f1d"
uuid = "ccf2f8ad-2431-5c83-bf29-c5338b663b6a"
version = "2.0.1"

[[PlotUtils]]
deps = ["ColorSchemes", "Colors", "Dates", "Printf", "Random", "Reexport", "Statistics"]
git-tree-sha1 = "b084324b4af5a438cd63619fd006614b3b20b87b"
uuid = "995b91a9-d308-5afd-9ec6-746e21dbc043"
version = "1.0.15"

[[Plots]]
deps = ["Base64", "Contour", "Dates", "Downloads", "FFMPEG", "FixedPointNumbers", "GR", "GeometryBasics", "JSON", "Latexify", "LinearAlgebra", "Measures", "NaNMath", "PlotThemes", "PlotUtils", "Printf", "REPL", "Random", "RecipesBase", "RecipesPipeline", "Reexport", "Requires", "Scratch", "Showoff", "SparseArrays", "Statistics", "StatsBase", "UUIDs", "UnicodeFun"]
git-tree-sha1 = "3e7e9415f917db410dcc0a6b2b55711df434522c"
uuid = "91a5bcdd-55d7-5caf-9e0b-520d859cae80"
version = "1.25.1"

[[PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "Dates", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "JSON", "Logging", "Markdown", "Random", "Reexport", "UUIDs"]
git-tree-sha1 = "b68904528fd538f1cb6a3fbc44d2abdc498f9e8e"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.21"

[[Preferences]]
deps = ["TOML"]
git-tree-sha1 = "00cfd92944ca9c760982747e9a1d0d5d86ab1e5a"
uuid = "21216c6a-2e73-6563-6e65-726566657250"
version = "1.2.2"

[[Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"

[[Qt5Base_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Fontconfig_jll", "Glib_jll", "JLLWrappers", "Libdl", "Libglvnd_jll", "OpenSSL_jll", "Pkg", "Xorg_libXext_jll", "Xorg_libxcb_jll", "Xorg_xcb_util_image_jll", "Xorg_xcb_util_keysyms_jll", "Xorg_xcb_util_renderutil_jll", "Xorg_xcb_util_wm_jll", "Zlib_jll", "xkbcommon_jll"]
git-tree-sha1 = "ad368663a5e20dbb8d6dc2fddeefe4dae0781ae8"
uuid = "ea2cea3b-5b76-57ae-a6ef-0a8af62496e1"
version = "5.15.3+0"

[[REPL]]
deps = ["InteractiveUtils", "Markdown", "Sockets", "Unicode"]
uuid = "3fa0cd96-eef1-5676-8a61-b3b8758bbffb"

[[Random]]
deps = ["Serialization"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[[RecipesBase]]
git-tree-sha1 = "6bf3f380ff52ce0832ddd3a2a7b9538ed1bcca7d"
uuid = "3cdcf5f2-1ef4-517c-9805-6587b60abb01"
version = "1.2.1"

[[RecipesPipeline]]
deps = ["Dates", "NaNMath", "PlotUtils", "RecipesBase"]
git-tree-sha1 = "7ad0dfa8d03b7bcf8c597f59f5292801730c55b8"
uuid = "01d81517-befc-4cb6-b9ec-a95719d0359c"
version = "0.4.1"

[[Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[Requires]]
deps = ["UUIDs"]
git-tree-sha1 = "4036a3bd08ac7e968e27c203d45f5fff15020621"
uuid = "ae029012-a4dd-5104-9daa-d747884805df"
version = "1.1.3"

[[SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"

[[Scratch]]
deps = ["Dates"]
git-tree-sha1 = "0b4b7f1393cff97c33891da2a0bf69c6ed241fda"
uuid = "6c6a2e73-6563-6170-7368-637461726353"
version = "1.1.0"

[[Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"

[[SharedArrays]]
deps = ["Distributed", "Mmap", "Random", "Serialization"]
uuid = "1a1011a3-84de-559e-8e89-a11a2f7dc383"

[[Showoff]]
deps = ["Dates", "Grisu"]
git-tree-sha1 = "91eddf657aca81df9ae6ceb20b959ae5653ad1de"
uuid = "992d4aef-0814-514b-bc4d-f2e9a6c4116f"
version = "1.0.3"

[[Sockets]]
uuid = "6462fe0b-24de-5631-8697-dd941f90decc"

[[SortingAlgorithms]]
deps = ["DataStructures"]
git-tree-sha1 = "b3363d7460f7d098ca0912c69b082f75625d7508"
uuid = "a2af1166-a08f-5f64-846c-94a0d3cef48c"
version = "1.0.1"

[[SparseArrays]]
deps = ["LinearAlgebra", "Random"]
uuid = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[StaticArrays]]
deps = ["LinearAlgebra", "Random", "Statistics"]
git-tree-sha1 = "3c76dde64d03699e074ac02eb2e8ba8254d428da"
uuid = "90137ffa-7385-5640-81b9-e52037218182"
version = "1.2.13"

[[Statistics]]
deps = ["LinearAlgebra", "SparseArrays"]
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"

[[StatsAPI]]
git-tree-sha1 = "0f2aa8e32d511f758a2ce49208181f7733a0936a"
uuid = "82ae8749-77ed-4fe6-ae5f-f523153014b0"
version = "1.1.0"

[[StatsBase]]
deps = ["DataAPI", "DataStructures", "LinearAlgebra", "LogExpFunctions", "Missings", "Printf", "Random", "SortingAlgorithms", "SparseArrays", "Statistics", "StatsAPI"]
git-tree-sha1 = "2bb0cb32026a66037360606510fca5984ccc6b75"
uuid = "2913bbd2-ae8a-5f71-8c99-4fb6c76f3a91"
version = "0.33.13"

[[StructArrays]]
deps = ["Adapt", "DataAPI", "StaticArrays", "Tables"]
git-tree-sha1 = "2ce41e0d042c60ecd131e9fb7154a3bfadbf50d3"
uuid = "09ab397b-f2b6-538f-b94a-2f83cf4a842a"
version = "0.6.3"

[[TOML]]
deps = ["Dates"]
uuid = "fa267f1f-6049-4f14-aa54-33bafae1ed76"

[[TableTraits]]
deps = ["IteratorInterfaceExtensions"]
git-tree-sha1 = "c06b2f539df1c6efa794486abfb6ed2022561a39"
uuid = "3783bdb8-4a98-5b6b-af9a-565f29a5fe9c"
version = "1.0.1"

[[Tables]]
deps = ["DataAPI", "DataValueInterfaces", "IteratorInterfaceExtensions", "LinearAlgebra", "TableTraits", "Test"]
git-tree-sha1 = "fed34d0e71b91734bf0a7e10eb1bb05296ddbcd0"
uuid = "bd369af6-aec1-5ad0-b16a-f7cc5008161c"
version = "1.6.0"

[[Tar]]
deps = ["ArgTools", "SHA"]
uuid = "a4e569a6-e804-4fa4-b0f3-eef7a1d5b13e"

[[Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"

[[URIs]]
git-tree-sha1 = "97bbe755a53fe859669cd907f2d96aee8d2c1355"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.3.0"

[[UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"

[[Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"

[[UnicodeFun]]
deps = ["REPL"]
git-tree-sha1 = "53915e50200959667e78a92a418594b428dffddf"
uuid = "1cfade01-22cf-5700-b092-accc4b62d6e1"
version = "0.4.1"

[[Wayland_jll]]
deps = ["Artifacts", "Expat_jll", "JLLWrappers", "Libdl", "Libffi_jll", "Pkg", "XML2_jll"]
git-tree-sha1 = "3e61f0b86f90dacb0bc0e73a0c5a83f6a8636e23"
uuid = "a2964d1f-97da-50d4-b82a-358c7fce9d89"
version = "1.19.0+0"

[[Wayland_protocols_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "66d72dc6fcc86352f01676e8f0f698562e60510f"
uuid = "2381bf8a-dfd0-557d-9999-79630e7b1b91"
version = "1.23.0+0"

[[XML2_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libiconv_jll", "Pkg", "Zlib_jll"]
git-tree-sha1 = "1acf5bdf07aa0907e0a37d3718bb88d4b687b74a"
uuid = "02c8fc9c-b97f-50b9-bbe4-9be30ff0a78a"
version = "2.9.12+0"

[[XSLT_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Libgcrypt_jll", "Libgpg_error_jll", "Libiconv_jll", "Pkg", "XML2_jll", "Zlib_jll"]
git-tree-sha1 = "91844873c4085240b95e795f692c4cec4d805f8a"
uuid = "aed1982a-8fda-507f-9586-7b0439959a61"
version = "1.1.34+0"

[[Xorg_libX11_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll", "Xorg_xtrans_jll"]
git-tree-sha1 = "5be649d550f3f4b95308bf0183b82e2582876527"
uuid = "4f6342f7-b3d2-589e-9d20-edeb45f2b2bc"
version = "1.6.9+4"

[[Xorg_libXau_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4e490d5c960c314f33885790ed410ff3a94ce67e"
uuid = "0c0b7dd1-d40b-584c-a123-a41640f87eec"
version = "1.0.9+4"

[[Xorg_libXcursor_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXfixes_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "12e0eb3bc634fa2080c1c37fccf56f7c22989afd"
uuid = "935fb764-8cf2-53bf-bb30-45bb1f8bf724"
version = "1.2.0+4"

[[Xorg_libXdmcp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fe47bd2247248125c428978740e18a681372dd4"
uuid = "a3789734-cfe1-5b06-b2d0-1dd0d9d62d05"
version = "1.1.3+4"

[[Xorg_libXext_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "b7c0aa8c376b31e4852b360222848637f481f8c3"
uuid = "1082639a-0dae-5f34-9b06-72781eeb8cb3"
version = "1.3.4+4"

[[Xorg_libXfixes_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "0e0dc7431e7a0587559f9294aeec269471c991a4"
uuid = "d091e8ba-531a-589c-9de9-94069b037ed8"
version = "5.0.3+4"

[[Xorg_libXi_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXfixes_jll"]
git-tree-sha1 = "89b52bc2160aadc84d707093930ef0bffa641246"
uuid = "a51aa0fd-4e3c-5386-b890-e753decda492"
version = "1.7.10+4"

[[Xorg_libXinerama_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll"]
git-tree-sha1 = "26be8b1c342929259317d8b9f7b53bf2bb73b123"
uuid = "d1454406-59df-5ea1-beac-c340f2130bc3"
version = "1.1.4+4"

[[Xorg_libXrandr_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libXext_jll", "Xorg_libXrender_jll"]
git-tree-sha1 = "34cea83cb726fb58f325887bf0612c6b3fb17631"
uuid = "ec84b674-ba8e-5d96-8ba1-2a689ba10484"
version = "1.5.2+4"

[[Xorg_libXrender_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "19560f30fd49f4d4efbe7002a1037f8c43d43b96"
uuid = "ea2f1a96-1ddc-540d-b46f-429655e07cfa"
version = "0.9.10+4"

[[Xorg_libpthread_stubs_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "6783737e45d3c59a4a4c4091f5f88cdcf0908cbb"
uuid = "14d82f49-176c-5ed1-bb49-ad3f5cbd8c74"
version = "0.1.0+3"

[[Xorg_libxcb_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "XSLT_jll", "Xorg_libXau_jll", "Xorg_libXdmcp_jll", "Xorg_libpthread_stubs_jll"]
git-tree-sha1 = "daf17f441228e7a3833846cd048892861cff16d6"
uuid = "c7cfdc94-dc32-55de-ac96-5a1b8d977c5b"
version = "1.13.0+3"

[[Xorg_libxkbfile_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libX11_jll"]
git-tree-sha1 = "926af861744212db0eb001d9e40b5d16292080b2"
uuid = "cc61e674-0454-545c-8b26-ed2c68acab7a"
version = "1.1.0+4"

[[Xorg_xcb_util_image_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "0fab0a40349ba1cba2c1da699243396ff8e94b97"
uuid = "12413925-8142-5f55-bb0e-6d7ca50bb09b"
version = "0.4.0+1"

[[Xorg_xcb_util_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxcb_jll"]
git-tree-sha1 = "e7fd7b2881fa2eaa72717420894d3938177862d1"
uuid = "2def613f-5ad1-5310-b15b-b15d46f528f5"
version = "0.4.0+1"

[[Xorg_xcb_util_keysyms_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "d1151e2c45a544f32441a567d1690e701ec89b00"
uuid = "975044d2-76e6-5fbe-bf08-97ce7c6574c7"
version = "0.4.0+1"

[[Xorg_xcb_util_renderutil_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "dfd7a8f38d4613b6a575253b3174dd991ca6183e"
uuid = "0d47668e-0667-5a69-a72c-f761630bfb7e"
version = "0.3.9+1"

[[Xorg_xcb_util_wm_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xcb_util_jll"]
git-tree-sha1 = "e78d10aab01a4a154142c5006ed44fd9e8e31b67"
uuid = "c22f9ab0-d5fe-5066-847c-f4bb1cd4e361"
version = "0.4.1+1"

[[Xorg_xkbcomp_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_libxkbfile_jll"]
git-tree-sha1 = "4bcbf660f6c2e714f87e960a171b119d06ee163b"
uuid = "35661453-b289-5fab-8a00-3d9160c6a3a4"
version = "1.4.2+4"

[[Xorg_xkeyboard_config_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Xorg_xkbcomp_jll"]
git-tree-sha1 = "5c8424f8a67c3f2209646d4425f3d415fee5931d"
uuid = "33bec58e-1273-512f-9401-5d533626f822"
version = "2.27.0+4"

[[Xorg_xtrans_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "79c31e7844f6ecf779705fbc12146eb190b7d845"
uuid = "c5fb5394-a638-5e4d-96e5-b29de1b5cf10"
version = "1.4.0+3"

[[Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"

[[Zstd_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "cc4bf3fdde8b7e3e9fa0351bdeedba1cf3b7f6e6"
uuid = "3161d3a3-bdf6-5164-811a-617609db77b4"
version = "1.5.0+0"

[[libass_jll]]
deps = ["Artifacts", "Bzip2_jll", "FreeType2_jll", "FriBidi_jll", "HarfBuzz_jll", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "5982a94fcba20f02f42ace44b9894ee2b140fe47"
uuid = "0ac62f75-1d6f-5e53-bd7c-93b484bb37c0"
version = "0.15.1+0"

[[libfdk_aac_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "daacc84a041563f965be61859a36e17c4e4fcd55"
uuid = "f638f0a6-7fb0-5443-88ba-1cc74229b280"
version = "2.0.2+0"

[[libpng_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Zlib_jll"]
git-tree-sha1 = "94d180a6d2b5e55e447e2d27a29ed04fe79eb30c"
uuid = "b53b4c65-9356-5827-b1ea-8c7a1a84506f"
version = "1.6.38+0"

[[libvorbis_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Ogg_jll", "Pkg"]
git-tree-sha1 = "c45f4e40e7aafe9d086379e5578947ec8b95a8fb"
uuid = "f27f6e37-5d2b-51aa-960f-b287f2bc3b7a"
version = "1.3.7+0"

[[nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"

[[p7zip_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "3f19e933-33d8-53b3-aaab-bd5110c3b7a0"

[[x264_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "4fea590b89e6ec504593146bf8b988b2c00922b2"
uuid = "1270edf5-f2f9-52d2-97e9-ab00b5d0237a"
version = "2021.5.5+0"

[[x265_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg"]
git-tree-sha1 = "ee567a171cce03570d77ad3a43e90218e38937a9"
uuid = "dfaa095f-4041-5dcd-9319-2fabd8486b76"
version = "3.5.0+0"

[[xkbcommon_jll]]
deps = ["Artifacts", "JLLWrappers", "Libdl", "Pkg", "Wayland_jll", "Wayland_protocols_jll", "Xorg_libxcb_jll", "Xorg_xkeyboard_config_jll"]
git-tree-sha1 = "ece2350174195bb31de1a63bea3a41ae1aa593b6"
uuid = "d8fb68d0-12a3-5cfd-a85a-d49703b185fd"
version = "0.9.1+5"
"""

# ╔═╡ Cell order:
# ╟─91de6368-6e15-42d9-8fff-e0b3a4a162f2
# ╟─26440e94-9ae4-4845-a733-b752233a5a34
# ╟─2ec90f9f-d92d-45c6-8d15-e0153259c7c5
# ╟─ed957203-dd59-464c-937e-0b4f135216bf
# ╟─d3ab82e2-525d-11ec-2828-4da3904be0ee
# ╟─8114c5a1-958c-4343-8375-e069563ca2be
# ╟─f9952443-595c-4af8-afcb-7ca7e7ce0aa7
# ╟─6bba50da-156f-4548-951e-f4efe989063d
# ╟─e8c1daaf-73f8-4f3e-bf39-70315098d661
# ╟─947bcedd-8064-4cdf-a252-591580a0e57e
# ╟─c7ce6d21-a013-4a24-a4d3-548ea9b8277c
# ╟─849bad17-9f2c-416e-ad05-c59901865080
# ╟─8bba398a-03de-4312-9f9f-00b49ee70d65
# ╟─cd782adf-44a5-4c76-b5ba-8baaac598c21
# ╟─8688a097-8583-4c53-8b8d-8d77df23dd82
# ╟─8c0c1f32-e051-43a0-b3e0-cab4a44b4f3b
# ╟─b4136155-3afe-4a98-bbc2-ab6ac7c88a8c
# ╟─ba5b6b87-9d60-40db-afcd-0e2398a70667
# ╟─858f96ef-f482-45d5-a5c6-bc1e8944d894
# ╟─b6c0532f-b9ae-4d8a-8a8e-0116c598ce9a
# ╟─50feddb8-86dd-40a7-b576-aa381b75d29a
# ╟─38cd6518-7966-424e-98ed-9d0facf86a76
# ╟─f409b036-2c71-4b25-9fa1-4054b82037df
# ╟─288f9a63-9397-4443-b0d6-3b7684da4946
# ╟─560ed0fd-734f-4344-8cca-8c9b2cf1b919
# ╟─b6ce4b17-d46c-48bf-8137-3b869774eed8
# ╟─e0e24b9a-088e-46c3-b15e-0ea07b3c09b4
# ╠═bc05f3b0-e828-44a6-8f62-c4c7aba5377a
# ╠═8f969c1b-1c72-45f2-a0fd-6615507bd1fa
# ╠═04332b21-2f2b-424c-8c3a-4b7dc7157ecd
# ╟─5f29f0dd-8b3a-4fd8-95f3-ad4e01de2afd
# ╠═846de6c4-bfc5-4613-9b29-2f459838b5ae
# ╟─3ed04359-e6d0-446d-a894-d59c5eaa2181
# ╟─8e113861-2578-4c65-b03b-f51f947cdfd1
# ╟─3b150a37-e32c-420a-aa80-509402b8cb3e
# ╟─8ecd9a0b-16d4-4c45-949a-1d077ba1f12e
# ╟─336f28e5-4664-48ec-93b4-975ef05d6f26
# ╠═8f75bd2c-2dd2-4c52-b4f9-248a1eed5262
# ╟─e9bf6cc4-809f-4d94-8e41-35a385df6b5b
# ╟─3fef783d-b2d6-4713-bf14-4a130368ce21
# ╟─043df08b-d08e-4d52-bcf9-863b97985c04
# ╟─2136c3c5-5e5d-4844-9dd7-3a920b86935a
# ╟─d87dd601-5779-4255-97c3-7caf7e636437
# ╟─24e33672-4d56-4c54-8cad-53623476d507
# ╟─6a9ede18-486c-4e20-9b86-cd8d1d938ca5
# ╟─56314477-9691-4628-befb-50581877e166
# ╟─87769b77-5a94-472a-8145-2add1b935ec0
# ╟─12c95972-9a31-4cf7-882d-47e59e28569d
# ╟─c1a897f7-acc4-4d35-b58c-4ecf19cb9e9a
# ╠═99524729-bab2-48d9-9b0f-e7d1453d229b
# ╟─8f3f2c72-3103-49ca-a0fe-c7698ad5a126
# ╟─4d5577c6-a50e-4e40-b50f-86975a0a7824
# ╟─5f6d8439-f6c7-4c89-96de-58ba956a63bf
# ╟─477354cf-34dc-4ebb-907f-3563fb455023
# ╟─cf3ad448-27b7-4093-b920-147aec20db08
# ╟─1edf7e9e-2bc6-4e30-ba56-3f89c9b64ef1
# ╟─21a65132-756c-4754-b939-3c5ee4e45a7f
# ╟─bfc6a235-2e09-4b5c-870d-948da20ef0bb
# ╟─f5a6edb2-dc2d-4bc2-915c-bdbb9338e3ae
# ╟─62fe15fc-652c-4df1-9c25-756c27b4043e
# ╟─7e59354b-f77a-46e6-b414-eaa74ef633b7
# ╟─1c3aabbf-15e7-4074-ac8f-14da8970b73d
# ╟─9a657c77-ae73-4b7f-98dd-29dd658bdb3e
# ╟─ab48307d-f7d6-447f-a792-cddc2f520d38
# ╟─7aaa144f-2091-4c56-901e-2819778318d8
# ╟─86731b90-b54d-4329-8d5f-f5aedb959607
# ╟─9d499ead-2706-4c56-a532-61430a149abb
# ╟─0c5e1f17-222a-4280-b9f3-7c07ca80ae2a
# ╟─52d753cd-5fa9-4067-875a-48c1ad09b048
# ╟─62b20983-592e-412e-8e4f-d90b7f7a6175
# ╟─9845cc46-f565-4fef-8781-ed02c646d15c
# ╟─71664389-7bee-400d-9554-7c56988bb566
# ╟─935e6d2e-f1d0-4ea4-afa0-25168031cd93
# ╟─feabf101-5e5d-4b7b-945e-74c4666d3811
# ╟─e3f47f60-4ff9-4a78-af19-a3f33b956965
# ╟─d9a282b7-d11b-4d5b-8724-37b541e643d9
# ╟─b9dd27ef-01c0-4e87-a7a4-af230846922a
# ╟─8a1cd3b2-a68d-4e8b-9603-5e752ac9111c
# ╟─529c90bf-d1e7-4cbd-a1ee-1f8d7146220f
# ╟─c6edb03f-8bee-42e7-9f72-8931f3161d0e
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
