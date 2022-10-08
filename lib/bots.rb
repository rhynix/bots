module Bots
  autoload :OperationsDeserializer, "bots/operations_deserializer"
  autoload :PreValidator,           "bots/pre_validator"
  autoload :PostValidator,          "bots/post_validator"
  autoload :Game,                   "bots/game"
  autoload :CLI,                    "bots/cli"
  autoload :Equatable,              "bots/equatable"
  autoload :AssertionError,         "bots/assertion_error"
  autoload :Server,                 "bots/server"

  autoload :BotLogItem,   "bots/bot_log_item"
  autoload :InputLogItem, "bots/input_log_item"

  autoload :InputOperation,  "bots/input_operation"
  autoload :BotOperation,    "bots/bot_operation"

  autoload :Bot,    "bots/bot"
  autoload :Output, "bots/output"
end
