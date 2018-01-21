# Music-Composition-and-Figured-Bass-realization
MATLAB code that composes 4-part harmony (soprano, alto, tenor, bass) music from a user-input bass line and optional figured bass and other notes.

The program features a GUI that allows the user to input bass notes (up to 11), any figures (e.g. 6, #3) and/or notes in other voices, and the maximum amount the voices are allowed to leap between notes. The GUI also supports audio playback of the composition and can display an example. The program selects notes at random that satisfy commonly-accepted rules of counterpoint, such as avoiding parallel fifths and octaves and avoiding voice crossing. As such, the user can generate multiple compositions using the same input by pressing the button repeatedly.

The current version is focused on harmony and does not support complicated rhythms. Additionally, the program was designed with the ability to change key in mind, but the current GUI does not yet implement a mechanism to change the key signature, so only C major/A minor is supported unless the user manually inputs accidentals.
