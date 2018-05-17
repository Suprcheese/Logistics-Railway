Logistics Railway 1.0.8
=======================

Version 1.0.8 was released May 16, 2016, was tested using Factorio v0.12.33, and was authored by Supercheese, with contributions from: TheAIBot, Choumiko, and operations.

This mod allows you to load/unload your trains using your logistics robots! You don't need to change your trains at all -- simply replace some of your normal rail segments with one of the types of special Logistics Rails and any cargo wagon that stops on those rails will be automagically converted into a Logistics Wagon of the associated type.
Then you can remove your inserters and chests and use only bots!
For example: If a wagon stops on top a Passive Provider rail, then its contents will be provided directly to the logistics network just like a passive provider chest.
You can, additionally, determine visually when a regular wagon becomes a Logistics Wagon when its alt-view cargo icons shrink in size.
In order to use Requester Rails, click them to set the logistics requests for any wagon that stops on top of them. You can, of course, copy/paste between Requester Rails just like with regular Requester Chests.
You can even use Requester Rails to automatically fuel up your locomotives! Please be careful to only request valid fuel items into locomotives, as all non-fuel items that cannot be inserted into locomotives will be destroyed. Also note that locomotives cannot use the other three types of rail.

The recipe for all Logistics Rails is merely a single regular rail piece, and when you remove a Logistics Rail, you receive a regular rail, for maximum flexibility.
If this recipe seems to cheap to you, it can be changed in the configuration file.


Known Issues/Quirks:
--------------------

Any time a Cargo Wagon becomes a Logistics Wagon, its inventory is dumped into a separate invisible entity, and it is in fact that entity that interacts with the logistics network.
When its inventory has been given to the other entity, the wagon's regular inventory is emptied and you are prevented from inserting/removing items by hand, unless you manually stop the train.

Requester Rails have a dummy item (control panel icon) auto-inserted on creation. This allows them to have logistics requests set but not actually request any items until a wagon comes along.
Please do not remove the control panel item. You needn't concern yourself with it, as it will be properly dealt with by the mod code.

Sadly it seems that you cannot quick-replace regular rails with Logistics Rails, even after setting the appropriate property in the entity prototypes, but you can rotate the logistics rails by 90° and then place them over the existing rails, then re-place them in the proper orientation.

Logistics rails can only be placed horizontally or vertically. You really wouldn't want to make a diagonal loading/unloading station anyway... would you?
It is possible to get stuck in a diagonal building mode, however, if you grab some regular Straight Rails, rotate them diagonally, then immediately grab some Logistics Rails.
If this happens to you, fret not, for if you try to place a Logistics Rail diagonally, the mod will automatically return you to orthoganal rail placement.
You are also not allowed to place ghost-diagonals of Logistics Rails.

While regular Straight Rails can overlap, Logistics Rails cannot.

This mod is NOT compatible with other mods that introduce logistics wagons such as 5dim Trains. It is, however, compatible with Bob's mods, Stainless Steel Wagon, and other such wagon mods that don't use control.lua.


Credits:
--------

I was originally inspired to make this mod by a conversation on IRC between Afforess and Fatmice. Props to you guys for coming up with the idea!

5dim Trains has Logistics Wagons, but they are locked into always being requesters or providers, and don't change based on the rails beneath them.
Nonetheless, it was that mod that also provided inspiration to create this one, although they do not share any code or graphics.

I extend thanks to TheAIBot for simplifying some duplicated code segments.

Courtesy of Choumiko, Logistics Railway is compatible with his Smart Trains mod.

New functionality arrived in v1.0.6 to deal with filters set on cargo wagons, thanks to operations: https://forums.factorio.com/viewtopic.php?p=143658#p143658

This mod makes use of the Factorio Standard Library by Afforess (https://github.com/Afforess/Factorio-Stdlib).

The control panel icon used for Requester Rails was obtained from: https://www.iconfinder.com/icons/171951/calculator_icon
That page states: "License: Free for non commercial use".

All other graphics are modified from Factorio base assets.

Thanks to the forum and #factorio IRC denizens for camaraderie, advice, & bugtesting.

See also the associated forum thread to give feedback, view screenshots & tutorials, etc.:

https://forums.factorio.com/viewtopic.php?f=93&t=21462
