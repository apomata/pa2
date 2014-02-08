class MovieDataOrganizer
	attr_accessor :mov_pop_ar_hs, :user_ratings, :movie_viewers, :data_array
	def initialize(*args)
		@mov_pop_ar_hs = []
		@user_ratings = []
		@movie_viewers = Hash.new{|h,k| h[k]=[]}
		@data_array =[]
		@path = args[0]
		@data_pair = args[1]
		if @path.nil?
			@path = 'C:\Users\Pomata\Documents\cosci\cosci 236\pa2\ml-100k\u.data'
		end
	end

	# file must end at last rating
	def load_data
		@data_array = IO.readlines(@path)
		ratings_array=[]
		# ya this is gonna be an array of hashes
		# with array index as movie id and hash with kew of rank and value of count 
		movie_pop_array_hash=[]
		user_ratings_arr = []
		data_array.each do |line|
			temp = line.split("\t")
			temp.map! { |i| i.to_i }
			####### THIS CREATES MOVIE POPULARITY TABLES
			movie_pop_store(movie_pop_array_hash, temp)
			####### THIS CREATES USER RATING TABLES
			user_rate(user_ratings_arr, temp)
			@movie_viewers[temp[0]] << temp[1]
		end
		@mov_pop_ar_hs = movie_pop_array_hash
		@user_ratings = user_ratings_arr	
	end
	
	# creates movie popularity tables
	# line[1] is movie id [line[2]] gets the hash value at the movies rating
	def movie_pop_store (pop_array, line)
		temp_ar= pop_array[line[1]]
		if temp_ar.nil?
			pop_array[line[1]]={}
		end
		num = pop_array[line[1]][line[2]]
		# check if the hash has a spot for the rating and update
		if num.nil?
			# set initial count to 1
			pop_array[line[1]][line[2]]=1
		else
			num = num + 1
			pop_array[line[1]][line[2]]=num
		end
	end

	def get_data(n)
		if n.nil?; return @data_array; else; return data_array.first(n); end
	end
	
	# creates user array with hashes for movie id to that users rating
	def user_rate (user_ratings_arr, line)
		if user_ratings_arr[line[0]].nil? 
			user_ratings_arr[line[0]] = {line[1] =>line[2]}
		else
			user_ratings_arr[line[0]][line[1]] = line[2]
		end
	end

	def popularity(movie_id)
		if @mov_pop_ar_hs[movie_id].nil?
			puts "#{movie_id} is an invalid movie"
			return 0.0
		else
			temp_hash = @mov_pop_ar_hs[movie_id]
			sum = 0.0
			count = 0
			# ratings are integers so I can multiply them despite being keys
			temp_hash.each do |rating, num|
				# i am using the average to give the popularity of the movie
				# preserves ratings with respect to their frequency, simple, standard number out of 5 used by many other sites
				# lacks some finesse with the proportion of times viewed compaired to other movies, but works fine
				sum += rating*num
				count += num
			end
			return sum/count
		end
	end
	# gives popularity of all movies in array
	def popularity_list
		if @mov_pop_ar_hs.nil?
			puts "data has not been loaded"
			return[]
		else
			movie_avg_pop={}
			count = 0
			while count < @mov_pop_ar_hs.length
				movie_avg_pop[count]=popularity(count)
				count = count + 1
			end
			#sort from highest to lowest

			return movie_avg_pop.sort_by {|movie, pop| pop}.reverse
		end
	end
	# get the similarity of two users
	def similarity (u1, u2)
		# make sure data is loaded first
		if @user_ratings.nil?
			puts "data has not been loaded"
			return 0
		else
			# make sure users exist before calculating similarity
			if check(u1, u2)==1
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
				# the formula for similarity
				# the # movies both have seen /the number of unique movies both have seen
				# this gives a percentage of similarity between the movies both users have rated
				# ensures similarity in preference of movies not just ratings
				# those who have more similar taste in movies ranked will have thier percentage of similarity affected less as it will be close to 1
				# where those who have disparate tastes in music will be closer to 0 reducing the total score and reflecting their difference in tastes
				# the sum is divided by 0 to normalize it(if all ranks are the same the sum comes to 4*number of movies both seen 
				# and needs to be removed to get a # below #movies both seen)
				# divide by total number of movies seen to get a percentage of similarity of ranks
				# +0.0 TO TURN INTO DECIMALS *100 TO GET THE PERCENT
				n =((0.0+both_seen.length)/(num_total_movies))*(((0.0+sum)/4)/both_seen.length)*100
				if n.nan?
					n = 0.0
				end
				return n
			else
				return 0
			end
		end
	end
	def most_similar(u)
		sim_hash = {}
		if @user_ratings.nil?
			puts "data not loaded"
			return sim_hash
		else
			if !@user_ratings[u].nil?
				@user_ratings.each do |u2|
					if u != @user_ratings.index(u2) && !u2.nil? 
						sim_hash[@user_ratings.index(u2)] = similarity(u, @user_ratings.index(u2))
					end
				end
				# return an array of arrays sorted by largest value (similarity) first  
				return sim_hash.sort_by {|user, sim| sim}.reverse	
			else
				return sim_hash
			end
		end
	end
	# make sure both users exist
	def check (u1, u2)
		if @user_ratings[u1].nil?
			puts "u1 is not registered"
			return 0
		end
		if @user_ratings[u2].nil?
			puts "u2 is not registered"
			return 0
		end
		return 1
	end


end

