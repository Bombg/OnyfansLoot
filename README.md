# OnyFans Loot
The loot list addon for OnyFans

## Features
- Shows whose next in line for an item
    - When holding alt over an item in your character sheet
    - When holding alt while clicking an item link
    - When holding alt before hovering over a corpse item
    - When holding alt before hovering over AtlasLoot tooltip
- Import a loot list from CSV 
    - Validates Itemnames by cross checking with AtlasLoot
    - Validates player names by cross checking with the in game guild list
    - Validates dates (list active, 1/2 active) 
    - Doesn't add players to a list who have not reached list active or 1/2 active
    - Takes attendance modifier into account when making the list
- Loot master features
    - Automatically broadcasts boss loot drops if looted by a master looter
    - Pre-made blacklist of items so nonsense items aren't broadcasted
- Loot tracking features
    - Broadcasts loot drops to other OnyFansLoot users who are out of range to recieve "so and so recieves xxxx" messages
    - Keeps track of dropped items that are on any players list and who got that item
    - Keeps track of all raid drops
    - Export these with the '/of export' or '/of export help' command

## Screenshots & Gifs
- Holding Alt over an inventory item

<img src="https://i.imgur.com/B7ki26u.gif" width =400><br><br>

- Holding Alt while clicking a chat link

<img src="https://i.imgur.com/4FZsbb9.gif" width =400><br><br>

- Holding Alt before hovering over mob loot

<img src="https://imgur.com/2NKiDRo.gif" width =400><br><br>

- Holding Alt before hovering over AtlasLoot tooltip

<img src="https://imgur.com/qKaG967.gif" width =400><br><br>

## Installation
1. Download OnyFans Loot
2. Unzip
3. Rename the unzipped folder to "OnyfansLoot"
4. Copy or cut the now renamed "OnyfansLoot" and paste it into Interface\AddOns
5. Restart World of Warcraft 
6. Wait for an automatic list update (if someone else is importing) OR Import the latest list via the /of import command (read instructions)

## Limitations
- If any of the items in the loot list or master loot list are misspelled this won't work
- For now, this does not update the list when people get items from their list 
    - List updates are sent out by whomever imports the list from csv
- Before importing from CSV, all items with strikethrough need to be deleted. Unfortunately strikethough cannot be put into a CSV.

## Commands
- Every command starts with /of or /onyfansloot. The examples will be using /of but /onyfansloot will work too.
- /of help - Bring up a list of commands
- /of export - bring up a logged list of drops from the last raid (if there's more than 1 raid that day, may need to use other commands)
- /of export n - where n is between 1 and 5. This will give you easy access to the last five raids that you've been in. For example /of export 3
- /of export help - bring up a list of raid keys. You can then copy a key to use in the next command
- /of export key - where key is one of the copy pasted keys you got from the '/of export help' command. This gives you access to all the raids you've been in
- /of import - brings up a window where you can paste in a loot list in CSV format. 
    - WARNING: Delete everything in this window before pasting in the CSV
    - WARNING - Remove any loot list items with strikethrough before converting to CSV and importing
    - once the list has been imported, a window will pop up showing any errors with spelling in item names, guild member names, and date errors
- /of stage - once you have cleared any erros with the import(or satisfied), this command will allow you to test the changes before you send them to anyone else.
- /of commit - If you are satisfied with how the list was staged, you can commit these changes. They will then be sent out to everyone else (assuming higher list version)

## How to Import From CSV
**** IT IS HIGHLY RECOMMENDED YOU HAVE [AtlasLoot](https://github.com/Lexiebean/AtlasLoot/) INSTALLED ****
1. Go to the lootlist Google spreadsheet hit ctrl+a to highlight everything and ctrl+c to copy everything
2. Paste a copy of the sheet in a completely new Google spreadsheet somewhere else. This is so you can modify it
3. Delete any item cell that has strikethrough. Strikethrough is lost when converting to CSV, so get rid of any cell with it now
4. go to File>Download> Comma Separated Values(.csv) to download the CSV
5. Open the CSV file in the text editor of your choice. Notepad works. DONT OPEN WITH EXCEL OR OTHER SPREADSHEET SOFTWARE
6. With the CSV text window open, hit ctrl+a to highlight everything, and ctrl+c to copy everything. 
7. Open or tab over to WoW, and type in the '/of import' command
8. Click inside the import window so your cursor is inside it, and then hit ctrl+a and then backspace to remove the instructions there
9. With your now clear import window, hit ctrl+v to paste in the previously copied CSV text 
10. Hit Save, a window after will pop up showing any errors. Fix these errors in your spreadsheet and repeat steps 4-10
11. Once all errors are cleared (at least the ones you care about) use the command '/of stage" to preview the loot list changes
12. The stage command will reset if you reload the game or UI. It just previews the changes to tooltips. 
13. If everything is as you hoped/excepted you can make this list official and share it by using the '/of commit' command
14. Congrats you have now imported your list! It will be shared to other guildmates after a few minutes.



