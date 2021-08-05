class Tweet < ApplicationRecord
  belongs_to :user
  belongs_to :twitter_account

  validates :body, length: { minimum: 1, maximum: 280 }
  validates :publish_at, presence: true

  after_initialize do
    self.publish_at ||= 1.hour.from_now
  end

  after_save_commit do
    TweetJob.set(wait_until: publish_at).perform_later(self) if publish_at_previously_changed?
  end

  def published?
    tweet_id?
  end

  def publish_to_twitter!
    tweet = twitter_account.client.update(body)
    update(tweet_id: tweet.id)
  end

  def self.user 
    self.user.email
  end

  def self.to_csv
    attributes = %w{ user_id twitter_account_id body publish_at tweet_id }

    CSV.generate(headers: true) do |csv|
      csv << attributes

      all.each do |tweet|
        csv << [ # attributes.map{ |attr| tweet.send(attr) }
          tweet.user.email,
          "@" + tweet.twitter_account.username,
          tweet.body,
          tweet.publish_at,
          tweet.tweet_id? ? "Published" : "Unpublished"
        ]
      end
    end
  end
end
