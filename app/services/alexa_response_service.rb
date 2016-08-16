class AlexaResponseService

  DEFAULT_CARD_IMAGE_SMALL = "https://s3-us-west-2.amazonaws.com/echo-demo-app-images/banana_small.png"
  DEFAULT_CARD_IMAGE_LARGE = "https://s3-us-west-2.amazonaws.com/echo-demo-app-images/banana_large.png"

  def initialize(params)
    @params = params
  end

  # Construct response returned to Skill Interface
  def contruct_response(text, reprompt_text="", session_attributes=nil, session_end=false, card_image_small=DEFAULT_CARD_IMAGE_SMALL, card_image_large=DEFAULT_CARD_IMAGE_LARGE)
    if text.present?
      {"response": {
          "outputSpeech": {
            "type": "PlainText",
            "text": text
          },
          'card': {
            "type": 'Standard',
            "title": 'My Portfolio',
            "text": text,
            "image": {
              "smallImageUrl": card_image_small,
              "largeImageUrl": card_image_large
            }
          },
          "reprompt": {
            "outputSpeech": {
              "type": "PlainText",
              "text": reprompt_text
            }
          },
          "shouldEndSession": session_end
        },
        "sessionAttributes": session_attributes
      }
    else
      # Blank response
      {"response": {
          "outputSpeech": {
            "type": "PlainText",
            "text": ""
          },
          "shouldEndSession": false
        }
      }
    end
  end

  # Determine the response for a given intent type
  def intent_response
    intent = @params['request']['intent']['name']

    if intent == "GetPortfolioPerformance" && !previous_session_equals?("get_portfolio_performance")
        response = get_portfolio_performance_response

    elsif intent == "GetPortfolioValue" && !previous_session_equals?("get_portfolio_value")
      response = get_portfolio_value_response

    elsif intent == "GetMoreOptions" && !previous_session_equals?("get_more_options")
      response = get_more_options_response

    elsif intent == "ChooseStockPrice" && !previous_session_equals?("choose_stock_price")
      response = choose_stock_price_response

    elsif intent == "ChooseMonthlyContribution" && !previous_session_equals?("choose_monthly_contribution")
      response = choose_monthly_contribution_response

    elsif intent == "IncreaseMonthlyContribution" && previous_session_equals?("choose_monthly_contribution") && !previous_session_equals?("increase_monthly_contribution")
      response = increase_monthly_contribution_response

    elsif intent == "AMAZON.NoIntent" || intent == "AMAZON.YesIntent"
      # get yes of no answer
      answer = intent == "AMAZON.YesIntent"

      response = get_answer_response(answer)

    else
      response = unsure_response
    end
  end

  # Reponse contructed when the skill is launched
  def launch_request_response
    text = "Welcome to your portfolio. Would you like to know how your portfolio is performing, what the total value of your portfolio is? Or do you want hear more options?"

    response = contruct_response(text)
  end

  # Response contructed with a GetPortfolioPerformance intent
  def get_portfolio_performance_response
    value = GoogleDriveService.new.read_sheet(8,2)

    if value.to_i < 0
      direction = "down"
    else
      direction = "up"
    end

    reprompt_text = "Do you want your financial advisor to contact you?"
    text = "Your portfolio is #{direction} by #{value} percent over the past year. #{reprompt_text}"

    session_attributes = {"previous_session": "get_portfolio_performance"}

    response = contruct_response(text, reprompt_text, session_attributes)
  end

  # Response contructed with a GetPortfolioValue intent
  def get_portfolio_value_response
    value = GoogleDriveService.new.read_sheet(5,3)
    reprompt_text = "Do you want me to send you an overview of your investment portfolio?"
    text = "Your current portfolio value is #{value} rand. #{reprompt_text}"

    session_attributes = {"previous_session": "get_portfolio_value"}

    response = contruct_response(text, reprompt_text, session_attributes)
  end

  # Response contructed with a GetMoreOptions intent
  def get_more_options_response
    text = "Would you like to increase your monthly contribution? Or do you want to check the stock price for Standard bank, Google, or Apple?"

    session_attributes = {"previous_session": "get_more_options"}

    response = contruct_response(text, "", session_attributes)
  end

  def choose_stock_price_response
    text = StockService.stock_price(@params)

    session_attributes = {"previous_session": "choose_stock_price"}

    response = contruct_response(text, "", session_attributes)
  end

  def choose_monthly_contribution_response
    value = GoogleDriveService.new.read_sheet(9,2)
    text = "You current monthly contribution is #{value} rand. With how much rands do you want to increase your contribution?"

    session_attributes = {"previous_session": "choose_monthly_contribution"}

    response = contruct_response(text, "", session_attributes)
  end

  def increase_monthly_contribution_response
    increase = request['request']['intent']['slots']['Increase']['value'].to_i

    service = GoogleDriveService.new
    value = service.read_sheet(9,2).to_i + increase
    service.write_sheet(value,9,2)

    text = "Your monthly contribution has been increased to #{value} rand. "

    session_attributes = {"previous_session": "increase_monthly_contribution"}

    response = contruct_response(text, "", session_attributes)
  end

  # Generic response if not sure about intent
  def unsure_response
    options = "Would you like to know how your portfolio is performing, would you like to know the total value of your portfolio, would you like to increase your monthly contribution. Or do you want to check the stock price for Standard bank, Google, or Apple?"
    text = "I'm not exactly sure what you want. #{options}"

    response = contruct_response(text)
  end

  def get_answer_response(answer)
    action_info = ""

    if answer && previous_session_equals?("get_portfolio_performance")

      # Send contact email to advisor
      MailerService.new.send_advisor_contact_message
      action_info = "Ok no problem. I've emailed your personal advisor with and requested that he contacts you."

    elsif answer && previous_session_equals?("get_portfolio_value")

      # Send portfolio overview to user
      MailerService.new.send_portfolio_overview
      action_info = "Ok no problem. I've sent you a copy of your portfolio."

    else

      # Blank response if yes or no was said in response to nothing
      action_info = ""

    end

    response = contruct_response(action_info)
  end

  # Fetch the previous session from the session attributes
  def previous_session
    session = ""
    if @params['session']['attributes'].present? && @params['session']['attributes']['previous_session'].present?
      session = @params['session']['attributes']['previous_session']
    end

    session
  end

  # Checks if the previous session is equal to query
  def previous_session_equals?(session)
    previous_session.present? && @params['session']['attributes']['previous_session'] == session
  end

end
