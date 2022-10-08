====
Bots
====

Bots is a simulator for a simple game. The game has the following rules:

- Chips with a value are given to bots.
- When a bot has two chips, it gives its lower value chip to a bot or
  output. It gives its higher value to another bot or output.
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
example::

  $ bin/bots examples/input.txt

The web server can be started using :code:`bin/server`. It accepts no command
line arguments and listens to port 8080. The inputs can be POSTed to the web
server root in a JSON array. For example, with cURL::

  $ curl --data @examples/input.json 127.0.0.1:8080

Alternatively, the server can be run in a docker container. For example::

  $ docker build -t bots:latest .
  $ docker run -p 8080:8080 bots:latest

Running the tests
=================

The tests can be run using :code:`bin/rspec`.

Architectural decisions
=======================

Validators
----------

The main game loop makes some assumptions about the data, both regarding the
inputs and the outputs after the game has finished. Some of these assumptions
are tested by the pre and post validator respectively. While these will not
cover all potential invalid datasets, they will cover the most likely ones.

Performance optimizations
-------------------------

Since running the application with the example dataset is relatively fast,
simplicity was chosen over optimizing for performance. This means there are some
potential performance optimizations, including:

* Not trying all operations each time. If bot X gives chips to bot Y and Z,
  checking only operations for bot Y and Z would suffice to keep the game
  running.
* Mutable state: the library barely contains any mutable state. This was an
  intential choice to make reasoning about the code easier. Immutable state
  often does lead to more GC pressure in Ruby, so using mutable state might
  improve performance.

Challenge
=========

This project was part of a challenge. This challenge poses two questions:

1. Based on your instructions, what is the number of the bot that is responsible
   for comparing value-61 microchips with value-17 microchips?

2. What do you get if you multiply together the values of one chip in each of
   outputs 0, 1, and 2?

Running :code:`bin/answers` with the example inputs provides the following
answers::

  $ bin/answers examples/input.txt
  Bot handling value-61 and value-17: 73
  Product of output 0, 1, and 2: 3965
