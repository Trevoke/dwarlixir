# defmodule StructBuilder do
#   defmacro __using__(mods) do
#     quoted_imports = for mod <- mods, do: quote do: import unquote(mod)

#     quote do
#       unquote(mods)
#       |> Enum.map(&(&1.__struct__ |> Map.to_list |> Keyword.delete(:__struct__)))
#       |> List.flatten
#       |> defstruct

#       unquote(quoted_imports)
#     end
#   end
# end

# #------------------

# defmodule ComponentBuilder do
#   defmacro __using__(_opts) do
#     quote do
#       defmacro __component__(_opts), do: nil
#       defoverridable [__component__: 1]

#       defmacro __using__(opts) do
#         module = __MODULE__

#         quote do
#           component = unquote(module)

#           existing_fields = Module.get_attribute(__MODULE__, :struct) || %{}

#           component_has_struct? =
#             Enum.member?(component.__info__(:functions), {:__struct__, 0})

#           component_fields =
#             if component_has_struct?, do: component.__struct__, else: %{}

#           fields =
#             [existing_fields, component_fields]
#             |> Enum.map(&(&1 |> Map.to_list |> Keyword.delete(:__struct__)))
#             |> List.flatten

#           if existing_fields != %{} do
#             @struct nil
#             defoverridable [__struct__: 0, __struct__: 1]
#           end

#           if fields != [], do: defstruct fields

#           unquote(module).__component__(unquote(opts))
#         end
#       end
#     end
#   end
# end

# defmodule Core do
#   use ComponentBuilder

#   defstruct id: nil, name: "", controller: nil, exits: nil
# end

# defmodule Biology do
#   use ComponentBuilder

#   @callback health :: integer

#   defstruct [:lifespan, :sex, :pregnant]

#   defmacro __component__(opts) do
#     opts[:alive] # true

#     quote do
#       @behaviour Biology

#       def checkup, do: "Checking health..."
#     end
#   end
# end

# defmodule Foo do
#   use Core
#   use Biology, alive: true

#   def health, do: 100
# end

# #-----
# #
# #defmodule ComponentBuilder do

#   defmacro defcomponent(props, block \\ []) do
#     # Get block if exits
#     props = List.wrap props
#     {code, props} = Keyword.pop(props, :do, Keyword.get(block, :do, [""]))

#     quote location: :keep do
#       defmacro __using__(_binding \\ []) do
#         builder = unquote(__MODULE__)
#         props = unquote(props)
#         code = unquote(code)

#         quote do
#           # Only register hook once
#           hook = {unquote(builder), :__before_compile__}
#           unless hook in Module.get_attribute(__MODULE__, :before_compile) do
#             Module.put_attribute(__MODULE__, :before_compile, hook)
#           end

#           # Store props
#           Module.register_attribute(__MODULE__, :props, accumulate: true)
#           Module.put_attribute(__MODULE__, :props, unquote(props))

#           # Eval block
#           unquote(code)

#         end
#       end
#     end
#   end

#   defmacro __before_compile__(env) do
#     quote do
#       defstruct unquote(env.module)
#       |> Module.get_attribute(:props)
#       |> Enum.flat_map(&(Enum.map(&1, fn
#         {key, value} -> {key, value}
#         key -> {key, nil}
#       end)))
#     end
#   end

# end

# defmodule Core do
#   import ComponentBuilder

#   defcomponent id: nil, name: "", controller: nil, exits: nil do
#     Module.put_attribute __CALLER__.module, :enforce_keys, [:id]
#   end
# end

# defmodule Biology do
#   import ComponentBuilder

#   defcomponent [:lifespan, :sex, :pregnant] do
#     IO.puts "inside component"
#     # IO.puts alive
#   end
# end

# defmodule Foo do
#   use Core
#   use Biology, alive: true
# end
