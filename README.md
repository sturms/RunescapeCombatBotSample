# RunescapeCombatBotSample
Sample combat bot for game "Runescape" which was created for fun in about 1 week to learn basics of scripting language- "AutoIt".
Would not really recommend using it nowadays.. as it was created in 2017 and when using it I got banned after some time when using it. The problem most likely was that there needed more random actions to be performed. 

What this script includes (see the actual GUI- preview.png):
It allows to customize the food, enemies and teleport. 
The total time in combat can also be set. If the provided time is empty then the character will fight until there is no food left.
If the teleport tablet/spell is chosen then after there is no food left, the character will use it and the bot will stop.
If "Rest after while parameters" are set then after time in combat user will exit to lobby and wait there until resting duration is reached. After that will log back in and continue combat.

You can also store your desired combat parameters in an XML file and upload depending on what lvl area you will fight!
For example, in Stronghold when fighting red taurens the template would look something like this:

`<?xml version="1.0"?><RSCombatBot>
<Params>
<Param name="FoodColor">
<Color>12409872</Color>
</Param>
<Param name="EnemyTarget">
<Color>11908476</Color>
</Param>
<Param name="TeleportToHome">
<Color>5919827</Color>
<Enabled>True</Enabled>
</Param>
<Param name="TakeABreakAfterSomeTime">
<FightingDuration>60</FightingDuration>
<RestingDuration>10</RestingDuration>
<ExitToLobbyButtonPosX>1276</ExitToLobbyButtonPosX>
<ExitToLobbyButtonPosY>856</ExitToLobbyButtonPosY>
<Enabled>True</Enabled>
</Param>
</Params>
</RSCombatBot>`

