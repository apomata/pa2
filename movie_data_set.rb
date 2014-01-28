#user ratings, movie viewers, most similar, movie pop, get data
require 'pry'
class MovieDataSet
	attr_accessor :movie_pop, :user_ratings, :movie_viewers, :data_array
	def initialize(path)
		#hash movie to array [ratrings count, sum] get average later
		@movie_pop = Hash.new{|h,k| h[k]={count: 0.0, sum: 0.0}}
		#u[2][3] = 4 ,user 2 movie 3 rated 4
		@user_ratings = Hash.new{|h,k| h[k]={}}
		#hash movie to array of all users who watched it
		@movie_viewers = Hash.new{|h,k| h[k]=[]}
		@data_array =[]
		@path = path
	end

	def load_data
		@data_array = IO.readlines(@path)
		@data_array.map! {|line| line.split("\t").map! { |i| i.to_i }}
		@data_array.each do |line|
			user = line[0]
			movie = line[1]
			rating = line[2]
			@movie_viewers[movie] << user
			#u[t[0]][t[1]] = t[2] : user t[0], rated movie t[1], with t[2]
			@user_ratings[user][movie]=rating
			#update num movie ratings, update sum of movie ratings
			@movie_pop[movie][:count] +=1
			@movie_pop[movie][:sum] +=rating
		end
	end
	#return all data or the first n ratings
	def get_data(n)
		if n.nil?; return @data_array; else; return @data_array.first(n); end
	end

	def popularity(movie)
		t_arr = @movie_pop[movie] 
		#if movie doeswnt exist returns 0
		if t_arr == {count: 0.0, sum: 0.0} 
			# returns 3 the middle rating
			t_arr = {count: 1.0, sum: 3.0}
		end
		return t_arr[:sum]/t_arr[:count]
	end

	# get the similarity of two users
	def similarity (u1, u2)
		# make sure users exist before calculating similarity
		if !@user_ratings[u1].nil? && !@user_ratings[u2].nil?
			u1_rate_hash = @user_ratings[u1]
			u2_rate_hash = @user_ratings[u2]
			# merge the two hashes since that produces a set 
			# then can get the length to get # of unique movies the two users have rated (in case users have not ranked all the same movies)
			num_total_movies = u1_rate_hash.merge(u2_rate_hash).keys.length
			# make combination of all movies that both users ahve seen
			both_seen = u1_rate_hash.keys & u2_rate_hash.keys
			sum = 0
			# loops throught the movies both users have seen and takes the difference between the ratings
			# this is subtracted from 4 (the max difference) to give an inverse on the difference if they have the same rating then 4 is added to the sum
			both_seen.each do |id|
				sum +=4 - (u1_rate_hash[id] - u2_rate_hash[id]).abs
			end
			n =((0.0+both_seen.length)/(num_total_movies))*(((0.0+sum)/4)/both_seen.length)
			if n.nan?
				n = 0.0
			end
			return n
		else
			return 0
		end
	end

	def most_similar(u, *args)
		sim_hash = {}
		#take array of users to sun on instead of whole list
		sim_arr = args[0]
		sim_arr ||= @user_ratings.keys
		if !sim_arr.nil?
			sim_arr.each do |u2|
				#binding.pry 
				if u != u2
					sim_hash[u2] = similarity(u, u2)
				end
			end
			# return an array of arrays sorted by largest value (similarity) first  
			return sim_hash.sort_by {|user, sim| sim}.reverse	
		else
			return sim_hash
		end
	end
end