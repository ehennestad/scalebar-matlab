%SCALEBAR Add a scale bar to axes.
%
%   hScalebar = scalebar() adds an automatically sized horizontal scale bar
%   to the current axes.
%
%   hScalebar = scalebar(scalebarLength) sets the physical scale-bar length.
%   hScalebar = scalebar(scalebarLength, unitLabel) also sets the label
%   appended to the length.
%
%   hScalebar = scalebar(hAxes, ___) adds the scale bar to hAxes instead of
%   the current axes.
%
%   hScalebar = scalebar(___, Name=Value) configures public properties using
%   one or more name-value arguments. For example, use Axis="y" to create a
%   vertical scale bar.
%
%   The legacy positional axis syntax, scalebar(axis, ___), is also accepted.
%
%   Public Properties:
%       Parent                       - Target axes.
%       Axis                         - Scale-bar orientation: "x" or "y".
%       ScalebarLength               - Physical length; NaN selects an
%                                      automatic length.
%       UnitLabel                    - Text appended to the displayed length.
%       ConversionFactor             - Data units per scale-bar unit.
%       AutoAdjustScalebarLength     - Automatically update the length when
%                                      axes limits change.
%       AutoScalebarLength           - Automatic length as a percentage of
%                                      the relevant axes range.
%       Location                     - Axes corner for the scale bar; append
%                                      "outside" to place it beyond the axes.
%       Color                        - Line and text color.
%       LineWidth                    - Scale-bar line width.
%       TextSpacing                  - Pixel gap between the line and label.
%       FontName                     - Label font name.
%       FontSize                     - Label font size.
%       FontWeight                   - Label font weight: "normal" or "bold".
%       Margin                       - Two-element pixel offset from the
%                                      selected axes corner.
%       ShowBackground               - Show a semi-transparent background.
%       BackgroundColor              - Background patch color.
%       BackgroundAlpha              - Background opacity from 0 to 1.
%       BackgroundPadding            - Pixel padding around the scale bar.
%       Visible                      - Visibility state: "on" or "off".
%
%   Example:
%     hAxes = axes();
%
%     hScalebar = scalebar(hAxes, 10, "um", ...
%         ConversionFactor=5, Location="southeastoutside", Color="w");

% Todo:
%   [ ] Position + units property?
%   [ ] Autogenerate code - given some settings, create snippet for
%       recreating scalebar

classdef scalebar < handle
%SCALEBAR Add scalebar to axes

    properties
        % Axis - Orientation of the scale bar: 'x' or 'y'.
        Axis (1,:) char {mustBeMember(Axis, {'x', 'y'})} = 'x'

        % ScalebarLength - Physical length, or NaN for automatic sizing.
        ScalebarLength (1,1) double = nan

        % UnitLabel - Text appended to the displayed scale-bar length.
        UnitLabel (1,1) string = ""

        % ConversionFactor - Number of data units per scale-bar unit.
        ConversionFactor (1,1) double = 1

        % AutoAdjustScalebarLength - Update the automatic length with axes limits.
        AutoAdjustScalebarLength (1,1) logical = false;

        % AutoScalebarLength - Automatic length as a percentage of the axes range.
        AutoScalebarLength (1,1) double = 20;

        % Location - Axes corner for the scale bar, optionally suffixed by 'outside'.
        Location (1,1) string {mustBeMember(Location, ...
            [ ...
            "southeast", ...
            "southwest", ...
            "northeast", ...
            "northwest", ...
            "southeastoutside", ...
            "southwestoutside", ...
            "northeastoutside", ...
            "northwestoutside"] ...
            ) ...
        } = 'southeast'

        % Color - Color specification for the scale-bar line and text.
        Color = 'k'

        % LineWidth - Width of the scale-bar line.
        LineWidth (1,1) double {mustBeNonnegative} = 1

        % TextSpacing - Pixel gap between the scale-bar line and label.
        TextSpacing (1,1) double {mustBeNonnegative} = 2;

        % FontName - Font used for the scale-bar label.
        FontName = 'Helvetica Neue';

        % FontSize - Font size of the scale-bar label.
        FontSize = 10;

        % FontWeight - Font weight of the scale-bar label.
        FontWeight = 'normal'

        % Margin - Horizontal and vertical pixel offsets from the axes corner.
        Margin = [10, 10]

        % ShowBackground - Whether to show a patch behind the scale bar.
        ShowBackground (1,1) logical = false

        % BackgroundColor - Color of the background patch.
        BackgroundColor = [0.5 0.5 0.5]

        % BackgroundAlpha - Opacity of the background patch from 0 to 1.
        BackgroundAlpha (1,1) double {mustBeFinite, ...
            mustBeGreaterThanOrEqual(BackgroundAlpha, 0), ...
            mustBeLessThanOrEqual(BackgroundAlpha, 1)} = 0.3

        % BackgroundPadding - Pixel padding around the line and label.
        BackgroundPadding (1,1) double {mustBeFinite, mustBeNonnegative} = 3
    end

    properties (Dependent)
        % Parent - Axes containing the scale bar.
        Parent
        % Visible - Visibility state of the scale bar.
        Visible matlab.lang.OnOffSwitchState
    end

    properties (Access = private)
        hAxes               % Handle for the axes
        hScalebarLine       % Handle for the scale bar's line
        hScalebarText       % Handle for the scale bar's text label
        hScalebarBackground % Handle for the semi-transparent background patch
        ContextMenu         % Handle for scale bar's context menu
        VisibleState matlab.lang.OnOffSwitchState = 'on'

        IsConstructed = false

        MarginNorm          % Margins in normalized units
        ScalebarLengthDu    % Length of scalebar in data units
        AxesSizePixels      % Size of axes in pixels
    end

    properties (Access = private)
        SizeChangedListener event.listener
        LimitsChangedListener event.listener
    end

    properties (Constant, Hidden)
        STYLE_PROPS = {'FontSize', 'FontWeight', 'LineWidth', ...
            'Color', 'Location', 'FontName', 'ShowBackground', ...
            'BackgroundColor', 'BackgroundAlpha', 'BackgroundPadding'};
        CONFIGURABLE_PROPS = {'Axis', 'ScalebarLength', 'UnitLabel', ...
            'ConversionFactor', 'AutoAdjustScalebarLength', ...
            'AutoScalebarLength', 'Location', 'Color', 'LineWidth', ...
            'TextSpacing', 'FontName', 'FontSize', 'FontWeight', ...
            'Margin', 'ShowBackground', 'BackgroundColor', ...
            'BackgroundAlpha', 'BackgroundPadding', 'Visible'};
    end

    methods % Constructor/destructor

        function obj = scalebar(varargin, propValues)
        %SCALEBAR Construct an instance of this class
        %
        %   hScalebar = scalebar() creates a scalebar in the current axes
        %
        %   hScalebar = scalebar(axis) creates a scalebar on the specified
        %   axis. Axis can be 'x' or 'y'. Default is 'x'.

            arguments (Repeating)
                varargin
            end
            arguments
                propValues.?scalebar
            end

            [hParent, positionalPairs, ~] = parseConstructorInputs(varargin{:});
            hasPositionalParent = ~isempty(varargin) && ...
                isa(varargin{1}, 'matlab.graphics.axis.Axes');
            if hasPositionalParent && isfield(propValues, 'Parent')
                error('scalebar:DuplicateParent', ...
                    'Specify the parent axes either positionally or as Parent, not both.')
            end
            obj.Parent = hParent;

            % Apply positional values before style preferences. This keeps the
            % historical positional constructor forms while validating every
            % value through its property setter.
            obj.assignPVPairs(positionalPairs{:})

            % Set default style properties from preferences
            preferencePairs = prefs2props();
            obj.assignPVPairs(preferencePairs{:})

            nvPairs = namedargs2cell(propValues);
            obj.assignPVPairs(nvPairs{:})

            % % Start creating scalebar
            isHoldOn = ishold(obj.hAxes);
            hold(obj.hAxes, 'on')

            if isnan(obj.ScalebarLength)
                obj.autoAdjustScalebarLength()
            end

            % Configure placement
            updateAxesSizePixel(obj)
            assignScalebarLength(obj)
            calculateMarginDataUnits(obj)

            % Plot scalebar
            obj.plotScalebar()
            obj.plotTextLabel()
            obj.plotBackground()

            % Create contextmenu
            obj.createContextMenu()
            obj.createListeners()

            obj.IsConstructed = true;
            obj.refreshAutoScalebarLength()
            obj.Visible = obj.VisibleState;

            if ~isHoldOn
                hold(obj.hAxes, 'off')
            end
        end

        function delete(obj)
        %delete Delete components of scalebar

            obj.deleteListeners()
            delete(obj.ContextMenu)
            delete(obj.hScalebarLine)
            delete(obj.hScalebarText)
            if obj.hasBackground()
                delete(obj.hScalebarBackground)
            end
        end
    end

    methods % Set/get
        function set.Parent(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) matlab.graphics.axis.Axes
            end
            obj.validateAxes(newValue)
            obj.hAxes = newValue;

            obj.onParentChanged()
        end
        function hParent = get.Parent(obj)
            hParent = obj.hAxes;
        end

        function set.Visible(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) matlab.lang.OnOffSwitchState
            end
            obj.VisibleState = newValue;
            if obj.IsConstructed
                obj.hScalebarLine.Visible = newValue;
                obj.hScalebarText.Visible = newValue;
                if obj.hasBackground()
                    obj.hScalebarBackground.Visible = newValue;
                end
            end
        end
        function visible = get.Visible(obj)
            visible = obj.VisibleState;
        end

        function set.Axis(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) string {mustBeMember(newValue, ["x", "y"])}
            end
            obj.Axis = char(newValue);
            obj.updatePosition()
        end

        function set.Color(obj, newColor)
            obj.onColorSet(newColor)
            % Only set prop value if above does not fail
            obj.Color = newColor;
        end

        function set.UnitLabel(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) string
            end
            obj.UnitLabel = char(newValue);
            obj.updateTextLabel()
        end

        function set.ConversionFactor(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) double {mustBeFinite, mustBePositive}
            end
            obj.ConversionFactor = newValue;
            obj.updateScalebar()
            % obj.updateTextLabel()
            obj.updateTextPosition()
        end

        function set.ScalebarLength(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) double {mustBeValidScalebarLength}
            end
            obj.ScalebarLength = newValue;
            % obj.updateScalebar()
            obj.updateTextLabel()
            obj.updatePosition();
        end

        function set.LineWidth(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) double {mustBeFinite, mustBePositive}
            end
            obj.onLinewidthChanged(newValue)
            % Only set prop value if above does not fail
            obj.LineWidth = newValue;
            obj.updateTextPosition()
            obj.updateBackground()
            obj.updateContextMenu('Line Width')
            obj.updateBackground();
        end

        function set.FontName(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) string {mustBeNonzeroLengthText}
            end
            obj.onFontNameChanged(newValue)
            % Only set prop value if above does not fail
            obj.FontName = char(newValue);
            obj.updateBackground()
        end

        function set.FontSize(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) double {mustBeFinite, mustBePositive}
            end
            obj.onFontSizeChanged(newValue)
            % Only set prop value if above does not fail
            obj.FontSize = newValue;
            obj.updateBackground()
            obj.updateContextMenu('Font Size')
        end

        function set.FontWeight(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) string {mustBeMember(newValue, ["normal", "bold"])}
            end
             obj.onFontWeightChanged(newValue)
            % Only set prop value if above does not fail
            obj.FontWeight = char(newValue);
            obj.updateBackground()
        end

        function set.Location(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) string {mustBeValidLocation}
            end
            obj.Location = char(newValue);
            obj.updatePosition()
            obj.updateContextMenu('Location')
        end

        function set.Margin(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,2) double {mustBeFinite, mustBeNonnegative}
            end
            obj.Margin = newValue;
            obj.updatePosition()
        end

        function set.TextSpacing(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) double {mustBeFinite, mustBeNonnegative}
            end
            obj.TextSpacing = newValue;
            obj.updateTextPosition()
            obj.updateBackground()
        end

        function set.AutoAdjustScalebarLength(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) logical
            end
            obj.AutoAdjustScalebarLength = newValue;
            obj.refreshAutoScalebarLength()
        end

        function set.AutoScalebarLength(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) double {mustBeFinite, mustBePositive}
            end
            obj.AutoScalebarLength = newValue;
            obj.refreshAutoScalebarLength()
        end

        function set.ShowBackground(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) logical
            end
            obj.ShowBackground = newValue;
            obj.updateBackground()
            obj.updateContextMenu('Show Background')
        end

        function set.BackgroundColor(obj, newValue)
            obj.onBackgroundColorChanged(newValue)
            obj.BackgroundColor = newValue;
        end

        function set.BackgroundAlpha(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) double {mustBeFinite, ...
                    mustBeGreaterThanOrEqual(newValue, 0), ...
                    mustBeLessThanOrEqual(newValue, 1)}
            end
            obj.onBackgroundAlphaChanged(newValue)
            obj.BackgroundAlpha = newValue;
            obj.updateContextMenu('Background Opacity')
        end

        function set.BackgroundPadding(obj, newValue)
            arguments
                obj (1,1) scalebar
                newValue (1,1) double {mustBeFinite, mustBeNonnegative}
            end
            obj.BackgroundPadding = newValue;
            obj.updateBackground()
        end
    end

    methods (Access = private) % Config & creation

        function assignScalebarLength(obj)

            n = obj.ScalebarLength;

            switch obj.Axis
                case 'x'
                    obj.ScalebarLengthDu = [n * obj.ConversionFactor, 0];
                case 'y'
                    obj.ScalebarLengthDu = [0, n * obj.ConversionFactor];
            end
        end

        function [xSign, ySign] = configurePositionDirection(obj)

            xSign = 1;
            ySign = 1;

            % Factor which moves coordinates outside of axes...
            if contains(obj.Location, 'outside')
                switch obj.Axis
                    case 'x'
                        ySign = -1;
                    case 'y'
                        xSign = -1;
                end
            end
        end

        function calculateMarginDataUnits(obj)
            % Convert pixel margin to x and y margin
            % NB: requires plotboxpos function from fileexchange and assumes axes
            % units are normalized and figure units are pixels....
            obj.updateAxesSizePixel()
            obj.MarginNorm = obj.Margin ./ obj.AxesSizePixels;
        end

        function updateAxesSizePixel(obj)

            if exist('plotboxpos', 'file') == 2
                axUnits = obj.hAxes.Units;
                set(obj.hAxes, 'Units', 'normalized')
                axpos = plotboxpos(obj.hAxes);
                set(obj.hAxes, 'Units', axUnits)

                figH = ancestor(obj.hAxes, 'figure');
                figPos = getpixelposition(figH);
                axPixSize = figPos(3:4) .* axpos(3:4);

            else
                axPixPos = getpixelposition(obj.hAxes);
                axPixSize = axPixPos(3:4);
            end

            obj.AxesSizePixels = axPixSize;
        end

        function xData = calculateXData(obj)    % Calculate x coordinates of line

            [xSign, ~] = configurePositionDirection(obj);

            xLim = obj.hAxes.XLim;
            xLimRange = max(xLim) - min(xLim);

            offsetDu = xLimRange * obj.MarginNorm(1) * xSign;

            isEast = contains(obj.Location, 'east');
            if strcmp(obj.hAxes.XDir, 'reverse')
                isEast = ~isEast;
            end

            if isEast
                xData = xLim(2) - offsetDu - [obj.ScalebarLengthDu(1), 0];
            else
                xData = xLim(1) + offsetDu + [0, obj.ScalebarLengthDu(1)];
            end

            xData = double(xData);
        end

        function yData = calculateYData(obj)

            yLim = obj.hAxes.YLim;
            yLimRange = max(yLim) - min(yLim);

            [~, ySign] = configurePositionDirection(obj);

            offsetDu = yLimRange * obj.MarginNorm(2) * ySign;

            % Calculate y coordinates of line
            if contains(obj.Location, 'north')
                yData = yLim(2) - offsetDu - [obj.ScalebarLengthDu(2), 0];
            elseif contains(obj.Location, 'south')
                yData = yLim(1) + offsetDu + [0, obj.ScalebarLengthDu(2)];
            end

            if strcmp(obj.hAxes.YDir, 'reverse')
                yData = yLim(1) - (yData - yLim(2));
            end

            yData = double(yData);
        end

        function txtPos = calculateTextPosition(obj)

            xData = calculateXData(obj) ;
            yData = calculateYData(obj) ;
            xLim = obj.hAxes.XLim;
            yLim = obj.hAxes.YLim;

            [~, ySign] = configurePositionDirection(obj);

            if strcmp(obj.hAxes.YDir, 'reverse')
                ySign = -ySign;
            end

            [~, vert] = getTextAlignment(obj);
            yOffset = obj.TextSpacing + obj.LineWidth/2;
            yOffset = (max(yLim)-min(yLim)) * (yOffset/obj.AxesSizePixels(2)) * ySign;

            if strcmp(vert, 'top')
                yOffset = -1 * yOffset;
            end

            if contains(obj.Location, 'outside')
                yOffset = -1 * yOffset;
            end

            % Calculate text coordinates and set alignment of text.
            switch obj.Axis
                case 'x'
                    txtPos = struct('x', xData(1)+diff(xData)/2, 'y', yData(1) + yOffset);
                case 'y'
                    xOffset = obj.TextSpacing + obj.LineWidth/2;
                    xOffset = (max(xLim)-min(xLim)) * ...
                        (xOffset/obj.AxesSizePixels(1));

                    % Rotated text uses its vertical alignment to select the
                    % visual side of a vertical scale bar. Apply the requested
                    % gap on that same side, accounting for reversed x axes.
                    if strcmp(vert, 'bottom')
                        xOffset = -xOffset;
                    end
                    if strcmp(obj.hAxes.XDir, 'reverse')
                        xOffset = -xOffset;
                    end

                    txtPos = struct( ...
                        'x', xData(1) + xOffset, ...
                        'y', yData(1)+diff(yData)/2);
            end

            if strcmp(obj.hAxes.YDir, 'reverse')
                % txtPos.y = yLim(2) - (txtPos.y - yLim(1));
            end
        end

        function textLabel = getTextLabel(obj) % todo: dependent?
        %getTextLabel Get formatted text label

        % Add text
            n = obj.ScalebarLength;

            if strcmp(obj.UnitLabel, 'um') % Special case..
                unitLabel = sprintf('%sm', '\mu'); % micrometer
            else
                unitLabel = obj.UnitLabel;
            end

            % Todo....
            if isequal(n, round(n))
                textLabel = sprintf('%d %s', n, unitLabel);
            else
                textLabel = sprintf('%.3f %s', n, unitLabel);
            end
        end

        function [horz, vert] = getTextAlignment(obj)
            horz = 'center';
            vert = 'bottom';

            switch obj.Axis
                case 'x'
                    if any(strcmp(obj.Location, { 'northeast', 'northwest', ...
                            'southeastoutside', 'southwestoutside' }))
                        vert = 'top';
                    end
                case 'y'
                    if any(strcmp(obj.Location, { 'southeastoutside', 'southwest', ...
                            'northeastoutside', 'northwest' }))
                        vert = 'top';
                    end
            end

            % Todo: X:  north: text under line. South: text over line
            % Todo: y:  west: text right of line. east: text left of line
            % Reverse when scalebar is outside of axes....
        end

        function plotScalebar(obj)

            xData = calculateXData(obj) ;
            yData = calculateYData(obj) ;

            % Plot scalebar. Use a primitive line (not plot/chart line):
            % primitives carry no DataTipTemplate, so clicking the scale
            % bar can not pin a data tip in the host axes. As a bonus, a
            % primitive line never clears existing axes content.
            obj.hScalebarLine = line(obj.hAxes, xData, yData);
            % obj.hScalebarLine.HandleVisibility = 'off';
            obj.hScalebarLine.Tag = 'Scalebar Line';
            excludeFromDataTips(obj.hScalebarLine)

            addlistener(obj.hScalebarLine, 'ObjectBeingDestroyed', ...
                @(s,e) obj.delete);

            % Make sure scalebar is not clipped.
            % if contains(obj.Location, 'outside')
                set(obj.hScalebarLine, 'Clipping', 'off')
                % set(obj.hAxes, 'Clipping', 'on')
            % end

            obj.hScalebarLine.Color = obj.Color;
            obj.hScalebarLine.LineWidth = obj.LineWidth;
        end

        function plotTextLabel(obj)

            % Add text

            txtPos = calculateTextPosition(obj);
            textLabel = getTextLabel(obj);
            [horz, vert] = getTextAlignment(obj);

            if isempty(obj.hScalebarText)
                obj.hScalebarText = text(obj.hAxes, txtPos.x, txtPos.y, ...
                    textLabel, 'Color', obj.Color, 'FontSize', ...
                    obj.FontSize, 'FontWeight', obj.FontWeight, ...
                    'FontName', obj.FontName);
                % obj.hScalebarText.HandleVisibility = 'off';
                obj.hScalebarText.Tag = 'Scalebar Text';
                excludeFromDataTips(obj.hScalebarText)
            else
                obj.hScalebarText.Position(1:2) = [txtPos.x, txtPos.y];
            end

            obj.hScalebarText.VerticalAlignment = vert;
            obj.hScalebarText.HorizontalAlignment = horz;

            if strcmp(obj.Axis, 'y')
                obj.hScalebarText.Rotation = 90;
            else
                obj.hScalebarText.Rotation = 0;
            end
        end

        function plotBackground(obj)
            if ~obj.ShowBackground
                if obj.hasBackground()
                    obj.hScalebarBackground.Visible = 'off';
                end
                return
            end

            [xData, yData] = obj.calculateBackgroundVertices();
            [xOffset, yOffset] = obj.calculateInsideBackgroundOffset(xData, yData);
            if xOffset ~= 0 || yOffset ~= 0
                obj.translateScalebar(xOffset, yOffset)
                [xData, yData] = obj.calculateBackgroundVertices();
            end

            if ~obj.hasBackground()
                obj.hScalebarBackground = patch(obj.hAxes, xData, yData, ...
                    obj.BackgroundColor, EdgeColor='none', ...
                    FaceAlpha=obj.BackgroundAlpha, ...
                    Clipping='off', PickableParts='visible', ...
                    Tag='Scalebar Background');
                if ~isempty(obj.ContextMenu)
                    obj.hScalebarBackground.ContextMenu = obj.ContextMenu;
                end
                % The patch must stay clickable (right-click context
                % menu), so data tips are excluded per object instead of
                % turning off HitTest.
                excludeFromDataTips(obj.hScalebarBackground)
                % Keep the patch beneath the scale bar, but above image data.
                uistack(obj.hScalebarBackground, 'down', 2)
            else
                obj.hScalebarBackground.XData = xData;
                obj.hScalebarBackground.YData = yData;
                obj.hScalebarBackground.FaceColor = obj.BackgroundColor;
                obj.hScalebarBackground.FaceAlpha = obj.BackgroundAlpha;
                obj.hScalebarBackground.Visible = obj.Visible;
            end
        end

        function [xData, yData] = calculateBackgroundVertices(obj)
            lineXData = obj.hScalebarLine.XData;
            lineYData = obj.hScalebarLine.YData;
            textExtent = obj.getTextExtentInDataUnits();

            xRange = diff(obj.hAxes.XLim);
            yRange = diff(obj.hAxes.YLim);
            xPadding = xRange * obj.BackgroundPadding / obj.AxesSizePixels(1);
            yPadding = yRange * obj.BackgroundPadding / obj.AxesSizePixels(2);
            xLineHalfWidth = xRange * obj.LineWidth / ...
                (2 * obj.AxesSizePixels(1));
            yLineHalfWidth = yRange * obj.LineWidth / ...
                (2 * obj.AxesSizePixels(2));

            xData = [ ...
                min([lineXData - xLineHalfWidth, textExtent(1)]) - xPadding, ...
                max([lineXData + xLineHalfWidth, textExtent(2)]) + xPadding, ...
                max([lineXData + xLineHalfWidth, textExtent(2)]) + xPadding, ...
                min([lineXData - xLineHalfWidth, textExtent(1)]) - xPadding];
            yData = [ ...
                min([lineYData - yLineHalfWidth, textExtent(3)]) - yPadding, ...
                min([lineYData - yLineHalfWidth, textExtent(3)]) - yPadding, ...
                max([lineYData + yLineHalfWidth, textExtent(4)]) + yPadding, ...
                max([lineYData + yLineHalfWidth, textExtent(4)]) + yPadding];
        end

        function [xOffset, yOffset] = calculateInsideBackgroundOffset( ...
                obj, xData, yData)
            xOffset = 0;
            yOffset = 0;
            if contains(obj.Location, 'outside')
                return
            end

            xLimits = sort(obj.hAxes.XLim);
            yLimits = sort(obj.hAxes.YLim);
            xOffset = calculateContainmentOffset(min(xData), max(xData), xLimits);
            yOffset = calculateContainmentOffset(min(yData), max(yData), yLimits);
        end

        function translateScalebar(obj, xOffset, yOffset)
            obj.hScalebarLine.XData = obj.hScalebarLine.XData + xOffset;
            obj.hScalebarLine.YData = obj.hScalebarLine.YData + yOffset;
            obj.hScalebarText.Position(1:2) = ...
                obj.hScalebarText.Position(1:2) + [xOffset, yOffset];
        end

        function extent = getTextExtentInDataUnits(obj)
            originalUnits = obj.hScalebarText.Units;
            obj.hScalebarText.Units = 'data';
            textExtent = obj.hScalebarText.Extent;
            obj.hScalebarText.Units = originalUnits;

            xEnd = textExtent(1) + textExtent(3);
            if strcmp(obj.hAxes.YDir, 'reverse')
                yEnd = textExtent(2) - textExtent(4);
            else
                yEnd = textExtent(2) + textExtent(4);
            end
            extent = [min(textExtent(1), xEnd), max(textExtent(1), xEnd), ...
                min(textExtent(2), yEnd), max(textExtent(2), yEnd)];
        end

        function createContextMenu(obj)

            checked = {'off', 'on'};

            hFigure = ancestor(obj.hAxes, 'figure');
            hMenu = uicontextmenu(hFigure);

            mItem = uimenu(hMenu, 'Text', 'Configure Scalebar...');
            mItem.Callback = @(s,e) obj.onConfigureScalebarClicked;

            mItem = uimenu(hMenu, 'Text', 'Autoadjust Scalebar');
            mItem.Checked = checked{ obj.AutoAdjustScalebarLength + 1 };
            mItem.Callback = @(s,e) obj.onAutoadjustScalebarClicked(s);

            mItem = uimenu(hMenu, 'Text', 'Set Color...', 'Separator', 'on');
            mItem.Callback = @(s,e) obj.onSetColorClicked;

            mItem = uimenu(hMenu, 'Text', 'Set Line Width');
            for i = 1:6
                mSubItem = uimenu(mItem, 'Text', num2str(i, '%d'));
                mSubItem.Checked = checked{ isequal(i, obj.LineWidth) + 1 };
                mSubItem.Callback = @(s,e) obj.onSetLineWidthClicked(i);
            end

            mItem = uimenu(hMenu, 'Text', 'Set Font Size');
            for i = 0:6
                mSubItem = uimenu(mItem, 'Text', num2str(i+10, '%d'));
                mSubItem.Checked = checked{ isequal(i+10, obj.FontSize) + 1 };
                mSubItem.Callback = @(s,e) obj.onSetFontSizeClicked(i+10);
            end

            mItem = uimenu(hMenu, 'Text', 'Set Font...');
            mItem.Callback = @(s,e) obj.onSetFontClicked;

            mItem = uimenu(hMenu, 'Text', 'Location');
            locations = {'southeast', 'southwest', 'northwest', 'northeast'};
            for i = 1:numel(locations)
                mSubItem = uimenu(mItem, 'Text', locations{i});
                mSubItem.Checked = checked{ strcmp(locations{i}, obj.Location) + 1 };
                mSubItem.Callback = @(s,e) obj.onSetLocationClicked(locations{i});
            end

            mItem = uimenu(hMenu, 'Text', 'Background', 'Separator', 'on');
            mSubItem = uimenu(mItem, 'Text', 'Show Background');
            mSubItem.Checked = checked{obj.ShowBackground + 1};
            mSubItem.Callback = @(s,e) obj.onToggleBackgroundClicked();

            mSubItem = uimenu(mItem, 'Text', 'Set Background Color...');
            mSubItem.Callback = @(s,e) obj.onSetBackgroundColorClicked();

            mSubItem = uimenu(mItem, 'Text', 'Background Opacity');
            for opacity = [20, 40, 60, 80, 100]
                mSubSubItem = uimenu(mSubItem, ...
                    'Text', sprintf('%d%%', opacity));
                alpha = opacity / 100;
                mSubSubItem.Checked = checked{(abs( ...
                    obj.BackgroundAlpha-alpha) < 0.01) + 1};
                mSubSubItem.Callback = @(s,e) obj.onSetBackgroundAlphaClicked(alpha);
            end

            mItem = uimenu(hMenu, 'Text', 'Save Current Style', 'Separator', 'on');
            mItem.Callback = @(s,e) props2prefs(obj);

            mItem = uimenu(hMenu, 'Text', 'Delete Scalebar', 'Separator', 'on');
            mItem.Callback = @(s,e) obj.delete;

            obj.hScalebarText.ContextMenu = hMenu;
            obj.hScalebarLine.ContextMenu = hMenu;
            if obj.hasBackground()
                obj.hScalebarBackground.ContextMenu = hMenu;
            end

            obj.ContextMenu = hMenu; % store in property
        end

        function updateContextMenu(obj, name, propName)

            if isempty(obj.ContextMenu); return; end

            if nargin < 3; propName = 'Checked'; end

            switch name
                case 'Line Width'
                    menuItem = findobj(obj.ContextMenu, 'Text', 'Set Line Width');
                    menuSubItem = menuItem.Children;
                    isMatched = strcmp({menuSubItem.Text}, num2str(obj.LineWidth, '%d'));

                case 'Font Size'
                    menuItem = findobj(obj.ContextMenu, 'Text', 'Set Font Size');
                    menuSubItem = menuItem.Children;
                    isMatched = strcmp({menuSubItem.Text}, num2str(obj.FontSize, '%d'));

                case 'Location'
                    menuItem = findobj(obj.ContextMenu, 'Text', 'Location');
                    menuSubItem = menuItem.Children;
                    isMatched = strcmp({menuSubItem.Text}, obj.Location);

                case 'Show Background'
                    menuItem = findobj(obj.ContextMenu, 'Text', 'Show Background');
                    if obj.ShowBackground
                        menuItem.Checked = 'on';
                    else
                        menuItem.Checked = 'off';
                    end
                    return

                case 'Background Opacity'
                    menuItem = findobj(obj.ContextMenu, 'Text', 'Background Opacity');
                    menuSubItem = menuItem.Children;
                    isMatched = cellfun(@(text) abs( ...
                        str2double(text(1:end-1))/100 - obj.BackgroundAlpha) < 0.01, ...
                        {menuSubItem.Text});
            end

            switch propName
                case 'Checked'
                    set(menuSubItem(~isMatched), 'Checked', 'off')
                    set(menuSubItem(isMatched), 'Checked', 'on')
            end
        end

        function createListeners(obj)

            obj.SizeChangedListener = listener(obj.hAxes, 'SizeChanged', ...
                @(s, e) obj.updatePosition);

            props = {'XLim', 'YLim'};
            obj.LimitsChangedListener = listener(obj.hAxes, props, ...
                'PostSet', @(s, e) obj.onAxesLimitsChanged);
        end

        function deleteListeners(obj)
            isdeletable = @(x) ~isempty(x) && isvalid(x);

            if isdeletable(obj.SizeChangedListener)
                delete(obj.SizeChangedListener)
            end

            if isdeletable(obj.LimitsChangedListener)
                delete(obj.LimitsChangedListener)
            end
        end
    end

    methods (Access = private) % Internal updating

        function tf = hasBackground(obj)
            tf = ~isempty(obj.hScalebarBackground) && ...
                isgraphics(obj.hScalebarBackground);
        end

        function validateAxes(~, hAxes)
            assert(isa(hAxes, 'matlab.graphics.axis.Axes') && isvalid(hAxes), ...
                'First argument must be a valid axes object')
        end

        function assignPVPairs(obj, varargin)
            for i = 1:2:numel(varargin)
                obj.(varargin{i}) = varargin{i+1};
            end
        end

        function onColorSet(obj, newValue)
            if obj.IsConstructed
                set(obj.hScalebarLine, 'Color', newValue)
                set(obj.hScalebarText, 'Color', newValue)
            end
        end

        function onLinewidthChanged(obj, newValue)
            if ~obj.IsConstructed; return; end
            set(obj.hScalebarLine, 'LineWidth', newValue)
        end

        function onFontNameChanged(obj, newValue)
            if ~obj.IsConstructed; return; end
            set(obj.hScalebarText, 'FontName', newValue)
        end

        function onFontSizeChanged(obj, newValue)
            if ~obj.IsConstructed; return; end
            set(obj.hScalebarText, 'FontSize', newValue)
        end

        function onFontWeightChanged(obj, newValue)
            if ~obj.IsConstructed; return; end
            set(obj.hScalebarText, 'FontWeight', newValue)
        end

        function onBackgroundColorChanged(obj, newValue)
            if ~obj.IsConstructed || ~obj.hasBackground()
                return
            end
            obj.hScalebarBackground.FaceColor = newValue;
        end

        function onBackgroundAlphaChanged(obj, newValue)
            if ~obj.IsConstructed || ~obj.hasBackground()
                return
            end
            obj.hScalebarBackground.FaceAlpha = newValue;
        end

        function onAxesLimitsChanged(obj)
            if obj.AutoAdjustScalebarLength
                obj.autoAdjustScalebarLength()
            end

            obj.updatePosition()
        end

        function onParentChanged(obj)
            if ~obj.IsConstructed; return; end

            wasHoldOn = ishold(obj.hAxes);
            hold(obj.hAxes, 'on')
            obj.hAxes.XLim = obj.hAxes.XLim;
            obj.hAxes.YLim = obj.hAxes.YLim;

            obj.hScalebarLine.Parent = obj.hAxes;
            obj.hScalebarText.Parent = obj.hAxes;
            if obj.hasBackground()
                obj.hScalebarBackground.Parent = obj.hAxes;
            end
            obj.deleteListeners()
            obj.createListeners()

            obj.ContextMenu.Parent = ancestor(obj.hAxes, 'figure');

            obj.updatePosition()

            if ~wasHoldOn
                hold(obj.hAxes, 'off')
            end
        end

        function updateTextLabel(obj)
            if ~obj.IsConstructed; return; end
            textLabel = obj.getTextLabel();
            obj.hScalebarText.String = textLabel;
            obj.updateBackground()
        end

        function updateScalebar(obj)
            if ~obj.IsConstructed; return; end

            obj.assignScalebarLength()
            obj.hScalebarLine.XData = obj.calculateXData();
            obj.hScalebarLine.YData = obj.calculateYData();
        end

        function updatePosition(obj)
            if ~obj.IsConstructed; return; end

            % Make sure limit mode is manual, because resizing the scalebar
            % could change the axes limits.
            xLimModePreUpdate = obj.hAxes.XLimMode;
            yLimModePreUpdate = obj.hAxes.YLimMode;

            if ~strcmp(xLimModePreUpdate, 'manual')
                obj.hAxes.XLimMode = 'manual';
            end
            if ~strcmp(yLimModePreUpdate, 'manual')
                obj.hAxes.YLimMode = 'manual';
            end

            assignScalebarLength(obj)
            calculateMarginDataUnits(obj)

            obj.updateScalebar()
            obj.plotTextLabel()
            obj.updateBackground()

            % Reset xlim and ylim modes
            obj.hAxes.XLimMode = xLimModePreUpdate;
            obj.hAxes.YLimMode = yLimModePreUpdate;
        end

        function updateTextPosition(obj)
            if ~obj.IsConstructed; return; end

            txtPos = calculateTextPosition(obj);
            obj.hScalebarText.Position(1:2) = [txtPos.x, txtPos.y];
            obj.updateBackground()
        end

        function updateBackground(obj)
            if ~obj.IsConstructed
                return
            end
            obj.plotBackground()
        end

        function refreshAutoScalebarLength(obj)
            if obj.AutoAdjustScalebarLength && obj.IsConstructed
                obj.autoAdjustScalebarLength()
            end
        end

        function autoAdjustScalebarLength(obj)

            switch obj.Axis
                case 'x'
                    axesLimits = obj.hAxes.XLim;
                case 'y'
                    axesLimits = obj.hAxes.YLim;
            end

            limRange = max(axesLimits) - min(axesLimits);

            scalebarLengthDu = limRange .* obj.AutoScalebarLength/100;

            % conversionFactor = data unit / scalebar unit;
            scalebarLengthRu = scalebarLengthDu / obj.ConversionFactor;

            % Round to nearest 5 on first significant digit
            x = floor( log10(scalebarLengthRu) );
            scalebarLengthRu_ = scalebarLengthRu .* 10^-x;
            scalebarLengthRu_ = round(scalebarLengthRu_);
            scalebarLengthRu_ = scalebarLengthRu_ .* 10^x;

% %             if scalebarLengthRu_ == 0
% %                 x = x + sign(x);
% %                 scalebarLengthRu_ = round(scalebarLengthRu/5, -x) * 5;
% %             end

            % Set autoadjusted scalebar length
            obj.ScalebarLength = scalebarLengthRu_;
        end
    end

    methods (Access = private) % Context menu callbacks
        function onConfigureScalebarClicked(obj)
            defaultInput = {num2str(obj.ScalebarLength), obj.UnitLabel, num2str(obj.ConversionFactor)};
            answer = inputdlg({'Enter scalebar length', 'Enter scalebar unit', ...
                'Enter conversion ratio'}, 'Enter scalebar info', 1, defaultInput);
            if isempty(answer); return; end

            scalebarLength = str2double(answer{1});
            unitLabel = answer{2};
            conversionFactor = str2double(answer{3});

            obj.ScalebarLength = scalebarLength;
            obj.UnitLabel = unitLabel;
            obj.ConversionFactor = conversionFactor;
        end

        function onAutoadjustScalebarClicked(obj, src)
            arguments
                obj (1,1) scalebar
                src (1,1) matlab.ui.container.Menu
            end

            if src.Checked
                obj.AutoAdjustScalebarLength = false;
                src.Checked = 'off';
            else
                obj.AutoAdjustScalebarLength = true;
                src.Checked = 'on';
                obj.autoAdjustScalebarLength()
            end
        end

        function onSetLineWidthClicked(obj, lineWidth)
            arguments
                obj (1,1) scalebar
                lineWidth (1,1) double {mustBeFinite, mustBePositive}
            end
            obj.LineWidth = lineWidth;
        end

        function onSetFontSizeClicked(obj, fontSize)
            arguments
                obj (1,1) scalebar
                fontSize (1,1) double {mustBeFinite, mustBePositive}
            end
            obj.FontSize = fontSize;
        end

        function onSetColorClicked(obj)
            c = uisetcolor('Select scalebar color');
            if isequal( c, 0)
                return % User canceled
            else
                obj.Color = c;
            end
        end

        function onSetFontClicked(obj)

            opts = uisetfont(obj.hScalebarText);
            if isequal( opts, 0)
                return % User canceled
            else
                obj.FontWeight = opts.FontWeight;
                obj.FontSize = opts.FontSize;
                obj.FontName = opts.FontName;
            end
        end

        function onSetLocationClicked(obj, newLocation)
            arguments
                obj (1,1) scalebar
                newLocation (1,1) string {mustBeValidLocation}
            end
            obj.Location = newLocation;
        end

        function onToggleBackgroundClicked(obj)
            obj.ShowBackground = ~obj.ShowBackground;
        end

        function onSetBackgroundColorClicked(obj)
            color = uisetcolor(obj.BackgroundColor, 'Select background color');
            if ~isequal(color, 0)
                obj.BackgroundColor = color;
            end
        end

        function onSetBackgroundAlphaClicked(obj, alpha)
            obj.BackgroundAlpha = alpha;
        end
    end
end

function [hParent, positionalPairs, nvPairs] = parseConstructorInputs(varargin)
%parseConstructorInputs Normalize legacy positional inputs and name-value pairs.

    args = varargin;
    positionalPairs = {};
    nvPairs = cell(1, numel(args));
    numNVPairs = 0;
    hasPositionalParent = false;

    if ~isempty(args) && isa(args{1}, 'matlab.graphics.axis.Axes')
        hParent = args{1};
        hasPositionalParent = true;
        args(1) = [];
    else
        hParent = gca;
    end

    if ~isempty(args) && isTextScalar(args{1}) && ...
            any(strcmp(string(args{1}), ["x", "y"]))
        positionalPairs = [positionalPairs, {'Axis', args{1}}];
        args(1) = [];
    end

    if ~isempty(args) && isnumeric(args{1})
        positionalPairs = [positionalPairs, {'ScalebarLength', args{1}}];
        args(1) = [];
    end

    if ~isempty(args) && isTextScalar(args{1}) && ...
            ~isConfigurablePropertyName(args{1}) && ~strcmp(string(args{1}), "Parent")
        positionalPairs = [positionalPairs, {'UnitLabel', args{1}}];
        args(1) = [];
    end

    if isempty(args)
        nvPairs = {};
        return
    end

    if mod(numel(args), 2) ~= 0
        error('scalebar:InvalidConstructorInput', ...
            'Expected positional inputs followed by complete name-value pairs.')
    end

    for i = 1:2:numel(args)
        name = args{i};
        value = args{i+1};
        if ~isTextScalar(name)
            error('scalebar:InvalidOptionName', ...
                'Name-value option names must be character vectors or string scalars.')
        end

        name = char(string(name));
        if strcmp(name, 'Parent')
            if hasPositionalParent
                error('scalebar:DuplicateParent', ...
                    'Specify the parent axes either positionally or as Parent, not both.')
            end
            hParent = value;
            hasPositionalParent = true;
        elseif isConfigurablePropertyName(name)
            numNVPairs = numNVPairs + 2;
            nvPairs(numNVPairs-1:numNVPairs) = {name, value};
        else
            error('scalebar:UnknownOption', ...
                'Unknown scalebar option "%s".', name)
        end
    end

    nvPairs = nvPairs(1:numNVPairs);
end

function tf = isTextScalar(value)
    tf = (ischar(value) && isrow(value)) || (isstring(value) && isscalar(value));
end

function tf = isConfigurablePropertyName(name)
    tf = any(strcmp(char(string(name)), scalebar.CONFIGURABLE_PROPS));
end

function locations = validLocations()
    locations = ["northeast", "northwest", "southeast", "southwest", ...
        "northeastoutside", "northwestoutside", "southeastoutside", ...
        "southwestoutside"];
end

function mustBeValidLocation(value)
    if ~any(value == validLocations())
        error('scalebar:InvalidLocation', ...
            'Location must be a supported axes corner, optionally suffixed with outside.')
    end
end

function offset = calculateContainmentOffset(lowerBound, upperBound, limits)
    offset = 0;
    if lowerBound < limits(1) && upperBound <= limits(2)
        offset = limits(1) - lowerBound;
    elseif upperBound > limits(2) && lowerBound >= limits(1)
        offset = limits(2) - upperBound;
    end
end

function mustBeValidScalebarLength(value)
    if ~(isnan(value) || (isfinite(value) && value > 0))
        error('scalebar:InvalidScalebarLength', ...
            'ScalebarLength must be a positive finite scalar or NaN for automatic sizing.')
    end
end

function props2prefs(obj)

    [~, groupName, ~] = fileparts(mfilename('fullpath'));
    propNames = scalebar.STYLE_PROPS;

    for i = 1:numel(propNames)
        setpref(groupName, propNames{i}, obj.(propNames{i}))
    end
end

function nvPairs = prefs2props()

    [~, groupName, ~] = fileparts(mfilename('fullpath'));
    propNames = scalebar.STYLE_PROPS;
    % todo: get from mc...
    defaultValues = {12, 'normal', 1, 'k', 'southeast', 'Helvetica Neue', ...
        false, [0.5 0.5 0.5], 0.3, 3};
    prefValues = cell(1, numel(propNames));

    for i = 1:numel(propNames)
        prefValues{i} = getpref(groupName, propNames{i}, defaultValues{i});
    end

    nvPairs = cat(1, propNames, prefValues);
    nvPairs = transpose( nvPairs(:) );
end

function excludeFromDataTips(hObjects)
%excludeFromDataTips Keep data tips off scale bar graphics
%
%   Disables the data-cursor behavior per object. In java-based figures
%   clicking a graphics object pins a data tip even when the object has
%   its own ButtonDownFcn; the behavior object is what the data-cursor
%   machinery consults. Does not affect HitTest, ButtonDownFcn or
%   ContextMenu, and the host axes is left untouched (data tips on the
%   user's own data keep working).

    for i = 1:numel(hObjects)
        try
            hBehavior = hggetbehavior(hObjects(i), 'DataCursor');
            hBehavior.Enable = false;
        catch
            % Object type without behavior support; nothing to exclude.
        end
    end
end
