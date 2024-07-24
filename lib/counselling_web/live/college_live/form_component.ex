defmodule CounsellingWeb.CollegeLive.FormComponent do
  use CounsellingWeb, :live_component

  alias Counselling.Colleges

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage college records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="college-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:established_year]} type="number" label="Established year" />
        <.input field={@form[:location]} type="text" label="Location" />
        <:actions>
          <.button phx-disable-with="Saving...">Save College</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{college: college} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(Colleges.change_college(college))
     end)}
  end

  @impl true
  def handle_event("validate", %{"college" => college_params}, socket) do
    changeset = Colleges.change_college(socket.assigns.college, college_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"college" => college_params}, socket) do
    save_college(socket, socket.assigns.action, college_params)
  end

  defp save_college(socket, :edit, college_params) do
    case Colleges.update_college(socket.assigns.college, college_params) do
      {:ok, college} ->
        notify_parent({:saved, college})

        {:noreply,
         socket
         |> put_flash(:info, "College updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_college(socket, :new, college_params) do
    case Colleges.create_college(college_params) do
      {:ok, college} ->
        notify_parent({:saved, college})

        {:noreply,
         socket
         |> put_flash(:info, "College created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
