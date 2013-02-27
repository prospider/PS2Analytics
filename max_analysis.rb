require_relative 'PS2Analytics'

SetServiceTag("s:your tag here")

# Grab top players
top_players = TopPlayersByKills(ARGV[0])
max_players = Array.new
counter = 0

top_players.each { |player|
	faction = FactionFromId(player)
	max_deaths = DeathsByClassFromId(player, 'MAX')
	max_score = ScoreByClassFromId(player, 'MAX')
	
	Thread.new { print "Rank ##{counter += 1} fetched.\n" }
	
	max_players << {"id" => player, "faction" => faction, "max_deaths" => Integer(max_deaths), "max_score" => Integer(max_score) }
}

# Print ID, Faction, Score, Deaths and Score per Death ratio
print "TOP #{ARGV[0]} PLAYERS' SCORES AND DEATHS IN MAX UNITS\n"
print "Character ID\t\tFaction\tMAX Score\tMAX Deaths\tScore per death\n\n"

max_players.each { |player|
	print "#{player['id']}\t#{player['faction']}\t#{player['max_score']}\t\t#{player['max_deaths']}\t\t#{Float(player['max_score']) / Float(player['max_deaths'])}\n"
}

# Display sorted scores
sorted_scores = max_players.sort_by { |player| player['max_score'] }
sorted_scores.reverse!

print "\n\n"
print "SCORES SORTED FROM HIGHEST TO LOWEST WITH FACTION\n"
print "Faction\tScore"
print "\n\n"

sorted_scores.each do |player|
	print "#{player['faction']}\t#{player['max_score']}\n"
end

# Generate list of scores by faction
score_hash = {"tr" => Array.new, "nc" => Array.new, "vs" => Array.new}

max_players.each do |player|
	score_hash[player['faction']] = score_hash[player['faction']] << Float(player['max_score'])
end

score_hash.each_key do |key|
	score_hash[key] = score_hash[key].sort
end

# Find smallest amount of players per faction, and add up scores to that number
def smallest(a, b)
	a < b ? a : b
end

smallest_faction_length = smallest(smallest(score_hash['tr'].length, score_hash['nc'].length), score_hash['vs'].length)

total_score_hash = {"tr" => 0, "nc" => 0, "vs" => 0}

smallest_faction_length.times do |i|
	score_hash.each_key do |key|
		total_score_hash[key] = score_hash[key][i]
	end
end

# Generate a list of deaths by faction
death_hash = {"tr" => Array.new, "nc" => Array.new, "vs" => Array.new}

max_players.each do |player|
	death_hash[player['faction']] = death_hash[player['faction']] << Float(player['max_deaths'])
end

death_hash.each_key do |key|
	death_hash[key] = death_hash[key].sort
end

total_deaths_hash = {"tr" => 0, "nc" => 0, "vs" => 0}

smallest_faction_length.times do |i|
	death_hash.each_key do |key|
		total_deaths_hash[key] += death_hash[key][i]
	end
end

print "\n\n"
print "AVERAGE SCORE TO DEATH BY FACTION\n"
print "tr\t\tnc\t\tvs"

print "\n\n"
print "#{"%0.2f" % (total_score_hash['tr'] / total_deaths_hash['tr'])}\t\t#{"%0.2f" % (total_score_hash['nc'] / total_deaths_hash['nc'])}\t\t#{"%0.2f" % (total_score_hash['vs'] / total_deaths_hash['vs'])}"
print "\n"