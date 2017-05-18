defmodule Mix.Tasks.Decompile do
  use Mix.Task

  @moduledoc false

  # @recursive true
  @manifest "decompile"

  def run(argv) do
    IO.puts "Decompiling"

    ensure_project_path()

    {opts, modules} =
      argv
      |> OptionParser.parse!(switches: [output: :string], aliases: [o: :output])
    device = Keyword.get(opts, :output, :stdio)
    IO.puts "Writing to #{device}"
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

  defp ensure_project_path() do
    # For some reason, the main project is not included in the code path with
    # this task
    project_paths =
      if Mix.Project.umbrella? do
        Mix.Project.apps_paths()
        |> Enum.map(&elem(&1, 1))
      else
        [Mix.Project.app_path()]
      end
      |> Enum.map(& &1 <> "/ebin")
      |> Enum.map(&String.to_charlist/1)
      |> :code.add_pathsz()
  end

  defp usage() do
    IO.puts """
    Decompilerl mix task

    usage: mix decompile <module_name> [-o <erl_file> | --output=<erl_file>]
    """
  end

end
