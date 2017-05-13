defmodule World.Generator do
  @node_count 3000
  @edge_count 5000

  def call do
    connect_all_islands(Enum.to_list(1..@node_count), make_edge_list()) # [{loc_id, to_id}]
    |> Enum.group_by(fn({from, _to}) -> from end) # %{loc_id => [{loc_id, to_id}]}
    |> Enum.map(fn({loc, pathways}) ->
      World.location("#{loc}", "#{loc}", "room id #{loc}",
        Enum.map(Enum.uniq(pathways), fn({_to, from}) ->
          World.partial_pathway("#{from}", "#{from}")
        end))
    end)
  end

  def random_node, do: Enum.random(1..@node_count)

  def edge_pair(a, b) when a != b, do: [{a, b}, {b, a}]
  def edge_pair(_a, _b), do: []

  def make_edge_list() do
    1..@edge_count
    |> Enum.flat_map(
      fn(_x) -> edge_pair(random_node(), random_node())
    end)
  end

  def direct_edges(node1, edge_list) do
    Enum.filter(edge_list, fn({a, _b}) -> a == node1 end)
  end

  def get_connected(node1, edge_list) do
    Enum.uniq traverse(node1, edge_list, [])
  end

  def traverse(node1, edge_list, visited) do
    if Enum.member?(visited, node1) do
      visited
    else
      x = [node1 | visited]
      y = direct_edges(node1, edge_list)
      List.foldl(y, x ,fn({_a, b}, acc) -> traverse(b, edge_list, acc) end)
    end
  end

  def find_islands(nodes, edge_list) do
    find_island(nodes, edge_list, [])
  end

  def find_island([] = _nodes, _edge_list, islands), do: islands

  def find_island([h | t] = nodes, edge_list, islands) do
    connected = get_connected(h, edge_list)
    if Enum.empty?(connected) do
      find_island(t, edge_list, islands)
    else
      unconnected = nodes -- connected
      islands = [connected | islands]
      find_island(unconnected, edge_list, islands)
    end
  end

  def generate_necessary_bridges(islands), do: generate_necessary_bridges(islands, [])

  def generate_necessary_bridges([_island], acc), do: acc

  def generate_necessary_bridges([h|t] = islands, acc) when length(islands) == 2 do
    edge_pair(Enum.random(h), Enum.random(List.first(t))) ++ acc
  end

  def generate_necessary_bridges([h|t] = islands, acc) when length(islands) > 2 do
    [t1|_t2] = islands
    generate_necessary_bridges(t, edge_pair(Enum.random(h), Enum.random(t1)) ++ acc)
  end

  def connect_all_islands(nodes, edge_list) do
    bridges =
      nodes
      |> find_islands(edge_list)
      |> generate_necessary_bridges(edge_list)
    bridges ++ edge_list
  end

end
