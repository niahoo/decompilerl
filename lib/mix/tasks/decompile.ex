defmodule Mix.Tasks.Decompile do
  use Mix.Task

  @moduledoc false

  # @recursive true
  @manifest "decompile"

  def run(argv) do
    Mix.Task.run "compile"
    {opts, modules} =
      argv
      |> OptionParser.parse!(switches: [output: :string], aliases: [o: :output])
    device = Keyword.get(opts, :output, :stdio)
    case modules do
      [module] ->
        module
        |> to_module_atom()
        |> Decompilerl.decompile(device)
      _other ->
        usage()
    end
  end

  defp to_module_atom(module_name) do
    ret = if String.starts_with?(module_name, "Elixir.") do
      module_name
    else
      "Elixir." <> module_name
    end
    |> String.to_atom()
  end

  defp usage() do
    IO.puts """
    Decompilerl mix task

    usage: mix decompile <module_name> [-o <erl_file> | --output=<erl_file>]
    """
  end

end
