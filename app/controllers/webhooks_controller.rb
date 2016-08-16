class WebhooksController < ApplicationController
  skip_before_filter  :verify_authenticity_token

  def alexa
    request_type = params['request']['type']

    case request_type
    when "IntentRequest"
      response = AlexaResponseService.new(params).intent_response

    when "LaunchRequest"
      response = AlexaResponseService.new(params).launch_request_response

    else
      # Blank response for terminate session request
      response = AlexaResponseService.new(params).contruct_response("")

    end

    render json: response
  end

end
