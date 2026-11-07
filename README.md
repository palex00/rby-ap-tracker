# Archipelago Pokémon Red & Blue Tracker
<img width="1920" height="1040" alt="grafik" src="https://github.com/user-attachments/assets/7b7e783e-6016-4012-995d-1df239c14431" />


This is a tracker package for Poptracker. It features auto-tracking with Archipelago.

## Installation

Just download the latest release and put it in your packs folder.
This will auto-update with every new release I put out!

## Explanations

### Event Tracking
This tracker tracks in-game Events automatically. Purchasing the stones in the Celadon Dept. Store with disabled Stonesanity is still manual.

### Encounter & Pokédex Related
The tracker can currently not track which Pokémon you have obtained or where which Pokémon is. It will show you what Pokémon are Dexsanity Checks and which dexsanity checks have been sent out already.

The overworld map that contains location can also show you the total amount of Pokémon per route. Your encounter distribution ("Full"-Mapping or "1:1"-Mapping) is automatically set. 
You can hide / show encounter locations with the setting toggle in the "Tools"-section.
When shown, every submap that contains encounters will have a diamond in the top left for its wild encounters. Static encounters are shown on the actual location of the static Pokémon on its submap.

This is **entirely manual tracking**, however if you do not click "Reset" your progress will be saved between sessions based on your Seed-ID and you do not need to export / import, even when switching room. I recommend you to export / import though.

### (Manual) Entrance Tracking / Door Tracking
This tracker features accurate entrance tracking which, however, is **manual**.

It will automatically determine your Door Shuffle Mode for your slot and show / hide entrances based on that. Entrances are shown as trapezoids. Vanilla entrances still have their overview-squares.

**Linking Mode**
To link two entrances, left-click the first entrance ("from") and then the second entrance ("to"). You need to specifically click the "Entrance"-image on the Entrance location that appears when hovering over the square / trapezoid.
This also works with Decoupled Mode, it is direction-sensitive.
To cancel an active linking-in-progress or to clear a specific mapping, you can click on the options in the ER-Linking diamond which appears everywhere once you entered Linking Mode. 

**Routing Mode**
You can right-click an entrance ("from") and then a second entrance ("to") to activate Routing Mode. This will tell you which entrances to take to go from Entrance A to Entrance B.
If you right-click the same entrance twice, the routing will start from Pallet Town.
In this mode, the entrances you need to traverse will also blink.
Routing Mode considers Fly and Returning to Home if it is a faster alternative than normal walking.

**Tools-Section**
These are various quick settings that help you configure the pack.
You can hover over any of these to get a short description in the top-right corner of poptracker. But to shortly explain:
- Show / Hide Locations
- Show / Hide Encounter Locations
- Auto-Track Map. This tabs you to the submaps you are on with certain guidelines:
  - MOST: Tabs to all submaps that have checks
  - MIN: Tabs to all submaps that have more than one check (legacy behavior)
  - OFF: Does not tab you
  - ALL: Tabs to all submaps (automatically chosen when Door Shuffle is detected in your slot)
- Split Mode (Off / On / Reverse): Lets you have submap on one side of the poptracker and the overworld map on the other
- SGB Mode: Switch between SGB-colors and grayscale (original gameboy colors)
- Hide Cleared Locations: Hides any location that is cleared. This is different from poptracker's CTRL+H behavior as that can only show/hide full squares and not locations

**ER-Tools**
You can hover over any of these to get a short description in the top-right corner of poptracker. But to shortly explain:
- Entrance Icon: Hide / Show all Entrances
- RTNG: Whether the "Routing"-tab appears over the Overworld Map or the Submap Maps.
- HM Fly-Icon: Whether Routing can tell you to Fly to a place. Poptracker doesn't know if you've been to a town yet so if you want to know how something has come into logic in the first place, turn this off so it doesn't tell you to just Fly to it, like an Idiot.
- "ER" with an arrow around it: This clears all ER connections without being able to restore them. Do this at the start of a new slot. This is not restorable.

## ROADMAP
With support from Alchav and GerbilJames I will bring this Tracker more up to par with the Crystal, FRLG and Emerald one. Features soon to be added include:
- Dexsanity Support
- Full Encounter Tracking

## Credits
- Thanks to GerbilJames for the PRs to allow for Event & Map Tracking
- Thanks to darkfire for doing hours of manual work placing squares, making images and more
- Thanks to insaneau for reviving the project and providing map images for an earlier version