classdef ScalebarTest < matlab.unittest.TestCase

    properties (Access = private)
        Figure
        Axes
        AlternateFont string
    end

    methods (TestMethodSetup)
        function createAxes(testCase)
            repositoryRoot = fileparts(fileparts(mfilename('fullpath')));
            addpath(fullfile(repositoryRoot, 'src', 'scalebar'))

            testCase.Figure = figure('Visible', 'off');
            testCase.Axes = axes(testCase.Figure);
            plot(testCase.Axes, [0, 10], [0, 10])
            testCase.Axes.XLim = [0, 10];
            testCase.Axes.YLim = [0, 10];

            hText = text(testCase.Axes, 0, 0, '');
            defaultFont = string(hText.FontName);
            delete(hText)
            availableFonts = string(listfonts);
            testCase.AlternateFont = availableFonts( ...
                find(availableFonts ~= defaultFont, 1));

            testCase.addTeardown(@() close(testCase.Figure))
        end
    end

    methods (Test)
        function testConstructorAcceptsStringNameValueArguments(testCase)
            hScalebar = testCase.createScalebar( ...
                "x", 2, "mm", "Location", "northwest");

            testCase.verifyEqual(hScalebar.Location, 'northwest')
            testCase.verifyEqual(hScalebar.UnitLabel, 'mm')
        end

        function testConstructorPreservesCharacterVectorInputs(testCase)
            hScalebar = testCase.createScalebar( ...
                'x', 2, 'mm', 'Location', 'northwest');

            testCase.verifyEqual(hScalebar.Location, 'northwest')
            testCase.verifyEqual(hScalebar.UnitLabel, 'mm')
        end

        function testConstructorAppliesVisibleAndFontName(testCase)
            requestedFont = testCase.AlternateFont;
            hScalebar = testCase.createScalebar( ...
                "Visible", "off", "FontName", requestedFont);

            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');
            testCase.verifyEqual(hScalebar.Visible, matlab.lang.OnOffSwitchState.off)
            testCase.verifyEqual(hLine.Visible, matlab.lang.OnOffSwitchState.off)
            testCase.verifyEqual(hText.Visible, matlab.lang.OnOffSwitchState.off)
            testCase.verifyEqual(string(hText.FontName), requestedFont)
        end

        function testConstructorRejectsUnknownOption(testCase)
            testCase.verifyError( ...
                @() scalebar(testCase.Axes, "x", 2, "mm", "NotAnOption", 1), ...
                'scalebar:UnknownOption')
        end

        function testConstructorRejectsNonpositiveLength(testCase)
            testCase.verifyError( ...
                @() scalebar(testCase.Axes, "x", 0, "mm"), ...
                'scalebar:InvalidScalebarLength')
        end

        function testPropertyChangesUpdateGraphics(testCase)
            hScalebar = testCase.createScalebar("x", 2, "mm");
            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');

            initialTextPosition = hText.Position;
            hScalebar.TextSpacing = 20;
            testCase.verifyNotEqual(hText.Position, initialTextPosition)

            hScalebar.Axis = "y";
            testCase.verifyEqual(testCase.dataRange(hLine.XData), 0)
            testCase.verifyEqual( ...
                testCase.dataRange(hLine.YData), hScalebar.ScalebarLength, ...
                'AbsTol', 1e-10)
            testCase.verifyEqual(hText.Rotation, 90)
        end

        function testVerticalTextSpacingMovesEastLabelLeft(testCase)
            hScalebar = testCase.createScalebar( ...
                "y", 2, "mm", "Location", "southeast");
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');

            initialXPosition = hText.Position(1);
            hScalebar.TextSpacing = 20;

            testCase.verifyLessThan(hText.Position(1), initialXPosition)
        end

        function testVerticalTextSpacingRespectsReversedXAxis(testCase)
            testCase.Axes.XDir = 'reverse';
            hScalebar = testCase.createScalebar( ...
                "y", 2, "mm", "Location", "southeast");
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');

            initialXPosition = hText.Position(1);
            hScalebar.TextSpacing = 20;

            testCase.verifyGreaterThan(hText.Position(1), initialXPosition)
        end

        function testVerticalTextSpacingMovesWestLabelRight(testCase)
            hScalebar = testCase.createScalebar( ...
                "y", 2, "mm", "Location", "southwest");
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');

            initialXPosition = hText.Position(1);
            hScalebar.TextSpacing = 20;

            testCase.verifyGreaterThan(hText.Position(1), initialXPosition)
        end

        function testVerticalTextSpacingMovesEastOutsideLabelRight(testCase)
            hScalebar = testCase.createScalebar( ...
                "y", 2, "mm", "Location", "southeastoutside");
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');

            initialXPosition = hText.Position(1);
            hScalebar.TextSpacing = 20;

            testCase.verifyGreaterThan(hText.Position(1), initialXPosition)
        end

        function testVerticalTextSpacingMovesWestOutsideLabelLeft(testCase)
            hScalebar = testCase.createScalebar( ...
                "y", 2, "mm", "Location", "southwestoutside");
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');

            initialXPosition = hText.Position(1);
            hScalebar.TextSpacing = 20;

            testCase.verifyLessThan(hText.Position(1), initialXPosition)
        end

        function testEnablingAutomaticLengthUpdatesScalebar(testCase)
            hScalebar = testCase.createScalebar("x", 1, "mm");

            hScalebar.AutoAdjustScalebarLength = true;

            testCase.verifyEqual(hScalebar.ScalebarLength, 2)
        end

        function testReversedXAxisUsesVisualLocation(testCase)
            testCase.Axes.XDir = 'reverse';
            testCase.createScalebar( ...
                "x", 2, "mm", "Location", "southeast");
            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');

            testCase.verifyLessThan(mean(hLine.XData), mean(testCase.Axes.XLim))
        end

        function testStylePropertiesUpdateGraphics(testCase)
            hScalebar = testCase.createScalebar("x", 2, "mm");
            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');

            hScalebar.Color = 'r';
            hScalebar.LineWidth = 3;
            hScalebar.FontName = testCase.AlternateFont;
            hScalebar.FontSize = 14;
            hScalebar.FontWeight = "bold";

            testCase.verifyEqual(hLine.Color, [1, 0, 0])
            testCase.verifyEqual(hLine.LineWidth, 3)
            testCase.verifyEqual(string(hText.FontName), testCase.AlternateFont)
            testCase.verifyEqual(hText.FontSize, 14)
            testCase.verifyEqual(hText.FontWeight, 'bold')
        end

        function testBackgroundPropertiesCreateAndUpdatePatch(testCase)
            hScalebar = testCase.createScalebar( ...
                "x", 2, "mm", ShowBackground=true, ...
                BackgroundColor=[0.2 0.3 0.4], BackgroundAlpha=0.6, ...
                BackgroundPadding=5);
            hBackground = findobj(testCase.Axes, 'Tag', 'Scalebar Background');

            testCase.verifyNumElements(hBackground, 1)
            testCase.verifyEqual(hBackground.FaceColor, [0.2 0.3 0.4])
            testCase.verifyEqual(hBackground.FaceAlpha, 0.6)

            hScalebar.BackgroundAlpha = 0.4;
            hScalebar.ShowBackground = false;
            testCase.verifyEqual(hBackground.FaceAlpha, 0.4)
            testCase.verifyEqual(hBackground.Visible, ...
                matlab.lang.OnOffSwitchState.off)

            hScalebar.ShowBackground = true;
            testCase.verifyEqual(hBackground.Visible, ...
                matlab.lang.OnOffSwitchState.on)
        end

        function testEnabledBackgroundReceivesContextMenu(testCase)
            hScalebar = testCase.createScalebar( ...
                "x", 2, "mm", ShowBackground=false);
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');

            hScalebar.ShowBackground = true;
            hBackground = findobj(testCase.Axes, 'Tag', 'Scalebar Background');

            testCase.verifyEqual(hBackground.ContextMenu, hText.ContextMenu)
            testCase.verifyEqual(hBackground.PickableParts, 'visible')
        end

        function testBackgroundPatchMovesWithScalebar(testCase)
            hScalebar = testCase.createScalebar( ...
                "x", 2, "mm", ShowBackground=true);
            hBackground = findobj(testCase.Axes, 'Tag', 'Scalebar Background');
            initialXData = hBackground.XData;

            hScalebar.Margin = [20 20];

            testCase.verifyNotEqual(hBackground.XData, initialXData)
        end

        function testConversionFactorUpdatesLineLength(testCase)
            hScalebar = testCase.createScalebar("x", 2, "mm");
            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');

            hScalebar.ConversionFactor = 3;

            testCase.verifyEqual(testCase.dataRange(hLine.XData), 6)
        end

        function testMarginUpdatesLinePosition(testCase)
            hScalebar = testCase.createScalebar("x", 2, "mm");
            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');
            initialXData = hLine.XData;

            hScalebar.Margin = [20, 20];

            testCase.verifyNotEqual(hLine.XData, initialXData)
        end

        function testAutomaticLengthUsesConfiguredPercentage(testCase)
            hScalebar = testCase.createScalebar("x", 1, "mm");

            hScalebar.AutoScalebarLength = 30;
            hScalebar.AutoAdjustScalebarLength = true;

            testCase.verifyEqual(hScalebar.ScalebarLength, 3)
        end

        function testHorizontalOutsideLocationPlacesBarBelowAxes(testCase)
            testCase.createScalebar( ...
                "x", 2, "mm", "Location", "southeastoutside");
            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');

            testCase.verifyLessThan(hLine.YData(1), testCase.Axes.YLim(1))
        end

        function testVerticalOutsideLocationPlacesBarLeftOfAxes(testCase)
            testCase.createScalebar( ...
                "y", 2, "mm", "Location", "southwestoutside");
            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');

            testCase.verifyLessThan(hLine.XData(1), testCase.Axes.XLim(1))
        end

        function testReversedYAxisUsesVisualLocation(testCase)
            testCase.Axes.YDir = 'reverse';
            testCase.createScalebar("y", 2, "mm", "Location", "southwest");
            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');

            testCase.verifyGreaterThan(mean(hLine.YData), mean(testCase.Axes.YLim))
        end

        function testMicrometreFractionalLabel(testCase)
            testCase.createScalebar("x", 2.5, "um");
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');

            testCase.verifyNotEmpty(strfind(hText.String, '2.500'))
            testCase.verifyNotEmpty(strfind(hText.String, '\mu'))
        end

        function testParentChangeMovesGraphicsAndContextMenu(testCase)
            secondFigure = figure('Visible', 'off');
            secondAxes = axes(secondFigure);
            testCase.addTeardown(@() close(secondFigure))

            hScalebar = testCase.createScalebar("x", 2, "mm");
            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');

            hScalebar.Parent = secondAxes;

            testCase.verifyEqual(hScalebar.Parent, secondAxes)
            testCase.verifyEqual(hLine.Parent, secondAxes)
            testCase.verifyEqual(hText.Parent, secondAxes)
            testCase.verifyEqual(hText.ContextMenu.Parent, secondFigure)
        end

        function testAxesLimitChangeUpdatesAutomaticLength(testCase)
            hScalebar = testCase.createScalebar("x", 1, "mm");
            hScalebar.AutoAdjustScalebarLength = true;

            testCase.Axes.XLim = [0, 20];
            drawnow

            testCase.verifyEqual(hScalebar.ScalebarLength, 4)
        end

        function testPublicStyleProperties(testCase)
            hScalebar = testCase.createScalebar("x", 2, "mm");

            hScalebar.LineWidth = 3;
            hScalebar.FontSize = 14;
            hScalebar.Location = "northwest";

            testCase.verifyEqual(hScalebar.LineWidth, 3)
            testCase.verifyEqual(hScalebar.FontSize, 14)
            testCase.verifyEqual(hScalebar.Location, 'northwest')
        end

        function testContextMenuAutoadjustToggle(testCase)
            hScalebar = testCase.createScalebar("x", 1, "mm");
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');
            hMenuItem = findobj( ...
                hText.ContextMenu, 'Text', 'Autoadjust Scalebar');

            hMenuItem.Callback(hMenuItem, [])
            testCase.verifyTrue(hScalebar.AutoAdjustScalebarLength)
            testCase.verifyEqual(hMenuItem.Checked, matlab.lang.OnOffSwitchState.on)

            hMenuItem.Callback(hMenuItem, [])
            testCase.verifyFalse(hScalebar.AutoAdjustScalebarLength)
            testCase.verifyEqual(hMenuItem.Checked, matlab.lang.OnOffSwitchState.off)
        end

        function testConstructorUsesNamedParent(testCase)
            hScalebar = scalebar( ...
                "x", 2, "mm", "Parent", testCase.Axes);
            testCase.addTeardown(@() delete(hScalebar))

            testCase.verifyEqual(hScalebar.Parent, testCase.Axes)
        end

        function testConstructorRejectsIncompleteNameValueArguments(testCase)
            testCase.verifyError( ...
                @() scalebar(testCase.Axes, "x", 2, "mm", "Location"), ...
                'scalebar:InvalidConstructorInput')
        end

        function testConstructorRejectsNontextOptionName(testCase)
            testCase.verifyError( ...
                @() scalebar(testCase.Axes, "x", 2, "mm", 1, "value"), ...
                'scalebar:InvalidOptionName')
        end

        function testConstructorRejectsDuplicateParent(testCase)
            testCase.verifyError( ...
                @() scalebar(testCase.Axes, "x", 2, "mm", ...
                    "Parent", testCase.Axes), ...
                'scalebar:DuplicateParent')
        end

        function testLocationRejectsUnsupportedValue(testCase)
            hScalebar = testCase.createScalebar("x", 2, "mm");

            testCase.verifyError( ...
                @() setLocationToCenter(hScalebar), ...
                'MATLAB:validators:mustBeMember')
        end

        function testAutomaticYLengthUsesYAxisRange(testCase)
            testCase.Axes.YLim = [0, 20];
            hScalebar = testCase.createScalebar("y", 1, "mm");

            hScalebar.AutoAdjustScalebarLength = true;

            testCase.verifyEqual(hScalebar.ScalebarLength, 4)
        end

        function testPositionUpdateRestoresAutomaticLimitModes(testCase)
            hScalebar = testCase.createScalebar("x", 2, "mm");
            testCase.Axes.XLimMode = 'auto';
            testCase.Axes.YLimMode = 'auto';

            hScalebar.Margin = [20, 20];

            testCase.verifyEqual(testCase.Axes.XLimMode, 'auto')
            testCase.verifyEqual(testCase.Axes.YLimMode, 'auto')
        end

        function testSaveCurrentStyleContextMenuCallback(testCase)
            preferenceNames = {'FontSize', 'FontWeight', 'LineWidth', ...
                'Color', 'Location', 'FontName', 'ShowBackground', ...
                'BackgroundColor', 'BackgroundAlpha', 'BackgroundPadding'};
            [hadPreference, preferenceValues] = ...
                testCase.captureStylePreferences(preferenceNames);
            testCase.addTeardown(@() testCase.restoreStylePreferences( ...
                preferenceNames, hadPreference, preferenceValues))

            hScalebar = testCase.createScalebar("x", 2, "mm");
            hScalebar.Color = 'r';
            hText = findobj(testCase.Axes, 'Tag', 'Scalebar Text');
            hMenuItem = findobj( ...
                hText.ContextMenu, 'Text', 'Save Current Style');

            hMenuItem.Callback(hMenuItem, [])

            testCase.verifyEqual(getpref('scalebar', 'Color'), 'r')
        end

        function testPlotboxposPlacementRestoresAxesUnits(testCase)
            fixturePath = fullfile( ...
                fileparts(mfilename('fullpath')), 'fixtures');
            addpath(fixturePath, '-begin')
            testCase.addTeardown(@() rmpath(fixturePath))
            testCase.Axes.Units = 'pixels';

            testCase.createScalebar("x", 2, "mm");

            testCase.verifyEqual(testCase.Axes.Units, 'pixels')
        end

        function testPixelPositionFallbackWhenPlotboxposIsUnavailable(testCase)
            plotboxposPath = which('plotboxpos');
            if ~isempty(plotboxposPath)
                plotboxposFolder = fileparts(plotboxposPath);
                rmpath(plotboxposFolder)
                testCase.addTeardown(@() addpath(plotboxposFolder, '-end'))
            end

            testCase.createScalebar("x", 2, "mm");
            hLine = findobj(testCase.Axes, 'Tag', 'Scalebar Line');

            testCase.verifyNotEmpty(hLine)
        end
    end

    methods (Access = private)
        function hScalebar = createScalebar(testCase, varargin)
            hScalebar = scalebar(testCase.Axes, varargin{:});
            testCase.addTeardown(@() delete(hScalebar))
        end

        function value = dataRange(~, data)
            value = max(data) - min(data);
        end

        function [hadPreference, values] = captureStylePreferences(~, names)
            hadPreference = cellfun(@(name) ispref('scalebar', name), names);
            values = cell(size(names));
            for i = 1:numel(names)
                if hadPreference(i)
                    values{i} = getpref('scalebar', names{i});
                end
            end
        end

        function restoreStylePreferences(~, names, hadPreference, values)
            for i = 1:numel(names)
                if hadPreference(i)
                    setpref('scalebar', names{i}, values{i})
                elseif ispref('scalebar', names{i})
                    rmpref('scalebar', names{i})
                end
            end
        end
    end
end

function setLocationToCenter(hScalebar)
    hScalebar.Location = "center";
end
