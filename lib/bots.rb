# frozen_string_literal: true

module Bots
  autoload :OperationsParser, "bots/operations_parser"
  autoload :Game,             "bots/game"
  autoload :GameState,        "bots/game_state"
  autoload :CLI,              "bots/cli"
  autoload :Equatable,        "bots/equatable"
  autoload :AssertionError,   "bots/assertion_error"
  autoload :Server,           "bots/server"

  autoload :PreValidator,  "bots/pre_validator"
  autoload :PostValidator, "bots/post_validator"

  autoload :BotGiveLogItem,    "bots/bot_give_log_item"
  autoload :BotCompareLogItem, "bots/bot_compare_log_item"
  autoload :InputLogItem,      "bots/input_log_item"

  autoload :InputOperation,  "bots/input_operation"
  autoload :BotOperation,    "bots/bot_operation"

  autoload :Bot,    "bots/bot"
  autoload :Output, "bots/output"
end
