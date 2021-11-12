defmodule PolarisIcon.IconGenerator do
  @moduledoc """
  This library provides functions for every [Polaris](https://polaris.shopify.com/) [Icon](https://polaris-icons.shopify.com/).
  """

  @doc false
  defmacro __before_compile__(%Macro.Env{module: module}) do
    unless Module.has_attribute?(module, :icon_dir) do
      raise CompileError, description: "@icon_dir attrubute is required"
    end

    icon_dir = Module.get_attribute(module, :icon_dir)
    default_attrs = Module.get_attribute(module, :default_attrs)

    icon_paths =
      Path.absname(icon_dir, :code.priv_dir(:polaris_icon))
      |> Path.join("*.svg")
      |> Path.wildcard()

    for path <- icon_paths do
      generate_function(path, default_attrs)
    end
  end

  @doc false
  def generate_function(path, default_attrs) do
    name =
      Path.basename(path, ".svg")
      |> String.replace("-", "_")
      |> Macro.underscore()
      |> String.to_atom()

    icon = File.read!(path)
    {i, _} = :binary.match(icon, ">")
    {_, body} = String.split_at(icon, i)

    doc = """
    ![](/#{Path.relative_to(path, :code.priv_dir(:polaris_icon))}) {: width=24px}

    ## Examples
        iex> #{name}()
        iex> #{name}(class: "h-6 w-6 text-gray-500")
    """

    quote do
      @doc unquote(doc)
      @spec unquote(name)(keyword(binary)) :: {:safe, [any(), ...]}
      def unquote(name)(opts \\ []) do
        opts = Keyword.merge(unquote(default_attrs), opts)

        attrs =
          for {k, v} <- opts do
            safe_k =
              k |> Atom.to_string() |> String.replace("_", "-") |> Phoenix.HTML.Safe.to_iodata()

            safe_v = v |> Phoenix.HTML.Safe.to_iodata()

            {:safe, [?\s, safe_k, ?=, ?", safe_v, ?"]}
          end

        {:safe, ["<svg", Phoenix.HTML.Safe.to_iodata(attrs), unquote(body)]}
      end
    end
  end
end
