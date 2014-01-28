require_relative 'movie_data_set.rb'

class MovieTest
	attr_accessor :test_data
	def initialize
		@test_data=[]
	end
	#avg pred error
	def mean

		sum = 0.0
		@test_data.each do |rating|
			sum += rating[3]-rating[2]
			if sum.nan?
				binding.pry
			end
		end
		
		return sum/@test_data.length
	end
	#std dev of error
	def stddev
		m = mean
		sum = 0.0
		@test_data.each do |rating|
			sum += (((rating[3]-rating[2])-m).abs)**2
		end
		return (sum/(@test_data.length-1))**0.5
	end
	#root mean square error of prediction
	def rms
		sum = 0.0
		@test_data.each do |rating|
			sum += (rating[3]-rating[2])**2
		end
		return (sum/(@test_data.length))**0.5
	end
	def to_a
		return @test_data
	end
end