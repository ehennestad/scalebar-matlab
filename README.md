# scalebar

[![Version Number](https://img.shields.io/github/v/release/ehennestad/scalebar-matlab?label=version)](https://github.com/ehennestad/scalebar-matlab/releases/latest)
[![View scalebar on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://se.mathworks.com/matlabcentral/fileexchange/109114-scalebar-for-images-and-plots)
[![MATLAB Tests](.github/badges/tests.svg)](https://github.com/ehennestad/scalebar-matlab/actions/workflows/test-code.yml)
[![codecov](https://codecov.io/gh/ehennestad/scalebar-matlab/graph/badge.svg?token=ODXEKDNYFG)](https://codecov.io/gh/ehennestad/scalebar-matlab)
[![MATLAB Code Issues](.github/badges/code_issues.svg)](https://github.com/ehennestad/scalebar-matlab/security/code-scanning)
[![Run Codespell](https://github.com/ehennestad/scalebar-matlab/actions/workflows/run-codespell.yml/badge.svg)](https://github.com/ehennestad/scalebar-matlab/actions/workflows/run-codespell.yml)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://gitHub.com/ehennestad/scalebar-matlab/graphs/commit-activity)

`scalebar` adds configurable horizontal and vertical scale bars to MATLAB axes. It is intended for calibrated images and plots whose axes have meaningful units. Scale bars update when axes limits or size change, and can be configured through properties or their context menu.

## Requirements

MATLAB R2019b or later.

The image example additionally requires Image Processing Toolbox for MATLAB's
`cell.tif` sample image and contrast processing. The `scalebar` class and plot
example have no toolbox dependency.

## Installation

The recommended installation route is through MATLAB File Exchange:

1. Open the [scalebar File Exchange page](https://se.mathworks.com/matlabcentral/fileexchange/109114-scalebar-for-images-and-plots).
2. Select **Download** and then **Install** in MATLAB. This installs the toolbox as an add-on and manages the MATLAB path for you.

You can also search for **scalebar** in MATLAB's Add-On Explorer. For manual installation, download a `.mltbx` file from the [latest release](https://github.com/ehennestad/scalebar-matlab/releases/latest) and open it in MATLAB.

## Quick start

Create an image and add a horizontal scale bar in the lower-right corner:

```matlab
figure(Color="k")
imagesc(peaks(256))
axis image off
colormap turbo

scalebar(50, "pixels", ...
    Location="southeast", ...
    Color="w", ...
    LineWidth=2)
```

## Examples

### Calibrated image

The [complete image example](src/examples/createImageExample.m) creates the
following pseudocoloured microscopy image and adds a 25 µm scale bar. From the
repository root, run it with:

```matlab
addpath("src/examples")
createImageExample
```

![Pseudocoloured microscopy image with a 25 µm scale bar](docs/images/scalebar-image-example.png)

### Plot data

The [complete plot example](src/examples/createPlotExample.m) simulates a
membrane-potential trace and adds horizontal and vertical scale bars. From the
repository root, run it with:

```matlab
addpath("src/examples")
createPlotExample
```

![Membrane-potential trace with 500 ms and 50 mV scale bars](docs/images/scalebar-plot-example.png)

To regenerate the README images after changing either example, run
[`generateReadmeImages`](tools/generateReadmeImages.m) from the repository
root:

```matlab
addpath("tools")
generateReadmeImages
```

## Usage

```matlab
hScalebar = scalebar()
hScalebar = scalebar(scalebarLength)
hScalebar = scalebar(scalebarLength, unitLabel)
hScalebar = scalebar(hAxes, ___)
hScalebar = scalebar(___, Name=Value)
```

- `hAxes` is the target axes. If omitted, the current axes is used.
- `scalebarLength` is the physical length to display. If omitted, an appropriate length is calculated from the axes limits.
- `unitLabel` is the text appended to the displayed length. Use `'um'` for a micrometre label.
- `Axis="x"` creates a horizontal bar; `Axis="y"` creates a vertical bar.

The constructor accepts character vectors and string scalars. It returns a handle object, so appearance can be changed after creation:

```matlab
hScalebar = scalebar(10, "mm", Location="northwest");
hScalebar.Color = "w";
hScalebar.Location = "northwest";
```

### Name-value options

| Option | Description |
| --- | --- |
| `Axis` | Scale-bar orientation: `"x"` or `"y"`. |
| `ConversionFactor` | Number of data units per scale-bar unit. For example, use `2` when two pixels represent one micrometre. |
| `Location` | One of `northeast`, `northwest`, `southeast`, or `southwest`, optionally suffixed with `outside`. |
| `Color`, `LineWidth` | Line and text appearance. |
| `FontName`, `FontSize`, `FontWeight` | Text appearance. |
| `Margin`, `TextSpacing` | Pixel offsets from the axes corner and scale bar. |
| `AutoAdjustScalebarLength`, `AutoScalebarLength` | Automatically select a scale-bar length as a percentage of the relevant axes range. |
| `Visible` | Show or hide the scale bar using `'on'` or `'off'`. |

Right-click a scale bar to change its color, line width, font, location, and automatic-length setting interactively.

## Contributing

See the [contributing guidelines](.github/CONTRIBUTING.md).

## License

A license has not yet been selected for this project.

## Author

Eivind Hennestad
