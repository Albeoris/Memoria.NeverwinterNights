using System.Globalization;
using System.Text;
using System.Text.Encodings.Web;
using System.Text.Json;
using System.Text.Json.Nodes;

namespace Memoria.NeverwinterNights.Toolset;

internal static class NuiLayoutTool
{
    private sealed record Rect(double X, double Y, double Width, double Height);
    private sealed record Element(string Id, string Type, Rect Logical, Rect Physical);

    public static int Run(string[] arguments)
    {
        if (arguments.Length == 0) return Fail("nui-layout: specify a JSON configuration.");
        List<string> mutable = arguments.ToList();
        string configPath = Path.GetFullPath(mutable[0]);
        mutable.RemoveAt(0);
        string outputDirectory = Path.GetFullPath(TakeOption(mutable, "-o", "--output") ?? Path.Combine(Path.GetDirectoryName(configPath)!, "preview"));
        if (mutable.Count > 0) return Fail($"nui-layout: unknown arguments: {string.Join(' ', mutable)}");
        JsonObject config = JsonNode.Parse(File.ReadAllText(configPath))?.AsObject() ?? throw new InvalidDataException("The JSON configuration is empty.");
        JsonObject screen = RequireObject(config, "screen");
        JsonObject window = RequireObject(config, "window");
        double screenWidth = Number(screen, "width", 3440.0);
        double screenHeight = Number(screen, "height", 1440.0);
        double scale = Number(screen, "uiScale", 2.0);
        double coverage = Number(window, "coverage", 0.9);
        double titleHeight = Number(window, "titleHeight", 24.0);
        double padding = Number(window, "padding", 8.0);
        if (screenWidth <= 0.0 || screenHeight <= 0.0 || scale <= 0.0 || coverage <= 0.0 || coverage > 1.0) throw new InvalidDataException("Invalid screen, uiScale, or window.coverage value.");
        double logicalWidth = window["logicalWidth"] is null ? Math.Floor(screenWidth * coverage / scale) : Number(window, "logicalWidth", Math.Floor(screenWidth * coverage / scale));
        double logicalHeight = window["logicalHeight"] is null ? Math.Floor(screenHeight * coverage / scale) : Number(window, "logicalHeight", Math.Floor(screenHeight * coverage / scale));
        if (logicalWidth <= 0.0 || logicalHeight <= 0.0 || logicalWidth * scale > screenWidth || logicalHeight * scale > screenHeight) throw new InvalidDataException("Invalid NUI window dimensions.");
        Rect physicalWindow = new((screenWidth - logicalWidth * scale) / 2.0, (screenHeight - logicalHeight * scale) / 2.0, logicalWidth * scale, logicalHeight * scale);
        Rect logicalContent = new(padding, titleHeight + padding, logicalWidth - padding * 2.0, logicalHeight - titleHeight - padding * 2.0);
        List<Element> elements = [];
        List<string> diagnostics = [];
        LayoutNode(RequireObject(config, "root"), logicalContent, scale, physicalWindow, elements, diagnostics, "root");
        Directory.CreateDirectory(outputDirectory);
        string stem = Path.GetFileNameWithoutExtension(configPath);
        string jsonPath = Path.Combine(outputDirectory, stem + ".layout.json");
        string svgPath = Path.Combine(outputDirectory, stem + ".svg");
        JsonObject report = BuildReport(configPath, screenWidth, screenHeight, scale, logicalWidth, logicalHeight, physicalWindow, elements, diagnostics);
        File.WriteAllText(jsonPath, report.ToJsonString(new JsonSerializerOptions { WriteIndented = true, Encoder = JavaScriptEncoder.UnsafeRelaxedJsonEscaping }), new UTF8Encoding(false));
        File.WriteAllText(svgPath, BuildSvg(screenWidth, screenHeight, physicalWindow, elements, diagnostics), new UTF8Encoding(false));
        Console.WriteLine($"NUI layout: {logicalWidth:0}x{logicalHeight:0} logical, {physicalWindow.Width:0}x{physicalWindow.Height:0} physical, scale x{scale:0.##}");
        Console.WriteLine($"Model: {jsonPath}");
        Console.WriteLine($"Preview: {svgPath}");
        foreach (string diagnostic in diagnostics) Console.Error.WriteLine("WARN: " + diagnostic);
        return diagnostics.Count == 0 ? 0 : 2;
    }

    private static void LayoutNode(JsonObject node, Rect bounds, double scale, Rect physicalWindow, List<Element> elements, List<string> diagnostics, string fallbackId)
    {
        string type = Text(node, "type", "control").ToLowerInvariant();
        string id = Text(node, "id", fallbackId);
        double width = Number(node, "width", bounds.Width);
        double height = Number(node, "height", bounds.Height);
        Rect rect = new(bounds.X, bounds.Y, Math.Min(width, bounds.Width), Math.Min(height, bounds.Height));
        if (width > bounds.Width + 0.01) diagnostics.Add($"{id}: width {width:0.##} exceeds {bounds.Width:0.##}.");
        if (height > bounds.Height + 0.01) diagnostics.Add($"{id}: height {height:0.##} exceeds {bounds.Height:0.##}.");
        elements.Add(new Element(id, type, rect, ToPhysical(rect, scale, physicalWindow)));
        if (type is "column" or "row") LayoutLinear(node, rect, scale, physicalWindow, elements, diagnostics, type == "row");
        else if (type == "group") LayoutGroup(node, rect, scale, physicalWindow, elements, diagnostics);
        else if (type == "list") LayoutList(node, rect, scale, physicalWindow, elements, diagnostics);
        else if (type == "grid") LayoutGrid(node, rect, scale, physicalWindow, elements, diagnostics);
        else if (type == "shelf") LayoutShelf(node, rect, scale, physicalWindow, elements, diagnostics);
    }

    private static Rect WidgetViewport(JsonObject node, Rect bounds, double scale, Rect physicalWindow, List<Element> elements, string defaultScrollbars, double defaultBorderInset)
    {
        string id = Text(node, "id", "widget");
        string scrollbars = Text(node, "scrollbars", defaultScrollbars).ToLowerInvariant();
        bool hasHorizontal = scrollbars is "x" or "horizontal" or "both";
        bool hasVertical = scrollbars is "y" or "vertical" or "both";
        double scrollbarSize = Number(node, "scrollbarSize", 16.0);
        double borderInset = Number(node, "borderInset", defaultBorderInset);
        double viewportWidth = Math.Max(0.0, bounds.Width - borderInset * 2.0 - (hasVertical ? scrollbarSize : 0.0));
        double viewportHeight = Math.Max(0.0, bounds.Height - borderInset * 2.0 - (hasHorizontal ? scrollbarSize : 0.0));
        Rect viewport = new(bounds.X + borderInset, bounds.Y + borderInset, viewportWidth, viewportHeight);
        elements.Add(new Element(id + ".viewport", "viewport", viewport, ToPhysical(viewport, scale, physicalWindow)));
        if (hasVertical)
        {
            Rect vertical = new(bounds.X + bounds.Width - borderInset - scrollbarSize, bounds.Y + borderInset, scrollbarSize, viewportHeight);
            elements.Add(new Element(id + ".scrollbar-y", "scrollbar-y", vertical, ToPhysical(vertical, scale, physicalWindow)));
        }
        if (hasHorizontal)
        {
            Rect horizontal = new(bounds.X + borderInset, bounds.Y + bounds.Height - borderInset - scrollbarSize, viewportWidth, scrollbarSize);
            elements.Add(new Element(id + ".scrollbar-x", "scrollbar-x", horizontal, ToPhysical(horizontal, scale, physicalWindow)));
        }
        return viewport;
    }

    private static void LayoutGroup(JsonObject node, Rect bounds, double scale, Rect physicalWindow, List<Element> elements, List<string> diagnostics)
    {
        Rect viewport = WidgetViewport(node, bounds, scale, physicalWindow, elements, "none", 4.0);
        JsonObject child = node["child"]?.AsObject() ?? [];
        string scrollbars = Text(node, "scrollbars", "none").ToLowerInvariant();
        bool hasHorizontal = scrollbars is "x" or "horizontal" or "both";
        bool hasVertical = scrollbars is "y" or "vertical" or "both";
        double childWidth = Number(child, "width", viewport.Width);
        double childHeight = Number(child, "height", viewport.Height);
        Rect childBounds = new(viewport.X, viewport.Y, hasHorizontal ? Math.Max(viewport.Width, childWidth) : viewport.Width, hasVertical ? Math.Max(viewport.Height, childHeight) : viewport.Height);
        LayoutNode(child, childBounds, scale, physicalWindow, elements, diagnostics, Text(node, "id", "group") + ".child");
    }

    private static void LayoutLinear(JsonObject node, Rect bounds, double scale, Rect physicalWindow, List<Element> elements, List<string> diagnostics, bool horizontal)
    {
        JsonArray children = node["children"]?.AsArray() ?? [];
        double gap = Number(node, "gap", 0.0);
        double availableMain = (horizontal ? bounds.Width : bounds.Height) - Math.Max(0, children.Count - 1) * gap;
        double fixedMain = 0.0;
        double growTotal = 0.0;
        foreach (JsonNode? childNode in children)
        {
            JsonObject child = childNode?.AsObject() ?? [];
            double grow = Number(child, "grow", 0.0);
            if (grow > 0.0) growTotal += grow;
            else fixedMain += Number(child, horizontal ? "width" : "height", 0.0);
        }
        double remaining = Math.Max(0.0, availableMain - fixedMain);
        bool scroll = node["scroll"]?.GetValue<bool>() ?? false;
        if (!scroll && fixedMain > availableMain + 0.01) diagnostics.Add($"{Text(node, "id", horizontal ? "row" : "column")}: fixed children consume {fixedMain:0.##} of {availableMain:0.##}.");
        double cursor = horizontal ? bounds.X : bounds.Y;
        for (int index = 0; index < children.Count; index++)
        {
            JsonObject child = children[index]?.AsObject() ?? [];
            double grow = Number(child, "grow", 0.0);
            double main = grow > 0.0 && growTotal > 0.0 ? remaining * grow / growTotal : Number(child, horizontal ? "width" : "height", 0.0);
            double cross = Number(child, horizontal ? "height" : "width", horizontal ? bounds.Height : bounds.Width);
            Rect childBounds = horizontal ? new Rect(cursor, bounds.Y, main, Math.Min(cross, bounds.Height)) : new Rect(bounds.X, cursor, Math.Min(cross, bounds.Width), main);
            LayoutNode(child, childBounds, scale, physicalWindow, elements, diagnostics, $"{Text(node, "id", "node")}.{index}");
            cursor += main + gap;
        }
    }

    private static void LayoutList(JsonObject node, Rect bounds, double scale, Rect physicalWindow, List<Element> elements, List<string> diagnostics)
    {
        Rect viewport = WidgetViewport(node, bounds, scale, physicalWindow, elements, "y", 2.0);
        double rowHeight = Number(node, "rowHeight", 30.0);
        int sampleRows = Math.Max(1, (int)Number(node, "sampleRows", Math.Floor(viewport.Height / rowHeight)));
        JsonArray cells = node["cells"]?.AsArray() ?? [];
        double fixedWidth = 0.0;
        double growTotal = 0.0;
        foreach (JsonNode? cellNode in cells)
        {
            JsonObject cell = cellNode?.AsObject() ?? [];
            double grow = Number(cell, "grow", 0.0);
            if (grow > 0.0) growTotal += grow;
            else fixedWidth += Number(cell, "width", 0.0);
        }
        if (fixedWidth > viewport.Width + 0.01) diagnostics.Add($"{Text(node, "id", "list")}: fixed cells consume {fixedWidth:0.##} of {viewport.Width:0.##}.");
        for (int row = 0; row < sampleRows && (row + 1) * rowHeight <= viewport.Height + 0.01; row++)
        {
            double x = viewport.X;
            for (int cellIndex = 0; cellIndex < cells.Count; cellIndex++)
            {
                JsonObject cell = cells[cellIndex]?.AsObject() ?? [];
                double grow = Number(cell, "grow", 0.0);
                double cellWidth = grow > 0.0 && growTotal > 0.0 ? Math.Max(0.0, viewport.Width - fixedWidth) * grow / growTotal : Number(cell, "width", 0.0);
                Rect cellRect = new(x, viewport.Y + row * rowHeight, cellWidth, rowHeight);
                string id = $"{Text(node, "id", "list")}.row{row}.{Text(cell, "id", "cell" + cellIndex)}";
                elements.Add(new Element(id, "list-cell", cellRect, ToPhysical(cellRect, scale, physicalWindow)));
                x += cellWidth;
            }
        }
    }

    private static void LayoutGrid(JsonObject node, Rect bounds, double scale, Rect physicalWindow, List<Element> elements, List<string> diagnostics)
    {
        int columns = Math.Max(1, (int)Number(node, "columns", 1.0));
        int rows = Math.Max(1, (int)Number(node, "rows", 1.0));
        double cellWidth = Number(node, "cellWidth", 40.0);
        double cellHeight = Number(node, "cellHeight", 40.0);
        double gap = Number(node, "gap", 2.0);
        double requiredWidth = columns * cellWidth + Math.Max(0, columns - 1) * gap;
        double requiredHeight = rows * cellHeight + Math.Max(0, rows - 1) * gap;
        string id = Text(node, "id", "grid");
        if (requiredWidth > bounds.Width + 0.01) diagnostics.Add($"{id}: grid width {requiredWidth:0.##} exceeds {bounds.Width:0.##}.");
        if (requiredHeight > bounds.Height + 0.01) diagnostics.Add($"{id}: grid height {requiredHeight:0.##} exceeds {bounds.Height:0.##}.");
        for (int row = 0; row < rows; row++)
        {
            for (int column = 0; column < columns; column++)
            {
                Rect cellRect = new(bounds.X + column * (cellWidth + gap), bounds.Y + row * (cellHeight + gap), cellWidth, cellHeight);
                elements.Add(new Element($"{id}.{row}.{column}", "grid-cell", cellRect, ToPhysical(cellRect, scale, physicalWindow)));
            }
        }
    }

    private static void LayoutShelf(JsonObject node, Rect bounds, double scale, Rect physicalWindow, List<Element> elements, List<string> diagnostics)
    {
        Rect viewport = WidgetViewport(node, bounds, scale, physicalWindow, elements, node["scroll"]?.GetValue<bool>() ?? false ? "y" : "none", 0.0);
        double unit = Number(node, "unit", 40.0);
        bool scroll = node["scroll"]?.GetValue<bool>() ?? false;
        List<(string Id, double Width, double Height)> items = [];
        JsonArray configuredItems = node["items"]?.AsArray() ?? [];
        for (int index = 0; index < configuredItems.Count; index++)
        {
            JsonObject item = configuredItems[index]?.AsObject() ?? [];
            items.Add((Text(item, "id", "item" + index), Number(item, "width", 1.0) * unit, Number(item, "height", 1.0) * unit));
        }
        items = items.OrderByDescending(item => item.Width * item.Height).ThenByDescending(item => item.Height).ToList();
        double x = viewport.X;
        double y = viewport.Y;
        double rowHeight = 0.0;
        foreach ((string id, double width, double height) in items)
        {
            if (x > viewport.X && (x + width > viewport.X + viewport.Width + 0.01 || Math.Abs(height - rowHeight) > 0.01))
            {
                x = viewport.X;
                y += rowHeight;
                rowHeight = 0.0;
            }
            Rect itemRect = new(x, y, width, height);
            elements.Add(new Element($"{Text(node, "id", "shelf")}.{id}", "shelf-item", itemRect, ToPhysical(itemRect, scale, physicalWindow)));
            x += width;
            rowHeight = Math.Max(rowHeight, height);
        }
        double usedHeight = y - viewport.Y + rowHeight;
        if (!scroll && usedHeight > viewport.Height + 0.01) diagnostics.Add($"{Text(node, "id", "shelf")}: packed height {usedHeight:0.##} exceeds {viewport.Height:0.##}.");
    }

    private static JsonObject BuildReport(string configPath, double screenWidth, double screenHeight, double scale, double logicalWidth, double logicalHeight, Rect physicalWindow, List<Element> elements, List<string> diagnostics)
    {
        JsonArray serializedElements = [];
        foreach (Element element in elements) serializedElements.Add(new JsonObject { ["id"] = element.Id, ["type"] = element.Type, ["logical"] = RectJson(element.Logical), ["physical"] = RectJson(element.Physical) });
        JsonArray serializedDiagnostics = [];
        foreach (string diagnostic in diagnostics) serializedDiagnostics.Add(diagnostic);
        return new JsonObject { ["config"] = configPath, ["screen"] = new JsonObject { ["width"] = screenWidth, ["height"] = screenHeight, ["uiScale"] = scale }, ["window"] = new JsonObject { ["logicalWidth"] = logicalWidth, ["logicalHeight"] = logicalHeight, ["physical"] = RectJson(physicalWindow) }, ["elements"] = serializedElements, ["diagnostics"] = serializedDiagnostics };
    }

    private static JsonObject RectJson(Rect rect)
    {
        return new JsonObject { ["x"] = Math.Round(rect.X, 2), ["y"] = Math.Round(rect.Y, 2), ["width"] = Math.Round(rect.Width, 2), ["height"] = Math.Round(rect.Height, 2) };
    }

    private static string BuildSvg(double screenWidth, double screenHeight, Rect physicalWindow, List<Element> elements, List<string> diagnostics)
    {
        StringBuilder svg = new();
        svg.AppendLine(FormattableString.Invariant($"<svg xmlns=\"http://www.w3.org/2000/svg\" width=\"{screenWidth:0}\" height=\"{screenHeight:0}\" viewBox=\"0 0 {screenWidth:0} {screenHeight:0}\">"));
        svg.AppendLine("<rect width=\"100%\" height=\"100%\" fill=\"#101820\"/>");
        svg.AppendLine(RectSvg(physicalWindow, "#090909", "#d3a64c", 4.0));
        foreach (Element element in elements.Where(element => element.Id != "root"))
        {
            string fill = element.Type == "grid-cell" ? "#323b48" : element.Type == "list-cell" ? "#28323d" : "#18232e";
            svg.AppendLine(RectSvg(element.Physical, fill, "#8293a6", 1.0));
            if (element.Physical.Width >= 70.0 && element.Physical.Height >= 24.0) svg.AppendLine(FormattableString.Invariant($"<text x=\"{element.Physical.X + 5.0:0.##}\" y=\"{element.Physical.Y + 18.0:0.##}\" fill=\"#e8e8e8\" font-family=\"Segoe UI\" font-size=\"14\">{EscapeXml(element.Id)}</text>"));
        }
        if (diagnostics.Count > 0) svg.AppendLine($"<text x=\"20\" y=\"30\" fill=\"#ff6060\" font-family=\"Segoe UI\" font-size=\"20\">{diagnostics.Count} layout warning(s)</text>");
        svg.AppendLine("</svg>");
        return svg.ToString();
    }

    private static string RectSvg(Rect rect, string fill, string stroke, double strokeWidth)
    {
        return FormattableString.Invariant($"<rect x=\"{rect.X:0.##}\" y=\"{rect.Y:0.##}\" width=\"{Math.Max(0.0, rect.Width):0.##}\" height=\"{Math.Max(0.0, rect.Height):0.##}\" fill=\"{fill}\" stroke=\"{stroke}\" stroke-width=\"{strokeWidth:0.##}\"/>");
    }

    private static Rect ToPhysical(Rect logical, double scale, Rect physicalWindow)
    {
        return new Rect(physicalWindow.X + logical.X * scale, physicalWindow.Y + logical.Y * scale, logical.Width * scale, logical.Height * scale);
    }

    private static JsonObject RequireObject(JsonObject parent, string name)
    {
        return parent[name]?.AsObject() ?? throw new InvalidDataException($"Missing object '{name}'.");
    }

    private static double Number(JsonObject node, string name, double fallback)
    {
        return node[name]?.GetValue<double>() ?? fallback;
    }

    private static string Text(JsonObject node, string name, string fallback)
    {
        return node[name]?.GetValue<string>() ?? fallback;
    }

    private static string? TakeOption(List<string> arguments, params string[] names)
    {
        for (int index = 0; index < arguments.Count; index++)
        {
            if (!names.Contains(arguments[index], StringComparer.OrdinalIgnoreCase)) continue;
            if (index + 1 >= arguments.Count) throw new ArgumentException($"{arguments[index]} requires a value.");
            string value = arguments[index + 1];
            arguments.RemoveRange(index, 2);
            return value;
        }
        return null;
    }

    private static string EscapeXml(string value)
    {
        return value.Replace("&", "&amp;").Replace("<", "&lt;").Replace(">", "&gt;").Replace("\"", "&quot;");
    }

    private static int Fail(string message)
    {
        Console.Error.WriteLine(message);
        return 1;
    }
}
