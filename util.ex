defmodule Util do
  @moduledoc """
  Módulo de procesos internos: validaciones estrictas y operaciones CRUD.
  """

  # --- PROCESOS DE VERIFICACIÓN ESTRICTA ---

  # 1. Validación para :int (Ej: stock) - Netamente números enteros
  def verificar_campo(entrada, :int) do
    if String.match?(entrada, ~r/^\d+$/) do
      {:ok, String.to_integer(entrada)}
    else
      {:error, "El valor debe contener netamente números enteros."}
    end
  end

  # 2. Validación para :real / :double (Ej: precio) - Números enteros o decimales
  def verificar_campo(entrada, :real) do
    case Float.parse(entrada) do
      {numero, ""} -> {:ok, numero}
      _ ->
        case Integer.parse(entrada) do
          {numero, ""} -> {:ok, numero / 1}
          _ -> {:error, "El valor debe ser un número válido (ej: 15 o 15.5)."}
        end
    end
  end

  # 3. Validación para :string (Ej: nombre) - Solo letras y espacios
  def verificar_campo(entrada, :string) do
    # La expresión regular permite letras (mayúsculas, minúsculas, acentos) y espacios.
    if String.match?(entrada, ~r/^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$/) do
      {:ok, entrada}
    else
      {:error, "Solo se permiten letras (no se admiten números ni símbolos)."}
    end
  end

  # 4. Validación para :id - Alfanumérico, pero NO netamente letras
  def verificar_campo(entrada, :id) do
    es_alfanumerico = String.match?(entrada, ~r/^[a-zA-Z0-9]+$/)
    tiene_numero = String.match?(entrada, ~r/\d/)

    if es_alfanumerico and tiene_numero do
      {:ok, entrada} # Se retorna como texto porque puede contener letras
    else
      {:error, "El ID puede tener letras y números, pero NO puede ser solo letras ni tener símbolos. Debe incluir al menos un número."}
    end
  end

  # --- OPERACIONES CRUD ---

  def agregar_producto(inventario, id, nombre, precio, stock) do
    producto = %{id: id, nombre: nombre, precio: precio, stock: stock}
    inventario ++ [producto]
  end

  def buscar_producto(inventario, id_buscar) do
    case Enum.find(inventario, fn p -> p.id == id_buscar end) do
      nil -> {:error, "Producto no encontrado en el inventario."}
      producto -> {:ok, producto}
    end
  end

  def actualizar_producto(inventario, id, nuevo_precio, nuevo_stock) do
    Enum.map(inventario, fn p ->
      if p.id == id do
        %{p | precio: nuevo_precio, stock: nuevo_stock}
      else
        p
      end
    end)
  end

  def eliminar_producto(inventario, id) do
    Enum.reject(inventario, fn p -> p.id == id end)
  end
end
