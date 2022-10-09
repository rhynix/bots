# frozen_string_literal: true

module Bots
  autoload :InstructionsParser, "bots/instructions_parser"
  autoload :Game,               "bots/game"
  autoload :GameState,          "bots/game_state"
  autoload :Runner,             "bots/runner"
  autoload :Equatable,          "bots/equatable"
  autoload :Server,             "bots/server"
  autoload :Entities,           "bots/entities"
  autoload :Instructions,       "bots/instructions"
  autoload :Log,                "bots/log"

  autoload :Error,  "bots/error"
  autoload :Errors, "bots/errors"

  autoload :PreValidator,  "bots/pre_validator"
  autoload :PostValidator, "bots/post_validator"
end
