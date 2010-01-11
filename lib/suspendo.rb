require 'grackle'
require 'cronedit'
require 'chronic'
require 'pp'

module Suspendo
  extend self
  
  def run(options)
    #client = Twitter::Base.new(Twitter::HTTPAuth.new(options[:username], options[:password]))
    @client = Grackle::Client.new(:auth => { 
      :type =>:basic, 
      :username => options[:username], 
      :password => options[:password] 
    })
    
    duration = options[:duration]
    source_user = options[:username]
    target_user = options[:user]
    cronkey = "#{source_user}-#{target_user}"
    
    relationship = @client.friendships.show.json?(:target_screen_name => target_user).relationship
    case options[:action]
    when "suspend"
      @client.friendships.destroy! :user_id => relationship.target.id, :screen_name => target_user if relationship.source.following
      CronEdit::Crontab.Add cronkey, "0 0 * * #{day_of_week(duration)} * /Users/gaustin/Projects/suspendo/bin/supsendo --username #{options[:username]} --password #{options[:password]} #{target_user} follow"
    when "follow"
      @client.friendships.create! :user_id => relationship.target.id, :target_screen_name => target_user if !relationship.source.following
      CronEdit::Crontab.Remove cronkey if CronEdit::Crontab.List.any? { |k,| k == cronkey }
    when "unfollow"
      @client.friendships.destroy! :user_id => relationship.target.id, :screen_name => target_user if relationship.source.following
    end
  end
  
  def following?(user)
    response = 
    response.relationship.source.following
  end
  
  def day_of_week(duration)
    dt = Chronic.parse("#{duration} days from now")
    # Ruby dates start at Sunday = 0, cron dates start with Monday = 1
    if dt.wday == 0
      7
    else
      dt.wday
    end
  end
end