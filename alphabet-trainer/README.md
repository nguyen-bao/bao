## Alphabet Trainer
Inspired by challenges to type the entire alphabet as fast as you can, alphabet trainer is a program to help you get faster at typing
- trains against `abcdefghijklmnopqrstuvwxyz` by default but custom strings can be used
- after a successful attempt, trainer will display how long it took in total and how long to type each character
  - this may be used to pinpoint weaknesses or slow spots, which you may then train individually using the custom string trainer
- after a failed attempt, trainer will display how long it took and show a diff between the user's input and the expected string
  - this may show a frequently missed sequence of characters, which can be trained on
- while typing, trainer will show a running timer and a diff between the user's input so far and the expected string

Challenges
- using python's curses library along with python multithreading (for the timer)
- taking real-time user input (including backspaces) and displaying it in curses
