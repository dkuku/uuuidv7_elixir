defmodule UUUIDv7 do
  @moduledoc """
  UUUIDv7 for Elixir.

  Used for generating version 7 UUIDs using submicrosecond precision.
  Normally the default precision is 1 millisecond, this causes issues
  when generating UUIDs in bulk because we can generate multiple UUIDs
  in the same millisecond. This module allows you to generate UUIDs with
  submicrosecond precision.

    UUUIDv7.generate()
    "018e90d8-06e8-7f9f-bfd7-6730ba98a51b"

    UUUIDv7.bingenerate()
    <<1, 142, 144, 216, 6, 232, 127, 159, 191, 215, 103, 48, 186, 152, 165, 27>>

  """

  @typedoc """
  A hex-encoded UUID string.
  """
  @type t :: <<_::288>>

  @typedoc """
  A raw binary representation of a UUID.
  """
  @type raw :: <<_::128>>

  @version 7
  @variant 2

  @doc """
  Generates a version 7 UUID using submilliseconds for increased clock
  precision.

  ## Example

    iex> [UUUIDv7.generate(), UUUIDv7.generate()]
    iex> |> Enum.map(& String.byte_slice(&1, 0, 11))
    iex> |> Enum.reduce(fn second, first -> second == first end)
    true

  """
  @spec generate() :: t
  def generate, do: bingenerate() |> encode()

  @doc """
  Generates a version 7 UUID in the binary format.

  ## Example

    iex> [UUUIDv7.bingenerate(), UUUIDv7.bingenerate()]
    iex> |> Enum.map(& :binary.part(&1, 0, 5))
    iex> |> Enum.reduce(fn second, first -> second == first end)
    true

  """
  def bingenerate do
    {milliseconds, scaled_nanos} = get_time()

    <<rand::62, _::2>> = :crypto.strong_rand_bytes(8)

    <<milliseconds::big-unsigned-48, @version::4, scaled_nanos::12, @variant::2, rand::62>>
  end

  # This maps the microsecond range to 4096 values
  # that fits in 12 bits
  @scale 1_000_000 / 4096
  @nanoseconds_per_millisecond 1_000_000
  @doc """
  returns the current time in milliseconds and scaled nanoseconds
  """
  def get_time do
    timestamp = System.system_time(:nanosecond)
    milliseconds = div(timestamp, @nanoseconds_per_millisecond)
    remaining_nanos = rem(timestamp, milliseconds)
    {milliseconds, scale_nanoseconds(remaining_nanos)}
  end

  @doc """
  scales the remaining nanoseconds to fit in 12 bits

  ## Example

      iex> UUUIDv7.scale_nanoseconds(0)
      0
      iex> UUUIDv7.scale_nanoseconds(500000)
      2048
      iex> UUUIDv7.scale_nanoseconds(999999)
      0xFFF

  """
  def scale_nanoseconds(nanos) do
    trunc(nanos / @scale)
  end

  @doc """
  Extract the millisecond timestamp from the UUID.

  ## Example

      iex> UUUIDv7.extract_timestamp("018ecb40-c457-73e6-a400-000398daddd9")
      1712807003223

  """
  @spec extract_timestamp(t | raw) :: integer
  def extract_timestamp(
        <<timestamp_ms::big-unsigned-48, @version::4, _rand_a::12, @variant::2, _::62>>
      ) do
    timestamp_ms
  end

  def extract_timestamp(<<_::288>> = uuid) do
    decode(uuid) |> extract_timestamp()
  end

  @doc """
  Encode a raw UUID to the string representation.

  ## Example

      iex> UUUIDv7.encode(<<1, 142, 144, 216, 6, 232, 127, 159, 191, 215, 103, 48, 186, 152, 165, 27>>)
      "018e90d8-06e8-7f9f-bfd7-6730ba98a51b"

  """
  @spec encode(raw) :: t
  def encode(
        <<a1::4, a2::4, a3::4, a4::4, a5::4, a6::4, a7::4, a8::4, b1::4, b2::4, b3::4, b4::4,
          c1::4, c2::4, c3::4, c4::4, d1::4, d2::4, d3::4, d4::4, e1::4, e2::4, e3::4, e4::4,
          e5::4, e6::4, e7::4, e8::4, e9::4, e10::4, e11::4, e12::4>>
      ) do
    <<e(a1), e(a2), e(a3), e(a4), e(a5), e(a6), e(a7), e(a8), ?-, e(b1), e(b2), e(b3), e(b4), ?-,
      e(c1), e(c2), e(c3), e(c4), ?-, e(d1), e(d2), e(d3), e(d4), ?-, e(e1), e(e2), e(e3), e(e4),
      e(e5), e(e6), e(e7), e(e8), e(e9), e(e10), e(e11), e(e12)>>
  end

  @compile {:inline, e: 1}

  defp e(0), do: ?0
  defp e(1), do: ?1
  defp e(2), do: ?2
  defp e(3), do: ?3
  defp e(4), do: ?4
  defp e(5), do: ?5
  defp e(6), do: ?6
  defp e(7), do: ?7
  defp e(8), do: ?8
  defp e(9), do: ?9
  defp e(10), do: ?a
  defp e(11), do: ?b
  defp e(12), do: ?c
  defp e(13), do: ?d
  defp e(14), do: ?e
  defp e(15), do: ?f

  @doc """
  Decode a string representation of a UUID to the raw binary version.

  ## Example

      iex> UUUIDv7.decode("018e90d8-06e8-7f9f-bfd7-6730ba98a51b")
      <<1, 142, 144, 216, 6, 232, 127, 159, 191, 215, 103, 48, 186, 152, 165, 27>>

  """
  @spec decode(t) :: raw | :error
  def decode(
        <<a1, a2, a3, a4, a5, a6, a7, a8, ?-, b1, b2, b3, b4, ?-, c1, c2, c3, c4, ?-, d1, d2, d3,
          d4, ?-, e1, e2, e3, e4, e5, e6, e7, e8, e9, e10, e11, e12>>
      ) do
    <<d(a1)::4, d(a2)::4, d(a3)::4, d(a4)::4, d(a5)::4, d(a6)::4, d(a7)::4, d(a8)::4, d(b1)::4,
      d(b2)::4, d(b3)::4, d(b4)::4, d(c1)::4, d(c2)::4, d(c3)::4, d(c4)::4, d(d1)::4, d(d2)::4,
      d(d3)::4, d(d4)::4, d(e1)::4, d(e2)::4, d(e3)::4, d(e4)::4, d(e5)::4, d(e6)::4, d(e7)::4,
      d(e8)::4, d(e9)::4, d(e10)::4, d(e11)::4, d(e12)::4>>
  catch
    :error -> :error
  end

  def decode(_), do: :error

  @compile {:inline, d: 1}

  defp d(?0), do: 0
  defp d(?1), do: 1
  defp d(?2), do: 2
  defp d(?3), do: 3
  defp d(?4), do: 4
  defp d(?5), do: 5
  defp d(?6), do: 6
  defp d(?7), do: 7
  defp d(?8), do: 8
  defp d(?9), do: 9
  defp d(?A), do: 10
  defp d(?B), do: 11
  defp d(?C), do: 12
  defp d(?D), do: 13
  defp d(?E), do: 14
  defp d(?F), do: 15
  defp d(?a), do: 10
  defp d(?b), do: 11
  defp d(?c), do: 12
  defp d(?d), do: 13
  defp d(?e), do: 14
  defp d(?f), do: 15
  defp d(_), do: throw(:error)
end