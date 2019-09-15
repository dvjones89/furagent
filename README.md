# FurAgent

## What Does FurAgent Do?
FurAgent is a simple Elixir & Phoenix app that integrates with [FreeAgent](https://www.freeagent.com) and makes it easy to create multi-line invoices for services that span multiple days. The current FreeAgent user interface requires line items to be added individually, which gets a little painful when you're providing a daily service over multiple weeks (for example, Pet Sitting).

## Can I See FurAgent In Action?
Sure! There's a copy of FurAgent running in a sandbox environment on [Heroku](https://www.heroku.com/free).  
http://furagent-sandbox.herokuapp.com/

Don't worry if the page takes a few seconds to load, there's a Virtual Machine spinning up behind the scenes.


## Running FurAgent Locally
To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`
