# ThesisUtils

This package controls the appearance of the plots in my thesis.

## `autofig(plotfunc, name, size)`

The function `autofig` wraps your plot command with the appropriate machinery to set the fonts, appearance and figure size appropriately.
You provide it with a function that returns a plot, a name, and the desired size of the figure.
The size can be any one of `Margin`, `Normal` or `Full`.
`autofig` makes the plot, displays it, and also saves it as a pdf under the directory `autofigs/`.

## `placeholder()`

There is also a `placeholder` function that makes a placeholder plot, which you can use by calling `placeholder()`.

[![Build Status](https://travis-ci.org/swt30/ThesisUtils.jl.svg?branch=master)](https://travis-ci.org/swt30/ThesisUtils.jl)

[![Coverage Status](https://coveralls.io/repos/swt30/ThesisUtils.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/swt30/ThesisUtils.jl?branch=master)

[![codecov.io](http://codecov.io/github/swt30/ThesisUtils.jl/coverage.svg?branch=master)](http://codecov.io/github/swt30/ThesisUtils.jl?branch=master)
