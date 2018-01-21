class API::V1::Translations < Grape::API
  include API::V1::Defaults

  resource :translations do
    desc 'Get all translations'
    get do
      present(Translation.all, with: API::V1::Entities::Translation)
    end
  end
end
