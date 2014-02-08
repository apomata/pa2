############# NOTE THIS IS VERY IMPORTANT ################## 
#WHEN RUNNING THIS CODE THE REQUIRE LINE MUST BE CHANGED TO THE LOCATION OF movie_data_organizer.rb
require_relative 'movie_data_set.rb'
require_relative 'movie_test.rb'
require 'pry'
class MovieData
	attr_accessor :path, :pair, :training_set, :test_set
	def initialize(path ,*args)
		@path = path
		#not sure what to do with learning set
		@pair = args[0]
		if @pair.nil?
			@training_set = set_vars(@path, "\\u.data")
		else
			@training_set = set_vars(@path, "\\"+@pair.to_s+".base")
			@test_set = set_vars(@path, "\\"+@pair.to_s+".test")
		end
		#@most_similar = {}
	end
	#set up test and training sets
	def set_vars(path, suffix)
			#binding.pry
			set = MovieDataSet.new(@path+suffix)
			set.load_data
			return set
	end
	#gives user rating
	def rating(u, m)
		#binding.pry 
		temp = @training_set.user_ratings[u][m]
		temp ||= 0
	end
	# get movies a user has seen 
	def movies(u)
		return @training_set.user_ratings[u].keys.sort
	end
	#get users who viewed a movie
	def viewers(m)
		return @training_set.movie_viewers[m].sort
	end

	def predict(u, m)
		#if using the hash to increase look up speeds(if running mulitple tests can save some time 
		# not very effective on just one test)
			#@most_similar[[u, m]] ||=((training_set.most_similar(u, viewers(m))).first(1)[0]
			#most_sim =  @most_similar[[u, m]]
			#most_sim =(training_set.most_similar(u, viewers(m))).first(1)[0]

		#get viewersof the movies similarity to user
		most_sim =(training_set.most_similar(u, viewers(m)))
		m_pop = @training_set.popularity(m)
		#make sure there are both similar users and the movie has been seen 
		#(movies in test set may have no viewers in the training set)
		if !most_sim.nil? && !viewers(m) == []
			most_sim_rate =  @training_set.user_ratings[most_sim[0]][m]
			#take waited average of the most similar user who saw the movie by their similarity
			#and themovies average rating waited by the invers similarity of the users
			return (most_sim_rate*most_sim[1])+((1-most_sim[1])*m_pop)
			#if you want to do it in one line slightly more accurate ~.001 uses weighted average of all users slightly slower
			#return most_sim.map{|ar| training_set.user_ratings[ar[0]][m]*ar[1]}.inject{|s, x| s+x}/most_sim.map{|ar| ar[1]}.inject{|s, x| s+x}
		else
			return m_pop
		end
	end

	def run_test(*args)
		mov_test = MovieTest.new
		a = Time.now
		puts a.to_s
		if !@test_set.nil?
			#run prediction on each rating in test
			temp_arr = @test_set.get_data(args[0])
			temp_arr.each do |line|
				user = line[0]
				movie = line[1]
				rate = line[2]	
				pred = predict(user, movie)
				#put info and prediction into test array
				mov_test.test_data.push [user, movie, rate, pred]
			end
			 b = Time.now
			puts Time.now
			puts (a-b).to_s
			return mov_test
		else
			puts "no test set"
			return nil
		end

	end
end