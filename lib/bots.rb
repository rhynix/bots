module Bots
  autoload :OperationsDeserializer, "bots/operations_deserializer"
  autoload :Validator,              "bots/validator"
  autoload :Equatable,              "bots/equatable"

  autoload :GoesToOperation,  "bots/goes_to_operation"
  autoload :GivesToOperation, "bots/gives_to_operation"

  autoload :Bot,    "bots/bot"
  autoload :Output, "bots/output"
end
