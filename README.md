# scalebar

[![Version Number](https://img.shields.io/github/v/release/ehennestad/scalebar-matlab?label=version)](https://github.com/ehennestad/scalebar-matlab/releases/latest)
[![View scalebar on File Exchange](https://www.mathworks.com/matlabcentral/images/matlab-file-exchange.svg)](https://se.mathworks.com/matlabcentral/fileexchange/109114-scalebar-for-images-and-plots)
[![MATLAB Tests](.github/badges/tests.svg)](https://github.com/ehennestad/scalebar-matlab/actions/workflows/test-code.yml)
[![codecov](https://codecov.io/gh/ehennestad/scalebar-matlab/graph/badge.svg?token=ODXEKDNYFG)](https://codecov.io/gh/ehennestad/scalebar-matlab)
[![MATLAB Code Issues](.github/badges/code_issues.svg)](https://github.com/ehennestad/scalebar-matlab/security/code-scanning)
[![Run Codespell](https://github.com/ehennestad/scalebar-matlab/actions/workflows/run-codespell.yml/badge.svg)](https://github.com/ehennestad/scalebar-matlab/actions/workflows/run-codespell.yml)
[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://gitHub.com/ehennestad/scalebar-matlab/graphs/commit-activity)

`scalebar` adds a configurable horizontal or vertical scale bar to an axes. It is intended for image data and plots whose axes have meaningful spatial units. The scale bar updates when the axes limits or size change, and can be configured through properties or its context menu.

## Requirements

MATLAB R2019b or later.

## Installation

The recommended installation route is through MATLAB File Exchange:

1. Open the [scalebar File Exchange page](https://se.mathworks.com/matlabcentral/fileexchange/109114-scalebar-for-images-and-plots).
2. Select **Download** and then **Install** in MATLAB. This installs the toolbox as an add-on and manages the MATLAB path for you.

You can also search for **scalebar** in MATLAB's Add-On Explorer. For manual installation, download a `.mltbx` file from the [latest release](https://github.com/ehennestad/scalebar-matlab/releases/latest) and open it in MATLAB.

## Quick start

Create an image and add a scale bar in the lower-right corner:

```matlab
imageData = peaks(256);

figure
imagesc(imageData)
axis image off
colormap parula

scalebar('x', 50, 'pixels', ...
    'Location', 'southeast', ...
    'Color', 'w', ...
    'LineWidth', 2);
```

The MATLAB sample image can be used in the same way:

```matlab
imageData = imread('cameraman.tif');

figure
imagesc(imageData)
axis image off
colormap gray

scalebar('x', 50, 'pixels', ...
    'Location', 'southeast', ...
    'Color', 'w', ...
    'LineWidth', 2);
```

For calibrated image data, specify the physical scale-bar length and the number of data units per physical unit:

```matlab
pixelsPerMicrometer = 2;

scalebar('x', 25, 'um', ...
    'ConversionFactor', pixelsPerMicrometer, ...
    'Location', 'southeastoutside', ...
    'Color', 'w');
```

## Constructor

```matlab
hScalebar = scalebar()
hScalebar = scalebar(axis, scalebarLength, unitLabel, Name, Value)
hScalebar = scalebar(hAxes, axis, scalebarLength, unitLabel, Name, Value)
```

- `hAxes` is the target axes. If omitted, the current axes is used.
- `axis` is `'x'` or `'y'`; the default is `'x'`.
- `scalebarLength` is the physical length to display. If omitted, an appropriate length is calculated from the axes limits.
- `unitLabel` is the text appended to the displayed length. Use `'um'` for a micrometre label.

The constructor accepts character vectors and string scalars. It returns a handle object, so appearance can be changed after creation:

```matlab
hScalebar = scalebar('x', 10, 'mm');
hScalebar.Color = 'w';
hScalebar.Location = "northwest";
```

### Name-value options

| Option | Description |
| --- | --- |
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
