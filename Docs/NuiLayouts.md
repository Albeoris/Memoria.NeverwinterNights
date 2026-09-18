# NUI layout validation

NUI layout fixtures model the usable content viewport rather than the outer window rectangle. The engine consumes 24 logical pixels horizontally and 49 vertically for window chrome and content insets; `NuiLayoutTool` uses those values by default. A fixture may set `horizontalInset` or `verticalInset` only when the corresponding runtime window deliberately uses different measured values.

Conditional controls hidden with `NuiVisible` still consume layout space. Mutually exclusive editor sections should therefore share one fixed group and replace its contents with `NuiSetGroupLayout`. Set `minimumSlack` on fixed rows or columns that must retain an explicit safety margin instead of packing controls against the viewport boundary.
