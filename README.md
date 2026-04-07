# DrummingGame
This is a rhythm game which can use an electronic drum kit as input. Users can upload their own audio files and create levels to play through. The goal is to accurately time hits to the beat of the level.
## How to run:
First, clone the repository using:
```sh
git clone "https://github.com/PetrucciCarl/DrummingGame.git"
```
After downloading, go to the _'drumming-game'_ directory using:
```sh
cd drumming-game
```
Then, install the required gems using:
```sh
bundler install
```
Then, delete the _.gitkeep_ file in the _'levels'_ directory as it is no longer needed:
```sh
del levels/.gitkeep
```
Then run the program using:
```sh
ruby main.rb
```
## How to play:
from the main menu, users will have two options:
1. **Play** an existing level
2. **Create** a new level
### Playing a level
For a user to play using their electronic drum kit as input, they must have their drum kit connected to their computer before running the program.
Alternatively, a user can use the space bar.

Upon selecting _'Play'_ users will see a file dialogue open up.
By default, this file dialogue will open the _'levels'_ directory.
Select a level file to begin playing. _*note that the program will not work if file is in an incorrect format or the path to the audio file is no longer valid. Additionally, the program may freeze and need to be terminated if the file dialogue is closed without selecting a file_

When the level begins, you will see musical notes move from the right hand side of the screen to the left hand side of the screen. When you hit the snare drum or press space, you will score points based on how close the notes are to the drum stick being displayed on the screen. A level will finish when there are no more notes to hit, and you will recieve a final score.
### Creating a level
Upon selecting _'Create'_ users will see a file dialogue open up.
Users are excpected to select an audio file which will be the background music for the level being created. _*note that the program may freeze and need to be terminated if the file dialogue is closed without selecting a file_

Users can hover their mouse over or around the general area of a musical note and then click on it to set it to 'active' meaning that a user will have to hit it in the level. Users can scroll to view and edit notes earlier and later in a level. If a user clicks _'Add'_, a new note is added to the level. If a user hovers over the _'BPM'_ and scrolls, they can change the beats per minute (how quickly the notes will move in the level) to any value between 1 and 240. If a user clicks _'Test'_, the selected audio track will begin playing, and active notes will turn green indicating when the player would need to hit in while playing the level.

Click _'Save & Exit'_ to save your level and return to the main menu.
A file dialogue will open up allowing you to name your level, and choose where it is saved to.
By default, levels will be saved in the 'levels' directory, it is not reccomended that you save them elsewhere.
## Acknowledgments
The typeface 'White on Black' used in this code project was downloaded from https://www.imagex-fonts.com/planche.php?idPolice=263 on the 28th of May 2025.
## Disclaimers
Code in this project may look a little strange. This was partially due to the fact that this was made as a project for univerisity, and there were some atypical coding requirements. Additionally, it took a while to get all of the gems working properly, this program currently works well for Windows 11 on Ruby (32 bit) version 3.3.8, but it may not work well on different versions or different operating systems.
