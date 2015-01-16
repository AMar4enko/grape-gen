module DelayedJobs
  class PongTime
    include Sidekiq::Worker

    sidekiq_options unique: true

    def perform
      FayePublisher.publish('/time',Time.now.utc.to_s)
    end
  end
end