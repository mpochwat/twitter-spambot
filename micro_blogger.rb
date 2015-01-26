require 'jumpstart_auth'
require 'bitly'

Bitly.use_api_version_3

bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
puts bitly.shorten('http://jumpstartlab.com/courses/').short_url

class MicroBlogger
	attr_reader :client

	def initialize
		puts "Initializing..."
		@client = JumpstartAuth.twitter
	end

	def tweet(message)
		if message.length < 140
			@client.update(message)
		else
			puts "Warning, this tweet exceed 140 characters."
		end
	end

	def run
		puts "Welcome to the JSL Twitter Client!"
		command = ""
		while command != "q"
			printf "enter command: "
			input = gets.chomp
			parts = input.split(" ")
			command = parts[0]
			case command
			when 't' then tweet(parts[1..-1].join(" "))
			when 'dm' then dm(parts[1], parts[2..-1].join(" "))
			when 'spam' then span_my_followers(parts[1..-1].join(" "))
			when 'elt' then everyones_last_tweet
			when 's' then shorten(parts[1])
			when 'turl' then tweet(parts[1..-2].join(" ") + " " + shorten(parts[-1]))
			when 'q' then puts "Goodbye!"
			else 
				puts "Sorry, I don't know how to #{command}"
			end
		end
	end

	def dm(target, message)
		puts "Trying to send #{target} this direct message:"
		puts message
		message = "d @#{target} #{message}"
		screen_names = @client.followers.collect { |follower| @client.user(follower).screen_name}
		if screen_names.include?(target)
			tweet(message)
		else
			puts "You can only direct message people who follow you."
		end
	end

	def followers_list
		screen_names = []
		@client.followers.each do |follower|
			screen_names << @client.user(follower).screen_name
		end
		screen_names
	end

	def span_my_followers(message)
		followers_list.each { |follower| dm(follower, message) }
	end	

	def everyones_last_tweet
		friends = @client.friends
		friends.sort_by { |friend| @client.user(friend).screen_name.downcase}
		friends.each do |friend|
			timestamp = @client.user(friend).status.created_at
			message = @client.user(friend).status.text
			puts "At #{timestamp.strftime("%A, %b %d")}, #{@client.user(friend).screen_name.upcase} said..."
			puts message
			puts ""
		end
	end

	def shorten(original_url)
		Bitly.use_api_version_3
		bitly = Bitly.new('hungryacademy', 'R_430e9f62250186d2612cca76eee2dbc6')
		puts "Shortening this URL: #{original_url}"
		bitly.shorten(original_url).short_url
	end
end

blogger = MicroBlogger.new
blogger.run