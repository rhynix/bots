module Bots
  autoload :OperationsDeserializer, "bots/operations_deserializer"
  autoload :PreValidator,           "bots/pre_validator"
  autoload :PostValidator,          "bots/post_validator"
  autoload :Game,                   "bots/game"
  autoload :Equatable,              "bots/equatable"
  autoload :AssertionError,         "bots/assertion_error"

  autoload :GoesToOperation,  "bots/goes_to_operation"
  autoload :GivesToOperation, "bots/gives_to_operation"

  autoload :Bot,    "bots/bot"
  autoload :Output, "bots/output"
end
