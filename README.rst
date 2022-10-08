Bots
====

Bots is a simulator for a simple game. The game has the following rules:

- Chips with a value are given to bots.
- When a bot has two chips, it gives its lower value chip to a bot or
  output. It gives its higher value to another bot.
- The game is done if all chips are at an output.

For examples of the input, see the examples directory.

Prerequisites
=============

This application was tested with Ruby 3.1.2. Provided Ruby is installed,
dependendencies can be installed using :code:`bundle install`.

Running the application
=======================

The application is available as a command line interface and a simple web
server. The CLI tool accepts a path that points to a text based input file. For
example:::

  bin/bots examples/input.txt

The web server can be started using :code:`bin/server`. It accepts no command
line arguments and listens to port 8080. The inputs can be POSTed to the web
server root in a JSON array. For example, with cURL:::

  curl --data '@examples/input.json' 127.0.0.1:8080

Alternatively, the application can be run in a docker container. For example:::

  docker build -t bots:latest .
  docker run -p 8080:8080 bots:latest

Running the tests
=================

The tests can be run using :code:`bin/rspec`.
