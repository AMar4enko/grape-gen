module API
  class Application < Grape::API
    format :json
    formatter :json, Grape::Formatter::Jbuilder

    logger Logging.logger[:api]

    helpers do
      def logger; API::Application.logger end

      def ability
        @_ability ||= ApiAbility.new(current_user)
      end

      def authorize!(*args)
        error! :unauthorized, 401 unless ability.can?(*args)
      end
      def current_user
        warden.authenticate(:access_token)
      end

      def warden; env['warden'] end

      def error!(msg, error = 400)
        super(msg, error, header)
      end

      def set_locals(locals_hash)
        env['api.tilt.locals'] = locals_hash
      end

      def add_locals(locals_hash)
        env['api.tilt.locals'] = (env['api.tilt.locals'] || {}).merge(locals_hash)
      end

      def redis
        REDIS_CONNECTION
      end
    end

    route [:get, :post, :put, :patch], :unauthenticated do
      error! :unauthenticated, 401
    end

    before do
      header('Access-Control-Allow-Origin', '*')
      header('Access-Control-Allow-Methods', '*')
      header('Access-Control-Allow-Headers', 'Content-Type,Accept-Version,X-Authorize')
    end

    rescue_from Mongoid::Errors::DocumentNotFound do
      Rack::Response.new(['Not found'], 404, env['api.endpoint'].header).finish
    end

    rescue_from :all do |exception|
      API::Application.logger.error exception
      Rack::Response.new(['Error'], 500, env['api.endpoint'].header).finish
    end

    rescue_from Grape::Exceptions::ValidationErrors do |exception|
      body = [MultiJson.dump(validation: exception.errors.map{|params, errors| Hash[params.zip([errors.first.to_s] * params.length)]}.inject({},&:merge))]
      Rack::Response.new(body, 400, env['api.endpoint'].header).finish
    end

    rescue_from Mongoid::Errors::Validations do |exception|
      body = [MultiJson.dump(validation: exception.document.errors.messages.map{|attr, errors| {attr => errors.first}}.inject({},&:merge))]
      Rack::Response.new(body, 400, env['api.endpoint'].header).finish
    end

    mount Mounts::Auth => '/auth'
    mount Mounts::Profile => '/profile'

    get :ping do
      {pong: true}
    end

    post :redis_write do
      {result: redis.set('redis_key', Time.now.to_s)}
    end

    get :redis_read do
      {result: redis.get('redis_key')}
    end
  end
end