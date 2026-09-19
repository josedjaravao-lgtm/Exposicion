Code.require_file("util.ex")

defmodule SimuladorTienda do
  @moduledoc """
  Módulo de interfaz: interactúa con el usuario solicitando campos según su tipo.
  """

  def start do
    IO.puts("=== Bienvenido al Simulador de Tienda ===")
    loop_menu([])
  end

  defp loop_menu(inventario) do
    IO.puts("\n--- MENÚ PRINCIPAL ---")
    IO.puts("1. Agregar producto (Create)")
    IO.puts("2. Ver todos los productos (Read)")
    IO.puts("3. Actualizar producto (Update)")
    IO.puts("4. Eliminar producto (Delete)")
    IO.puts("5. Salir")

    opcion = IO.gets("Seleccione una opción: ") |> String.trim()

    case opcion do
      "1" -> loop_menu(menu_agregar(inventario))
      "2" ->
        menu_leer(inventario)
        loop_menu(inventario)
      "3" -> loop_menu(menu_actualizar(inventario))
      "4" -> loop_menu(menu_eliminar(inventario))
      "5" -> IO.puts("Saliendo del simulador... ¡Hasta luego!")
      _ ->
        IO.puts("Error: Opción no válida. Intente de nuevo.")
        loop_menu(inventario)
    end
  end

  # --- FUNCIÓN MAESTRA PARA PEDIR Y VALIDAR DATOS ---

  defp pedir_campo(mensaje, tipo) do
    entrada = IO.gets(mensaje) |> String.trim()

    # Delegamos al archivo Util pasándole el tipo (:int, :real, :string, :id)
    case Util.verificar_campo(entrada, tipo) do
      {:ok, valor_valido} -> valor_valido
      {:error, razon} ->
        IO.puts("Error: #{razon}")
        pedir_campo(mensaje, tipo) # Si hay error, vuelve a preguntar
    end
  end

  # --- INTERFACES DE CADA OPCIÓN ---

  defp menu_agregar(inventario) do
    # Usamos los átomos para definir las reglas estrictas de cada campo
    id = pedir_campo("Ingrese ID del producto (letras y números permitidos): ", :id)
    nombre = pedir_campo("Ingrese nombre del producto (solo letras): ", :string)
    precio = pedir_campo("Ingrese precio del producto: ", :real)
    stock = pedir_campo("Ingrese cantidad en stock (solo números): ", :int)

    nuevo_inventario = Util.agregar_producto(inventario, id, nombre, precio, stock)

    IO.puts("Verificado: Producto agregado con éxito.")
    nuevo_inventario
  end

  defp menu_leer([]) do
    IO.puts("El inventario está vacío.")
  end

  defp menu_leer(inventario) do
    IO.puts("\n--- Inventario Actual ---")
    Enum.each(inventario, fn producto ->
      IO.puts("ID: #{producto.id} | Nombre: #{producto.nombre} | Precio: $#{producto.precio} | Stock: #{producto.stock}")
    end)
  end

  defp menu_actualizar(inventario) do
    id = pedir_campo("Ingrese el ID del producto a actualizar: ", :id)

    case Util.buscar_producto(inventario, id) do
      {:error, mensaje} ->
        IO.puts("Error: #{mensaje}")
        inventario

      {:ok, _producto} ->
        nuevo_precio = pedir_campo("Ingrese el nuevo precio: ", :real)
        nuevo_stock = pedir_campo("Ingrese el nuevo stock: ", :int)

        IO.puts("Verificado: Producto actualizado con éxito.")
        Util.actualizar_producto(inventario, id, nuevo_precio, nuevo_stock)
    end
  end

  defp menu_eliminar(inventario) do
    id = pedir_campo("Ingrese el ID del producto a eliminar: ", :id)

    case Util.buscar_producto(inventario, id) do
      {:error, mensaje} ->
        IO.puts("Error: #{mensaje}")
        inventario

      {:ok, _producto} ->
        IO.puts("Verificado: Producto eliminado con éxito.")
        Util.eliminar_producto(inventario, id)
    end
  end
end

SimuladorTienda.start()
