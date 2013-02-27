require 'open-uri'
require 'json'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

@characters = Hash.new

def SetServiceTag(tag)
	@url = "http://census.soe.com/#{tag}/get/ps2-beta/"
end

def AttemptAPIPull(url)
	for i in 1..10
		content = open(url).read
		json = JSON.parse(content)
		
		return json unless json == nil
		
		sleep 10 * i
	end
	
	raise "API call was attempt 10 times and was not completed."
end

def GetStatsFromId(id)
	return @characters[id] unless @characters[id] == nil
	
	url = @url + "character/#{id}"
	
	content = AttemptAPIPull(url)
	
	@characters[id] = content['character_list'][0]
end

def TopPlayersByKills(limit)
	url = "https://census.soe.com/s:soe/get/ps2-beta/leaderboard/?name=Kills&period=Forever&c:limit=#{limit}"
	
	content = open(url).read
	json = JSON.parse(content)
	
	ids = json['leaderboard_list'].map { |chr| chr['id'] }
	
	return ids
end

def DeathsByClassFromId(id, cls)
	character = GetStatsFromId(id)
	return character['stats']['deaths']['class'][cls]
end

def ScoreByClassFromId(id, cls)
	character = GetStatsFromId(id)
	return character['stats']['score']['class'][cls]['value']
end

def FactionFromId(id)
	character = GetStatsFromId(id)
	return character['type']['faction']
end


