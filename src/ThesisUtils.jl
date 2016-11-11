module ThesisUtils

import Plots: pyplot, default, plot, annotate!, font, with, png, svg

export Margin, Normal, Full
export autofig, placeholder

## Page layout settings
# To describe the extent of a figure we define these terms
@enum PlotSize Margin Normal Full
const plotsizes = (Margin, Normal, Full)
"Indicates that a figure spans the tufte-latex margin"
Margin
"Indicates that a figure spans the tufte-latex body area"
Normal
"Indicates that a figure spans the whole page"
Full

# DPI settings
const dpi_default = 100
const dpi_print = 300
const dpi_scale = 170

"Default plot aspect ratios"
const aspectratio = Dict(
  Margin => 1,
  Normal => 1.5,
  Full => 1.6 )

"Widths of the margin, body text, and full page in inches"
const width_in = Dict(
  Margin => 2,
  Normal => 4 + 3//16,
  Full => 6 + 1//2 )

"Sizes of figures in pixels"
const figsize = let
  pixelsizes = map(plotsizes) do s
    base_aspect = [1, 1/aspectratio[s]]
    dpi_scaled = base_aspect * dpi_print
    width_scaled = dpi_scaled * width_in[s]
    whole_numbers = round(Int, width_scaled)
  end

  Dict(zip(plotsizes, pixelsizes))
end

## Plot display options
# Font settings
const main_font = font("fbb", 10)
const caption_font = font("fbb", 8)
const main_font_opts = Dict(
  :tickfont => main_font,
  :legendfont => main_font,
  :guidefont => main_font,
  :titlefont => main_font )
const caption_font_opts = Dict(
  :tickfont => caption_font,
  :legendfont => caption_font,
  :guidefont => caption_font,
  :titlefont => caption_font )

# Plot appearance
const plotopts = Dict(
  :linewidth => 1.5,
  :grid => false,
  :dpi => dpi_scale )
pyplot(;plotopts...)

# Folder to save generated figures to
const figdir = "autofigs"

""" Make a plot to go in the thesis and save it as a pdf

    plotfunc: The plotting function; should return a Plot object
    name: The file name to save the figure as
    s::PlotSize: One of `Margin`, `Normal` or `Full`. Indicates what size
                 the figure should be saved as

    vscale [optional, default=1]: Scale the plot to create more or less
                                  vertical space
    png [optional, default=1]: Save the plot as a png instead of a pdf """
function autofig(plotfunc, name, s::PlotSize; vscale=1, savepng=false)
  # get the figure size and font size
  width = figsize[s][1]
  height = figsize[s][2] * vscale
  if s == Margin
    default(;caption_font_opts...)
  else
    default(;main_font_opts...)
  end

  # plot the figure and save it to file
  with(size=(width,height)) do
    p = plotfunc()
    figpath = joinpath(figdir, name)
    if savepng
      png(figpath)
    else
      svg(figpath)
      # bit of a workaround because the font doesn't embed
      run(`rsvg-convert -f pdf -o $figpath.pdf $figpath.svg`)
      rm("$figpath.svg")
    end
    p
  end
end

"Make a default plot"
function placeholder()
  plot([sin, cos], linspace(0, 2π), labels=["sin(x)" "cos(x)"],
    xlabel="This is the x-axis",
    ylabel="This is the y-axis",
    title="Placeholder plot")
end

end # module ThesisUtils
