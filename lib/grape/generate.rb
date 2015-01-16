require 'grape/generate/version'
require 'bundler/vendor/thor'
require 'digest'

module Grape
  module Generate
    BATTERIES = %w{sidekiq carrierwave mandrill es faye}
    class CLI < Thor
      include Thor::Actions

      source_root File.expand_path('../../template', File.dirname(__FILE__))

      desc 'app APP_NAME', 'Guides you through Grape app scaffolding process'
      option :path
      option :orm, default: 'mongoid'
      option :batteries,
             type: :array,
             default: Generate::BATTERIES,
             desc: 'Batteries to include'

      option :'use-grape-rackbuilder', type: :boolean, default: true

      attr_accessor *Generate::BATTERIES

      def app(app_name)
        Generate::BATTERIES.each do |v|
          send("#{v}=", options[:batteries].include?(v))
        end

        @app_name = app_name

        @orm = options[:orm]
        @dev_reload = options[:'use-grape-rackbuilder']

        begin
          FileUtils.rm_r(options[:path] || app_name.downcase)
        rescue
        end

        self.destination_root = options[:path] || app_name.downcase
        @redis = true
        @faye_secret = Digest::MD5.hexdigest('%s-%s'%[app_name,Time.now.to_s])

        directory './', exclude_pattern: /(sidekiq|carrierwave|faye|mandrill|tire|elastic_search|search_indexes|mailers|uploaders|jobs)/

        directory './log'
        directory './tmp/pids'

        @redis ||= @sidekiq || @faye

        if @faye
          template './faye.ru'
          copy_file './config/boot_faye.rb'
          copy_file './config/initializers/faye.rb'
          copy_file './config/initializers/em-patches/faye.rb'
          copy_file './public/faye.html'
          copy_file './lib/faye_auth_extension.rb'
          copy_file './lib/faye_publisher.rb'
        end

        if @sidekiq
          if @faye
            copy_file './jobs/pong_time.rb'
          end
          copy_file './config/initializers/sidekiq.rb'
          copy_file './config/initializers/em-patches/sidekiq.rb'
          template './config/sidekiq.yml'
          template './config/boot_sidekiq.rb'
        end

        if @mandrill
          copy_file './config/initializers/mandrill.rb'
          copy_file './config/initializers/em-patches/mandrill.rb'
          directory './mailers'
        end

        if @es
          template './config/initializers/tire.rb'
          copy_file './config/initializers/em-patches/tire.rb'
          copy_file './lib/mongoid/tire_plugin.rb'
          directory './search_indexes'
        end

        if @carrierwave
          copy_file './config/initializers/em-patches/carrierwave.rb'
          copy_file './config/initializers/carrierwave.rb'
          directory './uploaders'
        end
      end
    end
  end
end
