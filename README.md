# dx-gui (A work in progress)

Making gui with dx-gui is easy:

```lua
-- Create a window
local win = Window(0, 0, 800, 600,'cool window')
win.align('center')

-- Add a couple of buttons
local btn1 = Button(50, 50, 150, 60, 'click me')
btn1.setParent(win)
btn1.on('click', function() btn1.value = 'clicked' end)

local btn2 = Button(50, 120, 150, 60, 'click me too')
btn2.setParent(win)
btn2.on('click', function() btn2.value = 'clicked' end)
```

For more examples check the *demo.lua* file.

# License

Copyright 2018 Tails

Licensed under the AGPLv3: https://www.gnu.org/licenses/agpl-3.0.html
