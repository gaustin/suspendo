require 'grackle'

module Suspendo
  extend self
  
  def run(options)
    #client = Twitter::Base.new(Twitter::HTTPAuth.new(options[:username], options[:password]))
    @client = Grackle::Client.new(:auth => { 
      :type =>:basic, 
      :username => options[:username], 
      :password => options[:password] 
    })
    
    source_user = options[:username]
    target_user = options[:user]
    case options[:action]
    when "suspend"
      puts "suspend"
      client.friendships.destroy! :screen_name => user if !following?(target_user)
      # add crontab entry to recreate this friendship in x days
    when "follow"
      client.friendships.create! :screen_name => user if following?(target_user)
    when "unfollow"
      client.friendships.destroy! :screen_name => user if !following?(target_user)
    end
  end
  
  def following?(user)
    response = @client.friendships.show.json?(:target_screen_name => user)
    response.relationship.source.following
  end
end