defmodule OrchestraWeb.RoomChannel do
  use OrchestraWeb, :channel
  alias OrchestraWeb.Presence

  def join("room:lobby", payload, socket) do
    if authorized?(payload) do
      send(self(), :after_join)
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (room:lobby).
  def handle_in("playNote", payload, socket) do
    IO.inspect payload
    broadcast(socket, "playNote", payload)
    {:noreply, socket}
  end

  def handle_info(:after_join, socket) do
    push(socket, "presence_state", Presence.list(socket))

    uuid = Ecto.UUID.generate()

    {:ok, _} =
      Presence.track(socket, uuid, %{
        online_at: inspect(System.system_time(:second)),
        uuid: uuid
      })

    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
