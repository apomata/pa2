require 'C:\Users\Pomata\Documents\cosci\cosci 236\pa2\movie_data_organizer'
class MovieTest
	attr_accessor :test_data
	initialize
		@test_data=[]
	end
end
class MovieData
	attr_accessor
	initialize(*args)

		@path = args[0]
		#not sure what to do with learning set
		@pair = [1]
		#i need to change movie data organizer in a way that it can take 2 arguments for learning data and etc
		#not sure what to use a learning set for or where to store it maybe a second organizer?
		@movie_data_organizer = MovieDataOrganizer.new()
		@movie_data_organizer.load_data

	end

	def rating(u, m) 
		temp = @movie_data_organizer.user_ratings[u][m]
		if temp.nil?
			return 0
		else
			return temp
		end
	end

	def movies(u)
		return @movie_data_organizer.user_ratings[u].keys.sort
	end

	def viewers(m)
		return @movie_data_organizer.movie_viewers[2].sort
	end

	def predict(u, m)
		# well shit
		# no clue what to do with learning set
		# no clue how to predict maybe something off of similarity list
		# do i compute similar stuff from the test then use that to predict on the data run?
	end

	def run_test(*args)
		mov_test = MovieTest.new
		temp_arr = []
		if args.nil?
			temp_arr = @movie_data_organizer.data_array
		else
			temp_arr = @movie_data_organizer.data_array.first(args[0])
		end
		temp_arr.each do |line|
			t_line = line.split("\t")
			t_line.map! { |i| i.to_i }
			pred = predict(t_line[0], t_line[1])
			# 0: user, 1: movie, 2: actual rating, 
			mov_test.test_data.push [t_line[0], t_line[1], t_line[2], pred]
		end
		return mov_test
	end
end