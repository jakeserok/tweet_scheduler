class TwitterAccount < ApplicationRecord
  belongs_to :user
  has_many :tweets

  validates :username, uniqueness: true

  def client
    Twitter::REST::Client.new do |config|
      config.consumer_key        = Rails.application.credentials.dig(:twitter, :api_key)
      config.consumer_secret     = Rails.application.credentials.dig(:twitter, :api_secret)
      config.access_token        = token
      config.access_token_secret = secret
    end
  end

  def self.to_csv
    attributes = %w{ twitter_account_id twitter_handle user tweets }

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |account|
        tweets = []
        account.tweets.map{ |t| tweets << t.body if t.tweet_id?  }
        
        csv << [ # attributes.map{ |attr| account.send(attr) }
          account.id,
          account.username,
          account.user.email,
          tweets
        ]
      end
    end
  end
end
