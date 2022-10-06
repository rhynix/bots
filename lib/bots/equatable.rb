module Bots
  # Equatable is a module that contains a single method that creates an
  # anonymous module. This anonymous module defines methods that can be used
  # to compare objects based on attributes that are passed arguments to the []
  # method.
  #
  # Usage:
  #
  # class Person < Struct(:name, :age)
  #   include Equatable[:name, :age]
  # end
  module Equatable
    def self.[](*attrs)
      Module.new do
        define_method(:==) do |otr|
          return false unless otr.instance_of?(self.class)
          return false unless attrs.all? { |attr| send(attr) == otr.send(attr) }

          return true
        end

        define_method(:eql?) do |otr|
          return false unless otr.instance_of?(self.class)
          return false unless attrs.all? { |attr| send(attr) == otr.send(attr) }

          return true
        end

        define_method(:hash) do
          [self.class, *attrs.map { |attr| send(attr) }].hash
        end
      end
    end
  end
end
