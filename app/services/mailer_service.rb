class MailerService

  def initialize
    @url = Settings.mailgun.url
    @from = Settings.mailgun.from
  end

  def send_advisor_contact_message
    advisor_email = "Advisor <gys.muller@gmail.com>"
    message = "Please contact your client Gys to discuss his portfolio."

    RestClient.post @url,
      from: @from,
      to: advisor_email,
      subject: "Please contact Gys",
      text: message
  end

  def send_portfolio_overview
    user_email = "Gys <gys.muller@gmail.com>"
    message = "Here is an overview of your portfolio https://docs.google.com/spreadsheets/d/1qbZfJ9SNGbpQP0Jq2pg7KLLIWKNx6wtIwq6lfUTNJqI/edit#gid=0"

    RestClient.post @url,
      from: @from,
      to: user_email,
      subject: "Portfolio Overview",
      text: message
  end

end
