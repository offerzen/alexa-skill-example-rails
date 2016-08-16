# Alexa Skill Example for Rails

This project demonstrate some of the functionality which can be achieved with an Alexa skill service. This services enables a user to:

* fetch values for a Google Sheet
* write values to a Google Sheet
* send an email to yourself
* fetch the stock price for a list of given companies

## Overview

**This guide assumes you are already a rails developer and have ruby and rails setup and running on your laptop/development environment.**

This app was also built on OSX but should run fairly easily on linux. We don't recommend Ruby/Rails dev on Windows.

## Setup

**Install the gems**

    bundle install

**Start the server**

    rails s

**Setup ngrok to expose the endpoint**

    ngrok http 3000

**Setup your skill interface**

* Go to [Amazon Developer's Portal](https://developer.amazon.com) and create a new Alexa skill
* Setup the interaction model using the provided `Intent Schema`, `Sample Utterance`, and `Custom slot types` which can be found in the `/interaction_model` folder.
* Setup the endpoint to point to your ngrok tunnel, example: `https://81429dd5.ngrok.io/alexa`
