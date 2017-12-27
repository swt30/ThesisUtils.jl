module ThesisUtils

import Plots
import PlotUtils
import ColorTypes
import PyCall
  PyCall.@pyimport gc as pygc

export Margin, Normal, Full
export autofig, placeholder, annotate_color!, seqcolors,
       remove_ticklabels!

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
    whole_numbers = round.(Int, width_scaled)
  end

  Dict(zip(plotsizes, pixelsizes))
end

## Plot display options
# Font settings
const fontstyle = "fbb"
const fontsize = Dict(
  Margin => 8,
  Normal => 10,
  Full => 10 )
const font = Dict((s, Plots.font(fontstyle, fontsize[s])) for s in plotsizes)
const main_font_opts = Dict(
  :tickfont => font[Normal],
  :legendfont => font[Normal],
  :guidefont => font[Normal],
  :titlefont => font[Normal] )
const caption_font_opts = Dict(
  :tickfont => font[Margin],
  :legendfont => font[Margin],
  :guidefont => font[Margin],
  :titlefont => font[Margin] )

# Plot appearance
const plotopts = Dict(
  :linewidth => 1.5,
  :grid => false,
  :dpi => dpi_scale )
Plots.pyplot(;plotopts...)

# Folder to save generated figures to
const figdir = "autofigs"

""" Make a plot to go in the thesis and save it

    plotfunc: The plotting function; should return a Plot object
    name: The file name to save the figure as
    s::PlotSize: One of `Margin`, `Normal` or `Full`. Indicates what size
                 the figure should be saved as

    vscale [optional, default=1]: Scale the plot to create more or less
                                  vertical space
    png [optional, default=1]: Save the plot as a png instead of a pdf """
function autofig(plotfunc, name, s::PlotSize; vscale=1, savepng=false)
  # workaround for python not closing files properly
  pygc.collect()

  # get the figure size and font size
  width = figsize[s][1]
  height = figsize[s][2] * vscale
  if s == Margin
    Plots.default(;caption_font_opts...)
  else
    Plots.default(;main_font_opts...)
  end
  if s == Full
    name *= "_big_fig"
  end

  # plot the figure and save it to file
  Plots.with(size=(width,height)) do
    p = plotfunc()
    figpath = joinpath(figdir, name)
    if savepng
      Plots.png(figpath)
    else
      Plots.svg(figpath)
      # bit of a workaround because the font doesn't embed
      run(`rsvg-convert -f pdf -o $figpath.pdf $figpath.svg`)
      rm("$figpath.svg")
    end
    p
  end
end

"Make a default plot"
function placeholder()
  Plots.plot([sin, cos], linspace(0, 2π), labels=["sin(x)" "cos(x)"],
    xlabel="This is the x-axis",
    ylabel="This is the y-axis",
    title="Placeholder plot")
end

const PlotType = Union{Plots.Plot, Plots.Subplot}

"Annotate a plot with a colored label"
function annotate_color!(x, y, text, color;
                         position=:left, plotsize=Normal, rotation=0)
  basefont = font[plotsize]
  rot = deg2rad(rotation)
  formatted_font = Plots.font(basefont, color, position, rot)
  formatted_text = Plots.text(text, formatted_font)
  Plots.annotate!(x, y, formatted_text)
end
function annotate_color!(p::PlotType, x, y, text, color;
                         position=:left, plotsize=Normal, rotation=0)
  basefont = font[plotsize]
  rot = deg2rad(rotation)
  formatted_font = Plots.font(basefont, color, position, rot)
  formatted_text = Plots.text(text, formatted_font)
  Plots.annotate!(p, x, y, formatted_text)
end

"Remove the tick labels from a plot but leave the ticks and grid"
function remove_ticklabels!(p::PlotType; x=true, y=true)
  x && Plots.plot!(p; xformatter=_->"")
  y && Plots.plot!(p; yformatter=_->"")
  p
end

"Provide a palette of colors drawn sequentially from a color gradient"
function seqcolors(name, N, start=0, stop=1)
  grad = PlotUtils.cgrad(name)
  colors = ColorTypes.RGBA{Float64}[grad[n] for n in linspace(start, stop, N)]
end

end # module ThesisUtils
