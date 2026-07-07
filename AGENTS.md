# Agent notes

## GTA / FiveM clothing & appearance values

Look up freemode component, prop, overlay, and colour IDs on the **RAGE Multiplayer wiki**:

- https://wiki.rage.mp/wiki

Useful pages:

| Topic | Page |
| --- | --- |
| Clothes & props (component / prop IDs) | https://wiki.rage.mp/wiki/Clothes |
| Head overlays (facial hair, eyebrows, …) | https://wiki.rage.mp/wiki/Player::setHeadOverlay |
| Overlay colour (beard / brow / makeup tint) | https://wiki.rage.mp/wiki/Player::setHeadOverlayColor |
| Hair / facial-hair colour palette | https://wiki.rage.mp/wiki/Hair_Colors |
| Head blend (required before overlays/hair tint) | https://wiki.rage.mp/wiki/Player::setHeadBlendData |

### Head overlays (freemode)

Overlay ID **1** is facial hair (indexes **0–28**; **255** disables). Colour type **1** uses the hair colour palette.

`SetPedHeadOverlay` / `SetPedHairColor` only take effect after `SetPedHeadBlendData` has been applied on the ped.
