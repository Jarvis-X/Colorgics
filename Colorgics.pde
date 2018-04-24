// MIT License
//
// Copyright (c) 2018 Jarvis. X.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

// This program makes use of the MapNested by RolandRitt and Matlab Robotics
// Toolbox by Peter Corke

// two different font formats
PFont f1;
PFont f2;
PFont f_expression;

// The object saves the hirachy of the expressions
ArrayList<ArrayList<Tuple<String, Integer>>> levels =
  new ArrayList<ArrayList<Tuple<String, Integer>>>();

// The object saves all the argument names on the bottom level
ArrayList<String> arguments = new ArrayList<String>();

// The object saves all the symbols representing the same level
ArrayList<String> level_symbols = new ArrayList<String>();

// Variable to store text currently being typed
String typing = "";
// Variable to store saved text when return is hit
String saved = "";
// Variable that indicates if the typying is finished
boolean complete_flag = false;
// Variable that controls displayDensity()
boolean ready_flag = false;
// something silly
boolean uglycolor = false;
// something smart
int c = 1;

void setup() {
  size(1920, 1080);
  rectMode(RADIUS);
  surface.setResizable(true);
  smooth();
}

// the function showing the texts
void draw() {
  colorMode(RGB);
  if (c<510) {
    c++;
  } else {
    c = 1;
  }
  clear();
  if ( !ready_flag ) {
    if (uglycolor) {
      // if (millis()%(c+1) == 0) {
        generaterandomcolor(true);
      // }
    } else {
      background(100, 149, 237);
    }
    int indent = width/2 ;

    // Set the font and fill for text
    f1 = createFont("", width/60, true);
    f2 = createFont("", width/50, true);
    f_expression = createFont("", width/30, true);
    textFont(f1);
    fill(220, 220, 150, 200);
    // Display everything
    textAlign(CENTER, CENTER);
    text("Please enter the logic expression.", indent, height/27);
    text("~ Stands for negation (\u00AC).", indent, 2 * height/27);
    text("& Stands for conjunction (\u2227).", indent, 3 * height/27);
    text("| Stands for disjunction (\u2228).", indent, 4 * height/27);
    text("$ Stands for implication (\u2192).", indent, 5 * height/27);
    text("% Stands for biconditional (\u2194).", indent, 6 * height/27);
    text("/ Stands for existential (\u2203).", indent, 7 * height/27);
    text("@ Stands for universal (\u2200).", indent, 8 * height/27);
    fill(180, 135, 200, 200);
    text("f12 to start new expression.", indent, 9 * height/27);
    text("f11 to delete last line.", indent, 10 * height/27);

    // If enter key is pressed, the expression is complete
    // and it shown on the screen
    // else show the partially complete expression
    fill(255, 255, 150, 200);
    if (complete_flag == false) {
      String texttoshow = "";
      for (int i=0; i<=level_symbols.size(); i++) {
        texttoshow = texttoshow + "Level " + (char)(i+'1') + ": " + ((i>=0&&i<level_symbols.size())?level_symbols.get(i):typing) + "\n";
      }
      textAlign(CENTER, TOP);
      text(texttoshow, indent, 12 * height / 27);
      // if an expression is fully entered, reassemble it to be readable
    } else {
      reassemble();
      textFont(f2);
      fill(255, 255, 150, 200);
      text(saved, indent, 12 * height / 27);
    }
    // if visualization is ready
  } else {
    ArrayList<Integer> symbol_numbers = new ArrayList<Integer>();
    background(255);
    int indent = width/2 ;
    f1 = createFont("", width/60, true);
    textFont(f1);
    fill(85, 107, 47, 222);
    textAlign(CENTER, CENTER);
    text("press f12 to start a new expression.", indent, 2*height/27);
    colorMode(HSB);
    drawexpression();
  }
}

void keyPressed() {
  // if tab is Pressed, do something ugly
  if (keyCode == 9) {
    uglycolor = !uglycolor;
    // if f12 is pressed, restart the typing
  } else if (!complete_flag) {
    if (keyCode == 123) {
      newexpression();
      // if f11 is pressed, delete last line of expression
    } else if (keyCode == 122) {
      if (typing.length() == 0) {
        level_symbols.remove(level_symbols.size()-1);
        levels.remove(levels.size()-1);
      } else {
        typing = "";
      }
      // If the return key is pressed, save the String and clear it
    } else if (key == '\n') {
      int  i = 0;
      // convert a string to the array of arguments
      while(i < typing.length()) {
        if (i+1<typing.length()) {
          if(typing.charAt(i+1)=='(') {
            int j = 2;
            while(typing.charAt(i+j)!=')') {
              j++;
            }
            arguments.add(typing.substring(i, i+j+1));
            i+=(j+1);
          } else {
            arguments.add(typing.substring(i, i+1));
            i++;
          }
        } else {
          arguments.add(typing.substring(i, i+1));
          i++;
        }
      }
      typing = "";
      complete_flag = true;
      // delete the last char if backspace is pressed
    } else if (keyCode == BACKSPACE) {
      if (typing.length() > 0) {
        typing = typing.substring(0, typing.length()-1);
      }
      // delete the whole string if delete is pressed
    } else if (keyCode == DELETE) {
      typing = "";
      // if plus( the one on the numpad or the one needs SHIFT) is pressed,
      // add the symbol to a new level
    } else if (keyCode == 107 || keyCode == 61) {
      ArrayList<Tuple<String, Integer>> samelevel = new ArrayList<Tuple<String, Integer>>();

      // parsing the same level
      int i = 0;
      while(i < typing.length()) {
        // if predicate:
        if(typing.charAt(i)=='@'||typing.charAt(i)=='/') {
          String symbol = "";
          // Make them readible for logicians
          if (typing.charAt(i)=='@') {
            symbol = "" + '\u2200' + typing.charAt(i+1);
          } else {
            symbol = "" + '\u2203' + typing.charAt(i+1);
          }
          Integer num = new Integer(typing.charAt(i+2)-48);
          Tuple<String, Integer> element = new Tuple<String, Integer>(symbol,num);
          samelevel.add(element);
          i+=3;
          // else if propositional:
        } else if ( typing.charAt(i)=='|'|| typing.charAt(i)=='&'||
                    typing.charAt(i)=='$'|| typing.charAt(i)=='%'||
                    typing.charAt(i)=='~') {
          String symbol = "";
          // Make them readible for logicians
          if ( typing.charAt(i)=='|' ) {
            symbol = "" + '\u2228';
          } else if ( typing.charAt(i)=='&' ) {
            symbol = "" + '\u2227';
          } else if ( typing.charAt(i)=='$' ) {
            symbol = "" + '\u2192';
          } else if ( typing.charAt(i)=='%' ) {
            symbol = "" + '\u2194';
          } else {
            symbol = "" + '\u00AC';
          }
          Integer num = new Integer(typing.charAt(i+1)-48);
          Tuple<String, Integer> element = new Tuple<String, Integer>(symbol,num);
          samelevel.add(element);
          i+=2;
          // else if reiteration
        } else if (typing.charAt(i)==' ') {
          String symbol = " ";
          Tuple<String, Integer> element = new Tuple<String, Integer>(symbol, 1);
          samelevel.add(element);
          i++;
        } else {
          System.err.println("Error: Not a valid logic symbol:");
          System.out.println(typing.charAt(i));
          System.exit(1);
        }
      }
      // after finishing the same level parsing, save them into that level and
      // clear the temp text
      String modified_typing = "";
      levels.add(samelevel);
      for ( Tuple<String, Integer> tuples : samelevel ) {
        modified_typing += (tuples.x + (char)(tuples.y.intValue()+'0'));
      }
      level_symbols.add(modified_typing);
      typing = "";
      // Otherwise, concatenate the String with a list of exceptions
      // if enter is pressed, assign variables to the expression, assemble the
      // logic arguments
    } else if ( keyCode != SHIFT && keyCode != CONTROL && keyCode != ALT &&
                keyCode != LEFT && keyCode != RIGHT && keyCode != UP && keyCode != DOWN &&
                keyCode != 20 ) {
      typing = typing + key;
    }
  } else if (key == '\n') {
    ready_flag = true;
    // if f12 is pressed, restart the typing
  } else if (keyCode == 123) {
    newexpression();
  }
}

// The function reassembles the levels of the expression and gives the right
// format of it
void reassemble() {
  // prepare the arguments for each level
  ArrayList<String> args_for_level = new ArrayList<String>(arguments);
  ArrayList<String> args_after_level = new ArrayList<String>();

  // from bottom level to upper levels
  for (int i = levels.size()-1; i>=0; i--) {
    // on one single level
    ArrayList<Tuple<String, Integer>> thelevel = new ArrayList<Tuple<String, Integer>>(levels.get(i));
    int j = 0; // this variable tracks how many arguments we have used for this level

    for (Tuple<String, Integer> oneconnector : thelevel) {
      // get how many arguments it needs
      int num_of_args = oneconnector.y.intValue();
      if ( num_of_args == 1 ) {
        // if a carry-on symbol is detected, then just pass the argument
        if (oneconnector.x == " ") {
          args_after_level.add(args_for_level.get(j));
          // if a negation is dtected
        } else if (oneconnector.x == "\u00AC" ) {
          args_after_level.add(oneconnector.x + args_for_level.get(j));
          // or it is a predicate
        } else {
          args_after_level.add("(" + oneconnector.x + " " + args_for_level.get(j) + ")");
        }
        // if the connector connects more than one argument
      } else {
        String temp = "(" + args_for_level.get(j);
        for (int k = j+1; k< j+num_of_args; k++){
          temp += (oneconnector.x + args_for_level.get(k));
        }
        temp += ")";
        args_after_level.add(temp);
      }
      // move to the first argument of the next connector
      j += num_of_args;
    }
    //
    args_for_level.clear();
    args_for_level.addAll(args_after_level);
    args_after_level.clear();
  }
  saved = args_for_level.get(0);
}

void newexpression(){
  levels.clear();
  arguments.clear();
  level_symbols.clear();
  typing = "";
  saved = "";
  complete_flag = false;
  ready_flag = false;
  uglycolor = false;
}

// A tuple class implemented to save expressions on each level
public class Tuple<X, Y> {
  public final X x;
  public final Y y;
  public Tuple(X x, Y y) {
    this.x = x;
    this.y = y;
  }
  public Tuple(Tuple<X, Y> oldTuple) {
    this.x = oldTuple.x;
    this.y = oldTuple.y;
  }
}

// a function that generates polygons
void polygon(float x, float y, float radius, int npoints) {
  float angle = TWO_PI / npoints;
  beginShape();
  for (float a = 0; a < TWO_PI; a += angle) {
    float sx = x + cos(a) * radius;
    float sy = y + sin(a) * radius;
    vertex(sx, sy);
  }
  endShape(CLOSE);
}

// this function draws the picture according to the levels
void drawexpression( ) {
  background(255);
  color thecolor = color(255);
  if (uglycolor) {
    thecolor = generaterandomcolor(false);
  }
  float allcenterx = width*0.5;
  float allcentery = height*0.5;
  pushMatrix();
  translate(allcenterx, allcentery);
  // better if the shapes can rotate
  rotate(radians(millis()/30));
  // two arraylists that store graphic info
  ArrayList<Tuple<Tuple<Float, Float>, Float>> this_level_info = new ArrayList<Tuple<Tuple<Float, Float>, Float>>();
  ArrayList<Tuple<Tuple<Float, Float>, Float>> next_level_info = new ArrayList<Tuple<Tuple<Float, Float>, Float>>();
  // initializing top level infomation:
  Tuple<Float, Float> first_1 = new Tuple<Float, Float>(0.0, 0.0);
  Tuple<Tuple<Float, Float>, Float> first_2 = new Tuple<Tuple<Float, Float>, Float>(first_1, 0.32*height);
  this_level_info.add(first_2);

  for (ArrayList<Tuple<String, Integer>> samelevel : levels) {
    int depth = levels.indexOf(samelevel)+1;
    thecolor = color(0.5*depth*c/levels.size(), 255, 255, 100);
    fill(thecolor);
    for (int i = 0; i < samelevel.size(); i++) {
      Tuple<String, Integer> theconnector = new Tuple<String, Integer>(samelevel.get(i));
      // get the info for the very connector from the container
      Tuple<Float, Float> center = new Tuple<Float, Float>(this_level_info.get(i).x);
      float radius = this_level_info.get(i).y.floatValue();

      // if disjunction
      if ( theconnector.x.charAt(0) =='\u2228' ) {
        // represent as the negation of conjunction of negations
        pushMatrix();
        translate(center.x.floatValue(), center.y.floatValue());
        polygon(0, 0, 1.2*radius, 6);
        ellipse(0, 0, 2*radius, 2*radius);
        for (int j = 0; j<theconnector.y.intValue(); j++) {
          Tuple<Float, Float> newcenter = new Tuple<Float, Float>(center.x + radius*cos(TWO_PI*j/theconnector.y.intValue()), center.y + radius*sin(TWO_PI*j/theconnector.y.intValue()));
          Tuple<Tuple<Float, Float>, Float> newinfo = new Tuple<Tuple<Float, Float>, Float>(newcenter, radius*0.4);
          pushMatrix();
          translate(newcenter.x.floatValue() - center.x.floatValue(), newcenter.y.floatValue() - center.y.floatValue());
          rotate(radians(j+(millis()+2*i)/30));
          polygon(0, 0, 1.2*newinfo.y.floatValue(), 6);
          popMatrix();
          next_level_info.add(newinfo);
        }
        popMatrix();
        // if conjunction
      } else if ( theconnector.x.charAt(0) =='\u2227' ) {
        // represent as a circle
        pushMatrix();
        translate(center.x.floatValue(), center.y.floatValue());
        // generaterandomcolor();
        ellipse(0, 0, 2*radius, 2*radius);
        for (int j = 0; j<theconnector.y.intValue(); j++) {
          Tuple<Float, Float> newcenter = new Tuple<Float, Float>(center.x + radius*cos(TWO_PI*j/theconnector.y.intValue()), center.y + radius*sin(TWO_PI*j/theconnector.y.intValue()));
          Tuple<Tuple<Float, Float>, Float> newinfo = new Tuple<Tuple<Float, Float>, Float>(newcenter, radius*0.4);
          next_level_info.add(newinfo);
        }
        popMatrix();
        // if implication
      } else if ( theconnector.x.charAt(0) == '\u2192' ) {
        // represent as negation of conjunction
        pushMatrix();
        translate(center.x.floatValue(), center.y.floatValue());
        polygon(0, 0, 1.2*radius, 6);
        ellipse(0, 0, 2*radius, 2*radius);
        for (int j = 0; j<theconnector.y.intValue(); j++) {
          Tuple<Float, Float> newcenter = new Tuple<Float, Float>(center.x + radius*cos(TWO_PI*j/theconnector.y.intValue()), center.y + radius*sin(TWO_PI*j/theconnector.y.intValue()));
          Tuple<Tuple<Float, Float>, Float> newinfo = new Tuple<Tuple<Float, Float>, Float>(newcenter, radius*0.4);
          pushMatrix();
          translate(newcenter.x.floatValue() - center.x.floatValue(), newcenter.y.floatValue() - center.y.floatValue());
          rotate(radians(j+(millis()+2*i)/30));
          if (j == 0) {
            polygon(0, 0, 1.2*newinfo.y.floatValue(), 6);
          }
          popMatrix();
          next_level_info.add(newinfo);
        }
        popMatrix();
////////////////////////////////////////////////////////////////////////////////
/*************** I am not implementing a true bicondition here ****************/
        // if bicondition
      } else if ( theconnector.x.charAt(0) == '\u2194' ) {
        // represent as implication
        pushMatrix();
        translate(center.x.floatValue(), center.y.floatValue());
        polygon(0, 0, 1.2*radius, 6);
        ellipse(0, 0, 2*radius, 2*radius);
        for (int j = 0; j<theconnector.y.intValue(); j++) {
          Tuple<Float, Float> newcenter = new Tuple<Float, Float>(center.x + radius*cos(TWO_PI*j/theconnector.y.intValue()), center.y + radius*sin(TWO_PI*j/theconnector.y.intValue()));
          Tuple<Tuple<Float, Float>, Float> newinfo = new Tuple<Tuple<Float, Float>, Float>(newcenter, radius*0.4);
          pushMatrix();
          translate(newcenter.x.floatValue() - center.x.floatValue(), newcenter.y.floatValue() - center.y.floatValue());
          rotate(radians(j+(millis()+2*i)/30));
          if (j == 0) {
            polygon(0, 0, 1.2*newinfo.y.floatValue(), 6);
          }
          popMatrix();
          next_level_info.add(newinfo);
        }
        popMatrix();
/******* Because it requires me to change the data structure completely *******/
////////////////////////////////////////////////////////////////////////////////
        // if negation
      } else if ( theconnector.x.charAt(0) == '\u00AC') {
        pushMatrix();
        translate(center.x.floatValue(), center.y.floatValue());
        Tuple<Float, Float> newcenter = new Tuple<Float, Float>(center.x, center.y);
        Tuple<Tuple<Float, Float>, Float> newinfo = new Tuple<Tuple<Float, Float>, Float>(newcenter, radius*0.83);
        pushMatrix();
        rotate(radians((millis()+2*i)/30));
        polygon(0, 0, 1.2*radius, 6);
        popMatrix();
        next_level_info.add(newinfo);
        popMatrix();
        // if all qualifier
      } else if ( theconnector.x.charAt(0) == '\u2200') {
        // express as negation of existential qualifier
        pushMatrix();
        translate(center.x.floatValue(), center.y.floatValue());
        polygon(0, 0, 1.2*radius, 6);
        for (int k=1; k<50/depth; k++) {
          // System.out.println(k);
          fill(220, 10, 255, 30);
          pushMatrix();
          translate(0.75*radius*cos(radians(k*7.2*depth)), 0.75*radius*sin(radians(k*7.2*depth)));
          rotate(radians(k+millis()/30));
          for (int j = 0 ; j < 50/depth ; j++) {
            for (int l = 0; l<depth; l++) {
              if (!uglycolor) {
                pushMatrix();
              }
              float point_x = (float)(0.3*radius*cos(radians(j*7.2*depth + l*360/depth)));
              float point_y = (float)(0.3*radius*sin(radians(j*7.2*depth + l*360/depth)));
              translate(point_x, point_y);
              rotate(radians(j+millis()/30));
              rect(0,0,30.0/depth,30.0/depth);
              if (!uglycolor) {
                popMatrix();
              }
            }
          }
          popMatrix();
        }
        pushMatrix();
        translate(0.75*radius, 0);
        polygon(0, 0, 0.4*radius, 6);
        popMatrix();
        popMatrix();
        Tuple<Float, Float> newcenter = new Tuple<Float, Float>(center.x + radius, center.y);
        Tuple<Tuple<Float, Float>, Float> newinfo = new Tuple<Tuple<Float, Float>, Float>(newcenter, radius*0.4);
        next_level_info.add(newinfo);
        fill(thecolor);
        // if existential qualifier
      } else if ( theconnector.x.charAt(0) == '\u2203') {
        // represent as a long expression ring
        pushMatrix();
        translate(center.x.floatValue(), center.y.floatValue());
        for (int k=1; k<50/depth; k++) {
          // System.out.println(k);
          fill(220, 10, 255, 30);
          pushMatrix();
          translate(0.75*radius*cos(radians(k*7.2*depth)), 0.75*radius*sin(radians(k*7.2*depth)));
          rotate(radians(k+millis()/30));
          for (int j = 0 ; j < 50/depth ; j++) {
            for (int l = 0; l<depth; l++) {
              if (!uglycolor) {
                pushMatrix();
              }
              float point_x = (float)(0.3*radius*cos(radians(j*7.2*depth + l*360/depth)));
              float point_y = (float)(0.3*radius*sin(radians(j*7.2*depth + l*360/depth)));
              translate(point_x, point_y);
              rotate(radians(j+millis()/30));
              rect(0,0,30.0/depth,30.0/depth);
              if (!uglycolor) {
                popMatrix();
              }
            }
          }
          popMatrix();
        }
        popMatrix();
        Tuple<Float, Float> newcenter = new Tuple<Float, Float>(center.x + radius, center.y);
        Tuple<Tuple<Float, Float>, Float> newinfo = new Tuple<Tuple<Float, Float>, Float>(newcenter, radius*0.4);
        next_level_info.add(newinfo);
        fill(thecolor);
        // if space, i.e., carry-on
      } else {
        Tuple<Float, Float> newcenter = new Tuple<Float, Float>(center.x, center.y);
        Tuple<Tuple<Float, Float>, Float> newinfo = new Tuple<Tuple<Float, Float>, Float>(newcenter, radius);
        next_level_info.add(newinfo);
      }
    }
    this_level_info.clear();
    this_level_info.addAll(next_level_info);
    next_level_info.clear();
  }

  textFont(f_expression);
  for(int n = 0; n < this_level_info.size(); n++) {
    Tuple<Tuple<Float, Float>, Float> info = this_level_info.get(n);
    pushMatrix();
    translate(info.x.x.floatValue(),info.x.y.floatValue());
    text(arguments.get(n), 0, 0);
    popMatrix();
  }
  popMatrix();
}

color generaterandomcolor(boolean isBackG) {
  color thecolor = color(255);
  float nums[] = new float[3];
  for (int i=0; i<3; i++) {
    nums[i] = (float)(Math.random() * 180);
  }
  float transp = (float)(Math.random() * 60 + 160);
  if ( isBackG ) {
    thecolor = color(nums[0], nums[1], nums[2]);
    background(thecolor);
  } else {
    thecolor = color(nums[0], nums[1], nums[2], transp);
  }
  return thecolor;
}

color generaterainbow() {
  float transp = (float)(Math.random() * 60 + 160);
  color thecolor = color(c, 255, 255, transp);
  return thecolor;
}
