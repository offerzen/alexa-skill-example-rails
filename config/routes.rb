Rails.application.routes.draw do

  post "alexa" => "webhooks#alexa", as: :alexa

end
