defmodule Decompilerl do

  def decompile(module, device \\ :stdio) do
    with {:ok, beam} <- obtain_beam(module),
         code <- do_decompile(beam) do
           {:ok, code}
         end
    |> output(device)
  end

  defp obtain_beam(module) when is_atom(module) do
    IO.puts "Retrieving code for #{module}"
    case :code.get_object_code(module) do
      {^module, beam, _file} -> {:ok, beam}
      :error -> {:error, {:could_not_obtain_beam, module}}
      other -> other
    end
  end

  defp obtain_beam(module) when is_binary(module) do
    String.to_char_list(module)
  end

  defp do_decompile(beam_code) do
    {:ok, {_, [abstract_code: {_, ac}]}} =
      :beam_lib.chunks(beam_code, [:abstract_code])

    :erl_prettypr.format(:erl_syntax.form_list(ac))
  end

  defp output({:ok, code}, device),
    do: write_to(code, device)

  defp output(other, device) do
    IO.puts """
      Error: #{inspect other}
    """
  end

  defp write_to(code, :stdio) do
    IO.puts code
  end
  defp write_to(code, file_name) when is_binary(file_name) do
    {:ok, result} =
      File.open(file_name, [:write], fn(file) ->
        IO.binwrite(file, code)
      end)
    result
  end
end
