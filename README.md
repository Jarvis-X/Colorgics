# Colorgics
## Processing 3 with java syntax
  This toy program allows users to level-wisely enter logic expressions and converts them into readable ones. Then based on several rules, an animation representing the expression will show up. 
  ## features: 
  The program works for both propositional and predicate logic. And the animations for predicate logic expressions are highlighted.
  A bonus feature will reveal with a key press. It is ugly and looks crazy. Try with Tab.
  ## Instructions: 
  Enter main connectors and the number of arguments it connects at the current level from left to right. If the main connector connects an expression from next level, enter a space. 
  ### E.g., we have (A&B)|(C&~D), then:
  * level 1 : |2
  * level 2 : &2&2
  * level 3 : ' ' ' ' ' ' ~1
  * level 4 : ABCD
  * Press Enter twice
  ### E.g.2, we have (/x (A(x)|B(x))), then:
  * level 1 : /x1
  * level 2 : |2
  * level 3 : A(x)B(x)
  * Press Enter twice
  ## Known issues:
  Biconditions do not work right now! They will be drawn as implications.
  Some errors crash the program immediately.
  Not so colorful as I imagined.
