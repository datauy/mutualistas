require 'sinatra/base'
require 'json'
require 'sinatra/partial'
require root_path('helpers/assets')
require root_path('helpers/rankings')

class App < Sinatra::Base

  register Sinatra::Partial

  helpers Helpers::Assets
  helpers Helpers::Rankings

  APP_DOMAIN = 'mutualistas.datauy.org'

  configure do
    set :views, root_path('views')
    set :public_folder, root_path('public')
    set :static_cache_control, [:public, max_age: 60 * 60 * 24]
    set :environment, (ENV['RACK_ENV'] || 'development').to_sym
    set :partial_template_engine, :erb

    set :app_domain, settings.development? ? /localhost/ : APP_DOMAIN

    enable :static
  end

  configure :production, :development do
    enable :logging
  end

  not_found do
    erb :'not_found.html'
  end

  get %r{/(?:departamento/([^/]+))?$} do |departamento|
    if settings.app_domain === request.env['HTTP_HOST']
      cache_control :public, :must_revalidate, max_age: 60 * 60 * 24

      departamento = 'montevideo' unless departamento

      prioridades = get_prioridades(params)
      mutualistas = get_rankings(departamento, prioridades)
    
      erb(:'index.html', layout: :'layout.html', locals: {
        departamento: departamento,
        mutualistas: mutualistas,
        prioridades: prioridades
      })
    else
      redirect("http://#{APP_DOMAIN}", 301)
    end
  end

  get '/como_calculamos' do
    erb(:'como_calculamos.html', layout: :'layout.html')
  end

end
