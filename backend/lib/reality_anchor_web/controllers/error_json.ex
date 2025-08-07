defmodule RealityAnchorWeb.ErrorJSON do
  # If you want to customize a particular status code,
  # you may add your own clauses, such as:
  #
  # def render("500.json", _assigns) do
  #   %{errors: %{detail: "Internal Server Error"}}
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.json" becomes
  # "Not Found".
  def render(template, _assigns) do
    %{error: %{message: Phoenix.Controller.status_message_from_template(template)}}
  end

  @doc """
  Renders changeset errors
  """
  def changeset(%{changeset: changeset}) do
    %{error: %{message: "Validation failed", details: translate_errors(changeset)}}
  end

  @doc """
  Renders a custom error message
  """
  def error(%{message: message}) do
    %{error: %{message: message}}
  end

  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  defp translate_error({msg, opts}) do
    Regex.replace(~r"%{(\w+)}", msg, fn _, key ->
      opts |> Keyword.get(String.to_existing_atom(key), key) |> to_string()
    end)
  end
end