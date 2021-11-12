defmodule PolarisIcon do
  @moduledoc """
  Documentation for `PolarisIcon`.
  """

  @icon_dir "svg/"
  @default_attrs [xmlns: "http://www.w3.org/2000/svg", viewBox: "0 0 20 20", fill: "currentColor"]
  @before_compile PolarisIcon.IconGenerator
end
