import java.util.*;


PImage  fecesB; 
PImage  fecesA;
PImage  decomposer2B;
PImage  decomposer2A;
PImage  decomposer1C;  
PImage  decomposer1B; 
PImage  decomposer1A;
PImage  decomposer0;  
PImage  dead;  
PImage  bird4;
PImage  bird3;  
PImage  bird2;  
PImage  bird1;   
PImage  bird0;  

PImage  carni9;  
PImage  carni8;  
PImage carni7; 
PImage carni6;  
PImage  carni5;  
PImage  carni4; 
PImage  carni3;  
PImage  carni2;  
PImage  carni1;  
PImage  carni0;  

PImage  herbi9;  
PImage  herbi8;   
PImage  herbi7;  
PImage  herbi6; 
PImage  herbi5;  
PImage  herbi4;  
PImage  herbi3; 
PImage  herbi2; 
PImage  herbi1; 
PImage  herbi0; 

PImage fish4; 
PImage fish3; 
PImage fish2;  
PImage fish1;  
PImage fish0;  

PImage  cell4;  
PImage  cell3;  
PImage  cell2; 
PImage  cell1; 
PImage  cell0;  

PImage  tree9;  
PImage  tree8; 
PImage  tree7; 
PImage tree6;  
PImage tree5; 
PImage tree4;  
PImage tree3; 
PImage tree2; 
PImage  tree1;
PImage  tree0; 

//can we please make bushes block horizontal motion, and trees block vertical motion?
PImage  bush9; 
PImage  bush8;   
PImage  bush7;  
PImage  bush6; 
PImage  bush5;  
PImage  bush4;  
PImage  bush3; 
PImage  bush2; 
PImage  bush1; 
PImage  bush0;  

PImage  shrub11;
PImage  shrub10;
PImage  shrub9;  
PImage  shrub8; 
PImage  shrub7; 
PImage  shrub6;  
PImage  shrub5;  
PImage  shrub4;  
PImage  shrub3; 
PImage  shrub2;  
PImage  shrub1; 
PImage  shrub0; 

PImage  grass9; 
PImage  grass8;  
PImage  grass7;  
PImage  grass6;  
PImage  grass5; 
PImage  grass4; 
PImage  grass3;  
PImage  grass2; 
PImage  grass1;  
PImage  grass0; 

float transitionPercent;
boolean transition = false;
boolean raining = true;
boolean weatherView = true;
boolean paused = false;
int minutes = 0;
int gameMode = 0;
//gameMode 0 is zoom god mode
//gameMode 1 is animalGen mode
int zoom = 5;
int camPosX;
int camPosY;
int windowWidth;
int windowHeight;
final int worldWidth = 512;
final int worldHeight = 512;
Block[][] world;
Block[][] window;
float[][] clouds;
PImage[] grassArray;
PImage[] shrubArray;
PImage[] bushArray;
PImage[] treeArray;
PImage[] herbiArray;
PImage[] carniArray;
PImage[] cellArray;
PImage[] birdArray;
PImage[] fishArray;
ArrayList<Animal> Creatures;
Block nullBlock;
Block selected;

Perk nullPerk;
Perk hardy;

//DECLARE PLANTS
Plant nullFlora;
Animal nullFauna;

public void setup() {
  size(1000, 750);
  background(0);
  smooth();
  loadImages();
  fillArrays();
  camPosX = 0;
  camPosY = 0;
  windowWidth = height/zoom;
  windowHeight = windowWidth;
  noStroke();
  strokeWeight(0);
  background(75, 33, 17);
  //world sweep
  nullBlock = new Block(0, 0, 1);
  selected = nullBlock;
  world = new Block[worldWidth][worldHeight];
  window = new Block[windowWidth][windowHeight];
  clouds = new float[worldHeight][4096];

  nullPerk = new Perk("null", "No perk");
  //List of perks
  hardy = new Perk ("Hardy", "Able to resist death by drought or thirst");

  nullFlora = new Plant(0, 0, "nullFlora", 0, 0, color(0, 0, 0, 0), 0);
  nullFauna = new Animal(0, new Strategy("Null"), 10, nullBlock, "nullFauna", color(0, 0), 0, 15);

//  Animal tester = new Animal( 0, new Strategy("Wander"), 10, findMouseBlock(), "Tester", color(0, 255, 0), 0 ,15);

  // create dynamic archives of species and Creatures
  Creatures = new ArrayList<Animal>();

//  Creatures.add(tester);




  //creates the world template
  for (int row = 0; row < worldHeight ; row++) {
    for (int column = 0; column < worldWidth; column ++) {
      world[row][column]= new Block(row, column);
      world[row][column].grass = nullFlora;
    }
  }
  //sets the starting window position
  for (int row = 0; row < windowHeight ; row++) {
    for (int column = 0; column < windowWidth; column ++) {
      window[row][column]=world[row+camPosY][column+camPosX];
    }
  }


  worldGeneration();
}
public void draw() {
  //establish the time
  minutes = frameCount;

  background(75, 33, 17);
  //println(": " + mouseX + "   mouseY: " + mouseY);
  windowCalibrate();
  drawHUD();
  if (paused == false && minutes % 30 == 0 ) {
    globalDrying();
  }
  if (raining) {
    //if it is raining, grow more frequently
    if (paused == false && minutes % 10 == 0 ) {
      growAttempt();
      if (random(1) < .1)
        weatherTransition();
    }
  }
  else {
    if (paused == false && minutes % 68 == 0 ) {
      growAttempt();
    }
  }
  if (paused == false && minutes % 25 == 0 )
    updateWeather();

  if (paused == false && minutes % 500 == 0 && random(1) < .2) {
    weatherTransition();
  }
  transitionCheck();

  updateCreatures();
}


void updateCreatures(){
  for (Animal a : Creatures){
    if (a != null && a.behavior != null && a != nullFauna
    && frameCount%a.slowness == 0)
    a.behavior.action(a, a.behavior.name);
  }
}

//void displayCreatures() {
//  int k = Creatures.size();
//  println("Creature arraylist size" + Creatures.size());
//  for (int i = 0 ; i < k ; i++) {
//
//    Animal temp = Creatures.get(i);
//    //Animal temp = Creatures.get(0);
//    if (temp.location != null) {
//      println(temp.name + temp.location.x + "  " + temp.location.y );
//      //fill(Creatures.get(i).furColor);
//      //iffy code here
//      //rect(Creatures.get(i).x , Creatures.get(i).y , zoom, standatd);
//      temp.display();
//    }
//  }
//
//  noFill();
//}



void weatherTransition() {
  //safeguards against a double transition
  if ( !transition ) {
    transition = true;
    transitionPercent = 1;
  }
}



void transitionCheck() {
  //checks every draw if transitioning is true;
  if (transitionPercent > 0) {
    transitionPercent -= .1;
  } 
  else {
    //if transition percent runs dry, set transition to false, set it back to 0
    // and change the status of weather
    if (transition) {
      if (raining) {
        raining = false;
      } 
      else {
        raining = true;
      }
      transitionPercent = 0;
      transition = false;
    }
  }
}

void globalDrying() {
  for (int row = 0 ; row < world.length; row++) {
    for (int column = 0; column< world[0].length; column++) {
      if (raining) {
        world[row][column].humidity = world[row][column].maxHumidity;
      } 
      else {
        // decreases humidity if it is over 0 and checks for plant death
        if (world[row][column].humidity > 0 && random(1) > .5)
          world[row][column].humidity-- ;
        if ( world[row][column].humidity <= 5 && ((random(1) > .9 && world[row][column].grass.perk1.name != "Hardy")
          || random(1) > .99)) {

          world[row][column].grass.numDead ++;
          world[row][column].grass.deathThirst ++;
          world[row][column].grass = nullFlora;
        }
        if ( world[row][column].humidity <= 5 && ((random(1) > .9 && world[row][column].flora.perk1.name != "Hardy")
          || random(1) > .99)) {
          world[row][column].flora.numDead ++;
          world[row][column].flora.deathThirst ++;
          world[row][column].flora = nullFlora;
        }
      }
    }
  }
}

void growAttempt() {
  int tempRow;
  int tempColumn;

  for (int row = 0 ; row < world.length; row++) {
    for (int column = 0; column< world[0].length; column++) {

      if (world[row][column].grass != nullFlora) {

        //if grass exists
        tempRow = (int(random(3)) - 1);
        tempRow = row + tempRow;
        tempColumn = (int(random(3)) - 1);
        tempColumn = column + tempColumn;
        if (tempRow < world.length
          && tempRow >= 0
          && tempColumn >= 0
          && tempColumn < world[0].length
          && world[tempRow][tempColumn].humidity > 5
          && world[row][column].humidity > 5
          && world[tempRow][tempColumn].type == 1 ) {
          if ((world[tempRow][tempColumn].grass == nullFlora
            && random(1) < world[row][column].grass.growthChance) 
            || (random(1) < 0.1 && world[row][column].biome == world[tempRow][tempColumn].biome)) {
            world[tempRow][tempColumn].grass = world[row][column].grass;
          }
        }
      }
      if (world[row][column].flora != nullFlora) {
        //if flora exists

        tempRow = (int(random(world[row][column].flora.floraHeight + 1)));
        if (random(1) > .5)
          tempRow = -1*tempRow;

        tempColumn = (int(random(world[row][column].flora.floraHeight + 1)));
        if (random(1) > .5)
          tempColumn = -1*tempColumn;

        tempRow = row + tempRow;
        tempColumn = column + tempColumn;


        //conditions required for a flora to seed
        if (tempRow < world.length
          && tempRow >= 0
          && tempColumn >= 0
          && tempColumn < world[0].length
          && world[tempRow][tempColumn].humidity > 5
          && world[row][column].humidity > 5
          && world[tempRow][tempColumn].type == 1 
          && world[row][column].biome == world[tempRow][tempColumn].biome) {
          if ((world[tempRow][tempColumn].flora == nullFlora
            && random(1) < world[row][column].flora.growthChance)
            || (random(1) < 0.05)) {
            world[tempRow][tempColumn].flora = world[row][column].flora;
          } 
          else if ( world[tempRow][tempColumn].flora != nullFlora
            && random(100) >= (100 - 10*world[tempRow][tempColumn].flora.floraHeight)) {
            //kills the plant if overcrowded
            world[row][column].flora.numDead ++;
            world[row][column].flora.deathOvercrowded ++;
            world[row][column].flora = nullFlora;
          }
        }
      }
    }
  }
}




Block findMouseBlock() {
  //returns the block that the mouse is hovering over;
  if (mouseX/zoom < windowWidth) {
    //safeguards against the bug that freezes if mouse hover over null
    return world[mouseY/zoom + camPosY][mouseX/zoom+camPosX];
  } 
  else {
    return nullBlock;
  }
} 

Block findBlock(int x, int y) {
  //returns the block that the mouse is hovering over;

  //if (worldWidth > (y + camPosY) || worldHeight > (x+camPosX)) {
  return world[y+camPosY][x + camPosX];
}

void drawHUD() {
  if (selected != null) {
    String s = "";
    textSize(15);
    fill(0);
    rect(750, 0, width, height);

    fill(255);
    text("w,a,s,d to move", 800, 580);
    text("z, x to zoom in and out", 800, 600);
    text("c makes it rain!", 800, 620);
    //be sure to set selected to nullblock in case of title, menus, and whatnot
    if (selected != nullBlock) {
      if (selected.grass != nullFlora) {
        s = "Grass: " + selected.grass.name ;
        text(s, 800, 440);
        s = "Height: " + selected.grass.floraHeight;
        text(s, 800, 460);

        image(selected.grass.newImg, 760, 430, 30, 30);
      }
      if (selected.flora != nullFlora ) {
        println("Numdead: " + selected.flora.numDead + "   " + selected.flora.deathOvercrowded);
        s = "Flora: " + selected.flora.name;
        text(s, 800, 400);
        s = "Height: " + selected.flora.floraHeight;
        text(s, 800, 420);

        image(selected.flora.newImg, 760, 390, 30, 30);
      }
      if (selected.type != 4) { //4 is water
        s = "Biome: " + selected.biomeName((selected.absX), (selected.absY));
        text(s, 800, 480);
        s = "Position: (" + (selected.absX) + "," + (selected.absY)+ ")";
        text(s, 800, 500);
      } 
      else {
        s = "Biome: Aquatic" ;
        text(s, 800, 180);
        s = "Position: (" + (selected.absY) + "," + (selected.absX)+ ")";
        text(s, 800, 200);
      }

      drawDisplay(800, 10);
    } // end if selected == nullblock

    fill(255, 0, 0);
    if (gameMode == 1)
      text("Creature Placement is on. "+'\n'+"Press 'r' to turn off", 800, 50);
    if (gameMode == 2)
      text("Seed of Life is on. "+'\n'+"Press 't' to turn off", 800, 50);
    textSize(45);
    if (paused)
      text("PAUSED", 10, 10);
    noFill();
  } 
  else {
    println("Null block detected");
  }
}

void drawDisplay(int startingX, int startingY) {
  color temp= color(255, 0, 0);

  if (selected.type < 0) {
    println("Error: Unrecognized selected.type");
  } 
  else if ( selected.type == 0 ) {
    //ice
    temp = color(255);
  } 
  else if (selected.type == 1) {
    //dirt
    temp = color (75, 33, 17);
  } 
  else if (selected.type == 2) {
    //grass
    temp = color (74, 118, 56);
  } 
  else if (selected.type == 3) {
    //stone
    temp = color (159, 162, 157);
  } 
  else if (selected.type == 4) {
    //water
    temp = color (75, 114, 147);
  } 
  else if (selected.type == 5) {
    //sand
    temp = color (198, 184, 76);
  } 
  else { 
    //warning message
    println("Error: unrecognized type");
  }

  //front face
  if (selected.type == 0) {
    fill(255);
  } 
  else if (selected.type == 4) {
    fill(22, 70, 106);
  } 
  else {   
    fill(temp + color(selected.altitude/2, selected.altitude/2, selected.altitude/2));
  }

  rect(startingX, startingY + 350 - (230*(selected.altitude+40)/100), 120, (230*(selected.altitude+7)/100) );

  //top face
  if (selected.grass != null && selected.grass != nullFlora) {
    fill(selected.grass.leafColor);
  } 
  else if (selected.type == 0) { 
    fill(255);
  } 
  else {
    fill(temp + color(selected.altitude, selected.altitude, selected.altitude));
  }

  if (selected.altitude > -7) {
    quad(startingX, startingY + 350 - (230*(selected.altitude+40)/100)
      , startingX+120, startingY + 350 - 230*(selected.altitude+40)/100
      , startingX + 180, startingY + 290 - (230*(selected.altitude+40)/100)
      , startingX + 60, startingY + 290 - (230*(selected.altitude+40)/100));
  } 
  else {
    // if altitude is less than -7

    quad(startingX, startingY + 275
      , startingX+120, startingY + 275
      , startingX + 180, startingY + 215
      , startingX + 60, startingY + 215 );
  }

  if (selected.type == 0) {
    fill(220, 233, 242);
  } 
  else if (selected.type == 4) {
    fill(22, 70, 106);
  } 
  else {
    fill(temp);
  }

  //side face
  //println(mouseX + " , " + mouseY);

  quad(startingX+120, startingY + 350 - 230*(selected.altitude+40)/100
    , startingX +120, startingY + 275
    , startingX +180, startingY + 215
    , startingX + 180, startingY + 290 - (230*(selected.altitude+40)/100));


  //trees
  if (selected.type == 1 && selected.flora != nullFlora 
    && selected.flora != null && selected.flora.floraHeight >= 3) {
    //then draw a tree
    image(selected.flora.newImg, startingX + 50
      , startingY + 220 - (230*(selected.altitude+40)/100), 80, 80);
  }

  //bushes 
  if (selected.type == 1 && selected.flora != nullFlora 
    && selected.flora != null && selected.flora.floraHeight == 2) {
    //then draw a bush
    image(selected.flora.newImg, startingX + 60
      , startingY + 260 - (230*(selected.altitude+40)/100), 40, 40);

    image(selected.flora.newImg, startingX + 105
      , startingY + 280 - (230*(selected.altitude+40)/100), 40, 40);

    image(selected.flora.newImg, startingX + 25
      , startingY + 305 - (230*(selected.altitude+40)/100), 40, 40);
  }

  //shrub
  if (selected.type == 1 && selected.flora != nullFlora 
    && selected.flora != null && selected.flora.floraHeight == 1) {
    //then draw a bush
    image(selected.flora.newImg, startingX + 60
      , startingY + 280 - (230*(selected.altitude+40)/100), 20, 20);

    image(selected.flora.newImg, startingX + 105
      , startingY + 280 - (230*(selected.altitude+40)/100), 20, 20);

    image(selected.flora.newImg, startingX + 25
      , startingY + 305 - (230*(selected.altitude+40)/100), 20, 20);

    image(selected.flora.newImg, startingX + 75
      , startingY + 300 - (230*(selected.altitude+40)/100), 20, 20);

    image(selected.flora.newImg, startingX + 105
      , startingY + 325 - (230*(selected.altitude+40)/100), 20, 20);

    image(selected.flora.newImg, startingX + 45
      , startingY + 325 - (230*(selected.altitude+40)/100), 20, 20);

    image(selected.flora.newImg, startingX + 135
      , startingY + 290 - (230*(selected.altitude+40)/100), 20, 20);
  }
}


Plant floraGenerator(int startingX, int startingY) {

  float randomizer = random(0, 1);
  color c = color(0, 250, 0);
  int plantHeight = int(random(4));
  float growthChance = 0;
  String prefix;


  //Start with looking at the biome
  if (world[startingY][startingX].biome == 0) {
    //arctic
    prefix = "Arctic ";
    growthChance = .05;
    //checks for NO GRASS IN ARCTIC
    if (plantHeight <= 0) {
      plantHeight++;
    }
    c = color(54, 32, 10);
  }
  else if (world[startingY][startingX].biome == 1) {

    prefix = "Tropic ";
    growthChance = .5;

    if (randomizer < .3) {
      //tropic rain
      c= color(57, 175, 25);
    }
    else if (randomizer >= .3 && randomizer < .6) {
      //tropic rain
      c= color(16, 90, 21);
    }
    else if (randomizer >= .6 && randomizer < .95) {
      //tropic rain
      c= color(8, 129, 41);
    }
    if (randomizer >= .95 && randomizer < .98) {
      //tropic rain
      c= color(16, 90, 67);
    }
    if (randomizer >= .98) {
      //tropic rain
      c= color(240, 174, 7);
    }
  }
  //tropic end
  if (world[startingY][startingX].biome == 2) {
    prefix = "Alpine ";
    growthChance = .2;
    //tundra
    //no trees, few bushes
    if (plantHeight >3) {
      plantHeight -= 2;
    } 
    else if (plantHeight == 2 && random(1) > .3 ) {
      plantHeight = 0;
    }

    c= color(188, 142, 42);
  }
  if (world[startingY][startingX].biome == 3) {

    prefix = "Boreal ";
    growthChance = .25;
    //boreal
    plantHeight = 3;
    c= color(14, 88, 77);
  }
  if (world[startingY][startingX].biome == 4) {

    prefix = "Grassland ";
    //grassland
    growthChance = .4;
    if (plantHeight > 1) {
      plantHeight = 0;
    }

    if (randomizer >= .5) {
      c= color(74, 100, 29);
    } 
    else {
      c= color(54, 93, 39);
    }
  }
  if (world[startingY][startingX].biome == 5) {
    prefix = "Deciduous ";

    growthChance = .4;
    // deciduous
    if (randomizer < .3) {

      c= color(71, 149, 83);
    }
    else if (randomizer >= .3 && randomizer < .6) {
      //
      c= color(86, 152, 96);
    }
    else if (randomizer >= .6) {
      //
      c= color(82, 73, 24);
    }
  }
  if (world[startingY][startingX].biome == 6) {
    prefix = "Temperate ";

    // temperate rainforest
    growthChance = .6;
    if (randomizer < .3) {

      c= color(50, 173, 17);
    }
    else if (randomizer >= .3 && randomizer < .6) {
      //
      c= color(68, 155, 45);
    }
    else if (randomizer >= .6) {
      //
      c= color(63, 90, 73);
    }
  }
  if (world[startingY][startingX].biome == 7) {
    prefix = "Desert ";
    growthChance = .05;
    if (plantHeight > 2) {
      plantHeight = 2;
    }
    //desert
    c= color(135, 188, 89);
  }
  if (world[startingY][startingX].biome == 8) {
    prefix = "Thorny ";
    growthChance = .4;
    //thorn forest
    if (randomizer >= .6) {
      c= color(212, 88, 219);
    } 
    else {
      c= color(149, 27, 66);
    }
  }
  if (world[startingY][startingX].biome == 9) {
    prefix = "Barren ";
    growthChance = .1;
    //badlands
    c= color(137, 117, 108);
  }
  Plant subject = new Plant(startingX, startingY, floraNameGenerator(plantHeight), 
  growthChance, plantHeight, c, 0);
  return subject;
}

String floraNameGenerator (int plantHeight) {
  int randomNum;
  String suffix ="";
  String middle;
  if (plantHeight <= 0) {
    randomNum = int(random(9));
    //grasses
    if (randomNum == 0)
      suffix = "grass";
    if (randomNum == 1)
      suffix = "weed";
    if (randomNum == 2)
      suffix = "nettle";
    if (randomNum == 3)
      suffix = "thistle";
    if (randomNum == 4)
      suffix = "wheat";
    if (randomNum == 5)
      suffix = "vine";
    if (randomNum == 6)
      suffix = "moss";
    if (randomNum == 7)
      suffix = "dew";
    if (randomNum >= 8)
      suffix = "seed";
  } 
  else if (plantHeight == 1) {
    //sprout
    randomNum = int(random(13));
    //grasses
    if (randomNum == 0)
      suffix = "leaf";
    if (randomNum == 1)
      suffix = "herb";
    if (randomNum == 2)
      suffix = "wort";
    if (randomNum == 3)
      suffix = "pod";
    if (randomNum == 4)
      suffix = "bloom";
    if (randomNum == 5)
      suffix = "petal";
    if (randomNum == 6)
      suffix = "lily";
    if (randomNum == 7)
      suffix = "root";
    if (randomNum == 8)
      suffix = "bean";
    if (randomNum == 9)
      suffix = "reed";
    if (randomNum == 10)
      suffix = "stem";
    if (randomNum == 11)
      suffix = "stock";
    if (randomNum >= 12)
      suffix = "sprout";
  } 
  else if (plantHeight == 2) {
    //bush
    randomNum = int(random(8));
    //grasses
    if (randomNum == 0)
      suffix = "bush";
    if (randomNum == 1)
      suffix = "berry";
    if (randomNum == 2)
      suffix = "root";
    if (randomNum == 3)
      suffix = "shrub";
    if (randomNum == 4)
      suffix = "trap";
    if (randomNum == 5)
      suffix = "thorn";
    if (randomNum == 6)
      suffix = "leaf";
    if (randomNum >= 7)
      suffix = "sage";
  } 
  else if (plantHeight >= 3) {
    //tree
    randomNum = int(random(10));
    //grasses
    if (randomNum == 0)
      suffix = "wood";
    if (randomNum == 1)
      suffix = "tree";
    if (randomNum == 2)
      suffix = "bark";
    if (randomNum == 3)
      suffix = "palm";
    if (randomNum == 4)
      suffix = "leaf";
    if (randomNum == 5)
      suffix = "root";
    if (randomNum == 6)
      suffix = "sap";
    if (randomNum == 7)
      suffix = "branch";
    if (randomNum == 8) 
      suffix = "fruit";
    if (randomNum >= 9)
      suffix = "nut";
  }
  String[] middleChoice = new String[] {
    "Cotton", "Poison", "Rock", "Snow", "Golden", "Rag", "Moon", 
    "Moon", "Creeping", "Brook", "Milk", "Night", "Gobble", "Heaven", "Nag", "Butter", "Bitter", 
    "Wallow", "Thorn", "Hanging", "Honey", "Morning", "Razor", "Skunk", "Riddle", "Martyr", "Bull", "Frog", "Sun"
      , "Liver", "Terra", "Mingle", "Sugar", "Lock", "Sour", "Looming", "Lesser", "Holy", "Slender", "Stinging", "Bristle"
      , "Monk", "Silver", "Sunken", "Tumble", "Splinter", "Dagger", "Resin", "Pearl", "Odor", "Haze"
      , "Carpet", "Tangle", "Venom", "Blister", "Hermit"
  };

  int temp = int(random(middleChoice.length));
  middle = middleChoice[temp];

  //to safeguard against "double thorn"
  if (middle == "Thorn" && suffix == "thorn")
    suffix = "shooter";

  if (suffix != "tree" && suffix != "bush") {
    if (plantHeight == 2) {
      suffix += " Bush";
    }
    if (plantHeight == 3) {
      suffix += " Tree";
    }
  }
  return (middle+suffix);
}

//START WORLD GENERATION~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
void worldGeneration() {
  float randomizer;
  float[][] baseNoise = generateWhiteNoise(worldWidth, worldHeight);

  println("Generating terrain...");
  float[][] perlin = generatePerlinNoise(baseNoise, 6); //constant is the octave count, or resolution

  for (int row = 0 ; row < perlin.length; row++) {
    for (int column = 0; column< perlin[0].length; column++) {
      //if the perlin equivalent is greater than a certain percentage, 
      //assign a type to the corresponding world cell
      if (perlin[row][column] < .2) {
        world[row][column].altitude = -40;
        world[row][column].type = 4;
      } 
      if (perlin[row][column] >= .2 && perlin[row][column] < .3) {
        world[row][column].altitude = -30;
        world[row][column].type = 4;
      } 
      if (perlin[row][column] >= .3 && perlin[row][column] < .35) {
        world[row][column].altitude = -20;
        world[row][column].type = 4;
      } 
      if (perlin[row][column] >= .35 && perlin[row][column] < .375) {
        world[row][column].altitude = -10;
        world[row][column].type = 4;
      }
      if (perlin[row][column] >= .375 && perlin[row][column] < .4) {
        world[row][column].altitude = 5;
        world[row][column].type = 5;
        sandSifting(row, column, perlin);
      }
      if (perlin[row][column] >= .4 && perlin[row][column] < .5) {
        world[row][column].altitude = 10;
        world[row][column].type = 1;
      } 
      if (perlin[row][column] >= .5 && perlin[row][column] < .6) {
        world[row][column].altitude = 20;
        world[row][column].type = 1;
      } 
      if (perlin[row][column] >= .6 && perlin[row][column] < .7) {
        world[row][column].altitude = 30;
        world[row][column].type = 1;
      } 
      if (perlin[row][column] >= .7 && perlin[row][column] < .8) {
        world[row][column].altitude = 40;
        world[row][column].type = 1;
      } 
      if (perlin[row][column] >= .8 && perlin[row][column] < .9) {
        world[row][column].altitude = 50;
        world[row][column].type = 1;
      } 
      if (perlin[row][column] >= .9) {
        world[row][column].altitude = 60;
        world[row][column].type = 1;
      }
    }
  }

  println("Generating maxHumidity levels and temperature...");
  perlin = generatePerlinNoise(baseNoise, 8); //constant is the octave count, or resolution
  for (int row = 0 ; row < perlin.length; row++) {
    for (int column = 0; column< perlin[0].length; column++) {
      //sets the temperature based on distance from equator
      //temperature ranges from -25 to 100
      world[row][column].temperature = (45*(float(row)/float(worldHeight))-15 + random(-.5, .5));
      //if the perlin equivalent is greater than a certain percentage, 
      //assign a type to the corresponding world cell
      if (perlin[row][column] < .1) {
        world[row][column].maxHumidity = 0;
        world[row][column].type = 4;
      } 
      if (perlin[row][column] >= .1 && perlin[row][column] < .2) {
        world[row][column].maxHumidity = 10;
        world[row][column].type = 4;
      } 
      if (perlin[row][column] >= .2 && perlin[row][column] < .3) {
        world[row][column].maxHumidity = 20;
        world[row][column].type = 4;
      } 
      if (perlin[row][column] >= .3 && perlin[row][column] < .4) {
        world[row][column].maxHumidity = 30;
        world[row][column].type = 4;
      }
      if (perlin[row][column] >= .4 && perlin[row][column] < .5) {
        world[row][column].maxHumidity = 40;
      } 
      if (perlin[row][column] >= .5 && perlin[row][column] < .6) {
        world[row][column].maxHumidity = 50;
      } 
      if (perlin[row][column] >= .6 && perlin[row][column] < .7) {
        world[row][column].maxHumidity = 60;
      } 
      if (perlin[row][column] >= .7 && perlin[row][column] < .8) {
        world[row][column].maxHumidity = 70;
      } 
      if (perlin[row][column] >= .8 && perlin[row][column] < .9) {
        world[row][column].maxHumidity = 80;
      } 
      if (perlin[row][column] >= .9) {
        world[row][column].maxHumidity = 90;
      }
      //fixing water levels
      if (world[row][column].type == 4) {
        //if water is higher than the ground, reduce it
        world[row][column].altitude -= 35;
      }
      if (world[row][column].altitude >= 0 && world[row][column].type == 4) {
        world[row][column].altitude = -5;
      }
    }
  }

  //assignming biomes
  println("Assigning biomes...");
  for (int row = 0 ; row < worldWidth; row++) {
    for (int column = 0; column< worldHeight; column++) {
      if (world[row][column].type == 4 ) {
        //define water biomes
      }
      else {
        //if the tile is not water, consider maxHumidity, temp, and elevation


        // ARCTIC
        if   (world[row][column].temperature <= -10) {
          //if the block is not water and below -10 degrees, freeze it.
          world[row][column].type = 0;
          world[row][column].biome = 0;
        } 
        else if   ((world[row][column].temperature <= -7 
          && world[row][column].temperature > -10)
          || (world[row][column].temperature <= 2 
          && world[row][column].temperature > -7
          && world[row][column].maxHumidity > 20)) {
          //settles snow
          randomizer = random(-10, -7);
          if (randomizer > (world[row][column].temperature)) {
            world[row][column].type = 0;
          }
          if (world[row][column].altitude > 20) {
            world[row][column].biome = 3;
          } 
          else {
            world[row][column].biome = 2;
          }
        } 


        else if   ((world[row][column].maxHumidity <= 20
          && world[row][column].temperature > -7)) {
          //desert
          world[row][column].biome = 7;
          //sets sand
          world[row][column].type = 5;
        }

        else if   ((world[row][column].temperature >  2
          && world[row][column].maxHumidity > 20
          && world[row][column].maxHumidity <= 30)
          || (world[row][column].temperature > 20 
          && world[row][column].maxHumidity > 30
          && world[row][column].maxHumidity <= 40
          )) { //END IF STATEMENT
          //badlands/thorn forests
          if (world[row][column].altitude > 20) {
            world[row][column].biome = 8;
          } 
          else {
            world[row][column].biome = 9;
          }
        } 

        else if   ((world[row][column].temperature >  2
          && world[row][column].temperature <= 20
          && world[row][column].maxHumidity > 30
          && world[row][column].maxHumidity <= 60)
          || (world[row][column].temperature > 20 
          && world[row][column].maxHumidity > 40
          && world[row][column].maxHumidity <= 60
          )) { //END IF STATEMENT
          //deciduous and grasslands
          if (world[row][column].altitude > 20) {
            world[row][column].biome = 5;
          } 
          else {
            world[row][column].biome = 4;
          }
        } 

        else if   ((world[row][column].temperature >  2
          && world[row][column].maxHumidity > 60
          )) { //END IF STATEMENT, YOU'RE IN THE TROPICS SUGATITS
          //deciduous and grasslands
          if (world[row][column].altitude > 20) {
            world[row][column].biome = 6;
          } 
          else {
            world[row][column].biome = 1;
          }
        }
      }
      world[row][column].humidity = world[row][column].maxHumidity;
    }
  }
  Plant temp;

  println("Planting seeds...");
  for (int i = 0; i < 75; i++) {
    int humdumY = int(random(0, worldHeight));
    int humdumX = int(random(0, worldWidth));
    if (world[humdumY][humdumX].type == 1 || world[humdumY][humdumX].type == 0) {
      temp = floraGenerator(humdumX, humdumY);
      if (temp.grass && world[humdumY][humdumX].type == 1) {
        world[humdumY][humdumX].grass = temp;
      } 
      else {
        world[humdumY][humdumX].flora = temp;
      } 

      println("  -Planted at " + humdumX + "," + humdumY);
      temp.assignRandomImage();
    }
  }
  baseNoise = generateWhiteNoise(worldHeight, 4096); // power of two to loop

  println("Generating clouds...");
  perlin = generatePerlinNoise(baseNoise, 7); //constant is the octave count, or resolution

  for (int row = 0 ; row < world[0].length; row++) {
    for (int column = 0; column < 4096; column++) {
      clouds[row][column] = perlin[row][column];
    }
  }

  updateWeather();
}
//END WORLD GENERATION_----------------------------------------------

void updateWeather() {
  int push = int(minutes/25);
  for (int row = 0 ; row < world.length; row++) {
    for (int column = 0; column< world[0].length; column++) {
      int tempp = (push + column)%4096;
      world[row][column].weather = clouds[row][tempp];
    }
  }
}

//checks the proximity 
void sandSifting(int row, int column, float[][] thePerlin) {
  //println("sandsifting...");
  boolean keep = false;
  //in the 3x3 square surrounding the pixel
  for (int jana = -3; jana <= 3; jana++) {
    for (int ryan = -3; ryan <= 3; ryan++) {
      if (row >= 3 && row < worldHeight-3
        && column >= 3 && column < worldWidth-3) {
        if (thePerlin[row+ryan][column+jana] < .375) {
          keep = true;
        }
        //println(row+ ":" +column +":"+thePerlin[row+ryan][column+jana]);
      } 
      else {
        //this fixes a bug where the sand in the edges is turned to dirt
        keep = true;
      }
    }
  }
  //if the test is failed, turn sand to dirt
  if (keep!= true) {
    world[row][column].type = 1;
  } 
  else {
    //println("keep is not false");
  }
}

//generates smooth noise
float[][] generateSmoothNoise(float[][] baseNoise, int octave ) {
  int width = baseNoise.length;
  int height = baseNoise[0].length;

  float[][] smoothNoise = new float[width][height];

  int samplePeriod = (2<<octave);
  float sampleFrequency = 1.0/samplePeriod;

  for (int i = 0; i < width ; i++) {
    //calculate the horizontal sampling indices
    int sample_i0 = (i / samplePeriod) * samplePeriod;
    int sample_i1 = (sample_i0 + samplePeriod) % width; //wrap around
    float horizontal_blend = (i - sample_i0) * sampleFrequency;

    for (int j = 0; j < height; j++)
    {
      //calculate the vertical sampling indices
      int sample_j0 = (j / samplePeriod) * samplePeriod;
      int sample_j1 = (sample_j0 + samplePeriod) % height; //wrap around
      float vertical_blend = (j - sample_j0) * sampleFrequency;

      //blend the top two corners
      float top = Interpolate(baseNoise[sample_i0][sample_j0], 
      baseNoise[sample_i1][sample_j0], horizontal_blend);

      //blend the bottom two corners
      float bottom = Interpolate(baseNoise[sample_i0][sample_j1], 
      baseNoise[sample_i1][sample_j1], horizontal_blend);

      //final blend
      smoothNoise[i][j] = Interpolate(top, bottom, vertical_blend);
    }
  }

  return smoothNoise;
}

float Interpolate(float x0, float x1, float alpha)
{
  return x0 * (1 - alpha) + alpha * x1;
}

float[][] generateWhiteNoise(int someWidth, int someHeight) {
  float[][] randomNoise = new float[someWidth][someHeight];
  for (int i=0; i < someWidth; i++) {
    for (int j=0; j < someHeight; j++) {
      randomNoise[i][j] = random(0, 1);
    }
  }
  return randomNoise;
}

float[][] generatePerlinNoise(float[][] baseNoise, int octaveCount)
{
  int width = baseNoise.length;
  int height = baseNoise[0].length;

  float[][][] smoothNoise = new float[octaveCount][][]; //an array of 2D arrays containing

  float persistance = 0.5f;

  //generate smooth noise
  for (int i = 0; i < octaveCount; i++)
  {
    smoothNoise[i] = generateSmoothNoise(baseNoise, i);
  }

  float[][] perlinNoise = new float[width][height];
  float amplitude = 1.0f;
  float totalAmplitude = 0.0f;

  //blend noise together
  for (int octave = octaveCount - 1; octave >= 0; octave--)
  {
    amplitude *= persistance;
    totalAmplitude += amplitude;

    for (int i = 0; i < width; i++)
    {
      for (int j = 0; j < height; j++)
      {
        perlinNoise[i][j] += smoothNoise[octave][i][j] * amplitude;
      }
    }
  }

  //normalisation
  for (int i = 0; i < width; i++)
  {
    for (int j = 0; j < height; j++)
    {
      perlinNoise[i][j] /= totalAmplitude;
    }
  }

  return perlinNoise;
}

void windowCalibrate() {
  // NEW~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //println(windowWidth+ "," + windowHeight + "  zoom: " + zoom);
  //resets and displays the contents of the window
  //loop to check each cell
  //  Block [][] window = new Block[matrix.length][];
  //^^^might want to try deleting this redundancy
  for (int row = 0; row < windowHeight ; row++) {
    // old column is new windowWidth
    Block[] worldC = world[row+camPosY];
    window[row] = new Block[windowHeight];
    //    arrayCopy(world[row][], camPosX, window[row][], 0, windowWidth);
    arrayCopy(worldC, camPosX, window[row], 0, windowWidth);
    //println("row: " + row + "column: " +column);
    for (int column = 0; column < windowWidth ; column++) {
      window[row][column].relX = column;
      window[row][column].relY = row;
      window[row][column].display();
    }
  }
}


//BUTTONZ
void keyPressed() {

  if (key == 'z' && zoom > 5) {
    zoom--; 
    if (zoom > 5) {
      windowHeight = height/zoom+1;
      windowWidth = windowHeight;
    } 
    else {
      windowHeight = height/zoom;
      windowWidth = windowHeight;
    }
    //centers the zooming
    camPosX -= (16-zoom)/2;
    camPosY -= (16-zoom)/2;

    //fixes bug that occurs when player zooms out at edge
    if (camPosX + windowWidth + zoom >= worldWidth+1) {
      camPosX = worldWidth - windowWidth;
    }
    if (camPosY + windowHeight + zoom >= worldHeight+1) {
      camPosY = worldHeight - windowHeight;
    }
    if (camPosX < 0) {
      camPosX = 0;
    }
    if (camPosY< 0) {
      camPosY = 0;
    }
    //zoom
  }
  else if ( key == 'x' && zoom < 15) {
    zoom++;
    windowHeight = height/zoom+1;
    windowWidth = windowHeight;
    camPosX += (16-zoom)/2;
    camPosY += (16-zoom)/2;
  }

  //directional KEYS

  if (key == 'w' || key == 'W') {
    if (camPosY - 15 >= 0) {
      camPosY -= (16-zoom);
    }
    else {
      camPosY = 0;
    }
  }
  else if (key == 's' || key == 'S') {
    if (camPosY + windowHeight + 15 < worldHeight) {
      camPosY += (16-zoom);
    }
    else {
      camPosY = worldHeight - windowHeight;
    }
  }

  if (key == 'a' || key == 'A') {
    if (camPosX - 15 > 0) {
      camPosX -= (16-zoom);
    }
    else {
      camPosX = 0;
    }
  }
  else if (key == 'd' || key == 'D') {
    if (camPosX + windowWidth + 15 < worldWidth) {
      camPosX += (16-zoom);
    }
    else {
      camPosX = worldWidth - windowWidth;
    }
  }

  if (key == 'c' || key == 'C') {
    weatherTransition();
  }

  if (key == 'p' || key == 'P') {
    if (paused) {
      paused = false;
    }
    else {
      paused = true;
    }
  }

  if (key == 'r' || key == 'R') {
    if (gameMode != 1)
      //if the game mode isn't animalGen(1)...
      gameMode = 1;
    else
      gameMode = 0;
  }

  if (key == 't' || key == 'T') {
    if (gameMode != 2)
      //if the game mode isn't animalGen(1)...
      gameMode = 2;
    else
      gameMode = 0;
  }

  //End if key coded
}

void mouseReleased() {
  switch(gameMode) {
  case 0: 
    // if default option is on...
    selected = findMouseBlock();
    println(findMouseBlock().humidity + "  " + minutes);
    break;

  case 1:
    //if animal generation global is on, create a new animal at mouse point
    if (mouseX >= 0 && mouseX < windowWidth*zoom
      && mouseY >= 0 && mouseY < windowHeight*zoom) {
      Animal test = new Animal(0, new Strategy("Wander"), 10, findMouseBlock(), "Tester", color(random(255), random(255), random(255)), 0 ,15);
      Creatures.add(test);
      println("New Animal: " + test.x + "  " + test.y);
    } 
    else {
      println("Mouse out of bounds error.");
    }
    break;

  case 2:
    // planting mode, plants a random seed where the mouse is clicked.
    // first, make a plant
    Plant sprout = floraGenerator(mouseX/zoom, mouseY/zoom);
    // then, decide whether it is a tree or not and place it 
    // in the corresponding block's slot.
    if (sprout.floraHeight <= 0) {
      //    findMouseBlock().grass = nullFlora;
      findMouseBlock().grass = sprout;
      findMouseBlock().grass.assignRandomImage();
      findMouseBlock().grass.imageRecolor();
    }
    else {
      //    findMouseBlock().grass = nullFlora;
      findMouseBlock().flora = sprout;
      findMouseBlock().flora.assignRandomImage();
      findMouseBlock().flora.imageRecolor();
    }

    break;
  }
}

class Animal extends Entity {
int x;
int y;
int speed = 15;
  color furColor;
  int faunaSize = 1;
  PImage faunaImg = cellArray[3];
  PImage newImg;
  Perk perk1 = nullPerk;

  Strategy behavior;
  int stat = 0;
  int diet;
  int health;
  int slowness;

  int deathThirst = 0;

  Animal(int dieet, Strategy behav, int life, Block area, String nam, color fur, int numDead, int slow) {
    super(0, 0, numDead);

    
    if (area != null) {
      x = area.absY;
      y = area.absX;
          area.fauna = this;
    }

    name = nam;
    diet = dieet;
    behavior = behav;
    health = life;
    slowness = slow;

    furColor = fur;
    //gives the plant a unique clr
    furColor += (color(int(random(-15, 15)), int(random(-15, 15)), int(random(-15, 15))));
  }


  void setColor(color c) {
    furColor = c;
  }

  void assignRandomImage() {
    faunaImg = randomImg();

    imageRecolor();
  }

  void imageRecolor() {
    //after image has been assigned:
    loadPixels(); 
    // Since we are going to access the image's pixels too 
    newImg = faunaImg.get();
    faunaImg.loadPixels(); 
    for (int ry = 0; ry < faunaImg.height; ry++) {
      for (int rx = 0; rx < faunaImg.width; rx++) {
        int loc = rx + ry*faunaImg.width;

        // Image Processing would go here
        // If we were to change the RGB values, we would do it here, before setting the pixel in the display window.

        // Set the display pixel to the image pixel
        if (alpha(newImg.pixels[loc]) > 200) {
          newImg.pixels[loc] =  furColor;
        }
      }
    }
    //println("Leafcolor is: " + leafColor);
    updatePixels();
  }

  PImage randomImg() {
    if (faunaSize <= 0) {
      return grassArray[int(random(grassArray.length))];
    } 
    else if (faunaSize == 1) {
      return shrubArray[int(random(shrubArray.length))];
    } 
    else if (faunaSize ==2) {
      return bushArray[int(random(bushArray.length))];
    }
    else if (faunaSize >=3) {
      return treeArray[int(random(treeArray.length))];
    } 
    else {
      println("Warning: there was some sort of problem with the image generator");
      return dead;
    }
  }
}

class Block {
  
  float weather;
  int type;
  int altitude;
  int maxHumidity;
  int humidity = 0;
  float temperature;
  int biome = 4;
  int relX;
  int relY;
  int absY;
  int absX;
  Plant grass;
  Plant flora;

  Animal fauna = nullFauna;

  Block(int sx, int sy) {
    absY = sx;
    absX = sy;
    type = 1;
    altitude = 0;
    maxHumidity = 0;
    //type 1 is dirt
    temperature=0;
    grass = nullFlora;
    flora = nullFlora;
  }
  Block (int ax, int ay, int typee) {
    absY = ax;
    absX = ay;
    type = typee;
    altitude = 0;
    maxHumidity = 0;
    temperature=0;
    grass = nullFlora;
    flora = nullFlora;
  }

  String biomeName(int row, int column) {
    if (row < worldHeight && column < worldWidth) {
      String name = "";
      if (world[row][column].biome == 0)
        name =  "Artic ";

      else if (world[row][column].biome == 1)
        name =  "Tropical Rainforest ";

      else if (world[row][column].biome == 2)
        name =  "Tundra ";

      else if (world[row][column].biome == 3)
        name =  "Boreal ";

      else if (world[row][column].biome == 4)
        name =  "Grassland ";

      else if (world[row][column].biome == 5)
        name =  "Deciduous Forest ";

      else if (world[row][column].biome == 6)
        name =  "Temperate Rainforest ";

      else if (world[row][column].biome == 7)
        name =  "Desert ";

      else if (world[row][column].biome == 8)
        name =  "Thorn Forest ";

      else if (world[row][column].biome == 9)
        name =  "Badlands";

      return name;
    } 
    else {
      return "";
    }
  }

  void displayOverride(color c) {
   if (absY >= camPosY
      && absY < windowHeight + camPosY
      && absX >= camPosX
      && absX < windowWidth + camPosX) {
      println("Animal Position: " + absX + " , " + absY);
      fill(c);
      rect (relX*zoom, relY*zoom, zoom, zoom);
      noFill();
     } else {
      println("Display is out of bounds "+ camPosX + " < " +absX + " < " + (windowWidth + camPosX) +  " || " + camPosY +" < " +absY + " < " + (windowHeight + camPosY));
    }
  }

  void displayOverride(PImage p) {
    image (p, relX*zoom, relY*zoom, zoom, zoom);
  }

  void display() {

    if (this.type < 0) {
      println("Error: Unrecognized type");
    } 
    else if ( type == 0 ) {
      //ice
      fill(255);
    } 
    else if (type == 1 && grass == nullFlora) {
      //dirt
      fill (75+altitude, 33+altitude, 17+altitude);
    } 
    else if (type == 2) {
      //grass
      fill (74, 118, 56);
    } 
    else if (type == 3) {
      //stone
      fill (159, 162, 157);
    } 
    else if (type == 4) {
      //water
      fill (75+altitude, 114+altitude, 147+altitude);
    } 
    else if (type == 5) {
      //sand
      fill (198, 184, 76);
    }


    rect (relX*zoom, relY*zoom, zoom, zoom);
    //plants!=================================================================
    if (grass != nullFlora && type ==1) {
      fill(grass.leafColor + color(altitude, altitude, altitude));

      //if zoomed in
      if (zoom < 10) {
        rect (relX*zoom,relY*zoom, zoom, zoom); //temporary
      }
      else {
        image(grass.newImg, relX*zoom, relY*zoom, zoom, zoom);
      }
      noFill();
    }
    if (flora != nullFlora && type ==1) {
      fill(flora.leafColor + color(altitude, altitude, altitude));

      //if zoomed in
      if (zoom < 10) {
        rect (relX*zoom, relY*zoom, zoom, zoom); //temporary
      }
      else {
        image(flora.newImg, relX*zoom, relY*zoom, zoom, zoom);
      }
    }

    //IN THE CASE OF ANIMALS
    if (fauna != nullFauna) {
      displayOverride(fauna.furColor);
    }

    noFill(); //resets fill for rain effects

    //add rain effects
    if (transition == false && raining && random(1) > .95 && type != 4 && type != 0) {
      fill(58, 200, 206, 100);
      rect(relX*zoom, relY*zoom, zoom, zoom);
    }
    if (transition  && random(1) > .95 && type != 4 && type != 0) {

      if ( raining)
        fill(58, 200, 206, (transitionPercent)*100);
      else
        fill(58, 200, 206, (1 - transitionPercent)*100);
      rect(relX*zoom, relY*zoom, zoom, zoom);
    }

    //adds cloud effects
    if (zoom <= 8  && transition ==  false && weatherView == true && dist(relX*zoom, relY*zoom, mouseX, mouseY) > 30*zoom) {
      if (raining) {
        fill (197, 219, 214, (weather)*400 - 25);
      } 
      else {
        fill (255, 2625*weather - 1425);
        // fill (255, 25*(weather-.6)*105+150); //equivalent algorithm
      }
    }

    //allows transition from rain to sunny
    if (zoom <= 8 && transition && raining && dist(relX*zoom, relY*zoom, mouseX, mouseY) > 30*zoom) {
      fill (197, 219, 214, (transitionPercent)*(weather*400 - 25)) ;
      rect (relX*zoom, relY*zoom, zoom, zoom);
      fill (255, (1 - transitionPercent)*(25*(weather-.6)*105+150));
    } 
    else if (zoom <= 8  && transition && raining == false && dist(relX*zoom, relY*zoom, mouseX, mouseY) > 30*zoom) {
      fill (197, 219, 214, (1- transitionPercent)*((weather)*400 - 25));
      rect (relX*zoom, relY*zoom, zoom, zoom);
      fill (255, (transitionPercent)*(2625*weather - 1425));
    }

    rect (relX*zoom, relY*zoom, zoom, zoom); //temporary

    noFill();
  } //ennd display
}

class Entity {
  int numDead = 0;
  int x;
  int y;
  String name;
  Entity(int setX, int setY, int ded) {
    x = setX;
    y = setY;
    ded = numDead;
  }
  void setPos(int x_, int y_) {
    x = x_;
    y = y_;
  }


}



void loadImages() {
  text("Loading...", zoom*windowWidth/2, zoom*windowHeight/2);

  //LOADS ALL OF THE GRAPHICS IN ~~~~ &&&&&&&&@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@&&&&&&&&&  ~~~~
  fecesB = loadImage("graphics/graphics_0000_fecesb.png");
  fecesA = loadImage("graphics/graphics_0001_fecesa.png");
  decomposer2B = loadImage("graphics/graphics_0002_decomposer2b.png");
  decomposer2A = loadImage("graphics/graphics_0003_decomposer2a.png");
  decomposer1C = loadImage("graphics/graphics_0004_decomposer1c.png");
  decomposer1B = loadImage("graphics/graphics_0005_decomposer1b.png");
  decomposer1A = loadImage("graphics/graphics_0006_decomposer1.png");
  decomposer0 = loadImage("graphics/decomposer0.png");
  dead = loadImage("graphics/graphics_0008_dead.png");

  bird4 = loadImage("graphics/graphics_0009_bird4.png");
  bird3 = loadImage("graphics/graphics_0010_bird3.png");
  bird2 = loadImage("graphics/graphics_0011_bird2.png");
  bird1 = loadImage("graphics/graphics_0012_bird1.png");
  bird0 = loadImage("graphics/graphics_0013_bird0.png");

  carni9 = loadImage("graphics/graphics_0014_carni9.png");
  carni8 = loadImage("graphics/graphics_0015_carni8.png");
  carni7 = loadImage("graphics/graphics_0016_carni7.png");
  carni6 = loadImage("graphics/graphics_0017_carni6.png");
  carni5 = loadImage("graphics/graphics_0018_carni5.png");
  carni4 = loadImage("graphics/graphics_0019_carni4.png");
  carni3 = loadImage("graphics/graphics_0020_carni3.png");
  carni2 = loadImage("graphics/graphics_0021_carni2.png");
  carni1 = loadImage("graphics/graphics_0022_carni1.png");
  carni0 = loadImage("graphics/graphics_0023_carni0.png");

  herbi9 = loadImage("graphics/graphics_0024_herbi9.png");
  herbi8 = loadImage("graphics/graphics_0025_herbi8.png");
  herbi7 = loadImage("graphics/graphics_0026_herbi7.png");
  herbi6 = loadImage("graphics/graphics_0027_herbi6.png");
  herbi5 = loadImage("graphics/graphics_0028_herbi5.png");
  herbi4 = loadImage("graphics/graphics_0029_herbi4.png");
  herbi3 = loadImage("graphics/graphics_0030_herbi3.png");
  herbi2 = loadImage("graphics/graphics_0031_herbi2.png");
  herbi1 = loadImage("graphics/graphics_0032_herbi1.png");
  herbi0 = loadImage("graphics/graphics_0033_herbi0.png");

  fish4 = loadImage("graphics/graphics_0034_fish4.png");
  fish3 = loadImage("graphics/graphics_0035_fish3.png");
  fish2 = loadImage("graphics/graphics_0036_fish2.png");
  fish1 = loadImage("graphics/graphics_0037_fish1.png");
  fish0 = loadImage("graphics/graphics_0038_fish0.png");

  cell4 = loadImage("graphics/graphics_0039_cell4.png");
  cell3 = loadImage("graphics/graphics_0040_cell3.png");
  cell2 = loadImage("graphics/graphics_0041_cell2.png");
  cell1 = loadImage("graphics/graphics_0042_cell1.png");
  cell0 = loadImage("graphics/graphics_0043_cell0.png");

  tree9 = loadImage("graphics/graphics_0044_tree9.png");
  tree8 = loadImage("graphics/graphics_0045_tree8.png");
  tree7 = loadImage("graphics/graphics_0046_tree7.png");
  tree6 = loadImage("graphics/graphics_0047_tree6.png");
  tree5 = loadImage("graphics/graphics_0048_tree5.png");
  tree4 = loadImage("graphics/graphics_0049_tree4.png");
  tree3 = loadImage("graphics/graphics_0050_tree3.png");
  tree2 = loadImage("graphics/graphics_0051_tree2.png");
  tree1 = loadImage("graphics/graphics_0052_tree1.png");
  tree0 = loadImage("graphics/graphics_0053_tree0.png");

  bush9 = loadImage("graphics/graphics_0054_bush9.png");
  bush8 = loadImage("graphics/graphics_0055_bush8.png");
  bush7 = loadImage("graphics/graphics_0056_bush7.png");
  bush6 = loadImage("graphics/graphics_0057_bush6.png");
  bush5 = loadImage("graphics/graphics_0058_bush5.png");
  bush4 = loadImage("graphics/graphics_0059_bush4.png");
  bush3 = loadImage("graphics/graphics_0060_bush3.png");
  bush2 = loadImage("graphics/graphics_0061_bush2.png");
  bush1 = loadImage("graphics/graphics_0062_bush1.png");
  bush0 = loadImage("graphics/graphics_0063_bush0.png");

  shrub11 = loadImage("graphics/shrub10.png");
  shrub10 = loadImage("graphics/shrub11.png");
  shrub9 = loadImage("graphics/graphics_0064_shrub9.png");
  shrub8 = loadImage("graphics/graphics_0065_shrub8.png");
  shrub7 = loadImage("graphics/graphics_0068_shrub7.png");
  shrub6 = loadImage("graphics/graphics_0069_shrub6.png");
  shrub5 = loadImage("graphics/graphics_0070_shrub5.png");
  shrub4 = loadImage("graphics/graphics_0071_shrub4.png");
  shrub3 = loadImage("graphics/graphics_0072_shrub3.png");
  shrub2 = loadImage("graphics/graphics_0073_shrub2.png");
  shrub1 = loadImage("graphics/graphics_0074_shrub1.png");
  shrub0 = loadImage("graphics/graphics_0075_shrub0.png");

  grass9 = loadImage("graphics/graphics_0076_grass9.png");
  grass8 = loadImage("graphics/graphics_0077_grass8.png");
  grass7 = loadImage("graphics/graphics_0078_grass7.png");
  grass6 = loadImage("graphics/graphics_0079_grass6.png");
  grass5 = loadImage("graphics/graphics_0080_grass5.png");
  grass4 = loadImage("graphics/graphics_0081_grass4.png");
  grass3 = loadImage("graphics/graphics_0082_grass3.png");
  grass2 = loadImage("graphics/graphics_0083_grass2.png");
  grass1 = loadImage("graphics/graphics_0084_grass1.png");
  grass0 = loadImage("graphics/graphics_0085_grass0.png");
}


void fillArrays() {
  grassArray = new PImage[] {
    grass0, grass1, grass2, grass3, grass4, grass5, grass6, grass7, grass8, grass9
  };
  shrubArray = new PImage[] {
    shrub0, shrub1, shrub2, shrub3, shrub4, shrub5, shrub6, shrub7, shrub8, shrub9, shrub10, shrub11
  };
  bushArray = new PImage[] {
    bush0, bush1, bush2, bush3, bush4, bush5, bush6, bush7, bush8, bush9
  };
  treeArray = new PImage[] {
    tree0, tree1, tree2, tree3, tree4, tree5, tree6, tree7, tree8, tree9
  };
  carniArray = new PImage[] {
    carni0, carni1, carni2, carni3, carni4, carni5, carni6, carni7, carni8, carni9
  };
  herbiArray = new PImage[] {
    herbi0, herbi1, herbi2, herbi3, herbi4, herbi5, herbi6, herbi7, herbi8, herbi9
  };
  cellArray = new PImage[] {
    cell0, cell1, cell2, cell3, cell4
  };
  birdArray = new PImage[] {
    bird0, bird1, bird2, bird3, bird4
  };
  fishArray = new PImage[] {
    fish0, fish1, fish2, fish3, fish4
  };
}

class Perk {
  String name;
  String description;
  
  Perk(String n, String d){
    name = n;
    description = d;
  }
  
}

class Plant extends Entity{
  float growthChance;
  color leafColor;
  boolean grass = false;
  int floraHeight;
  PImage floraImg;
  PImage newImg;
  Perk perk1 = nullPerk;
  
  int deathOvercrowded = 0;
  int deathThirst = 0;
  
  Plant(int x, int y, String nam, float chance, int heeight, color leaf, int numDead){
    super(x,y, numDead);
    name = nam;
    growthChance = chance;
    floraHeight = heeight;
    
    
if (heeight <= 0){
    grass = true;
    } else {
    grass = false;
    }
    
    leafColor = leaf;
    //gives the plant a unique clr
    leafColor += (color(int(random(-15,15)),int(random(-15,15)),int(random(-15,15)))); 

}

  
  
 void  setGrowthChance(float chance){
    growthChance = chance;
  }
  
 void setLeafColor(color c){
    leafColor = c;
  }
  
  void assignRandomImage(){
    floraImg = randomImg();
    
    imageRecolor();
  }
  
  void imageRecolor(){
        //after image has been assigned:
 loadPixels(); 
  // Since we are going to access the image's pixels too 
 newImg = floraImg.get();
  floraImg.loadPixels(); 
  for (int ry = 0; ry < floraImg.height; ry++) {
    for (int rx = 0; rx < floraImg.width; rx++) {
      int loc = rx + ry*floraImg.width;
      
      // Image Processing would go here
      // If we were to change the RGB values, we would do it here, before setting the pixel in the display window.
      
      // Set the display pixel to the image pixel
      if (alpha(newImg.pixels[loc]) > 200){
      newImg.pixels[loc] =  leafColor;
      }
    }
  }
  //println("Leafcolor is: " + leafColor);
  updatePixels();
  }
  
  PImage randomImg(){
    if (floraHeight <= 0){
      return grassArray[int(random(grassArray.length))];
    } else if (floraHeight == 1){
      return shrubArray[int(random(shrubArray.length))];
    } else if (floraHeight ==2){
            return bushArray[int(random(bushArray.length))];
    }else if (floraHeight >=3){
          return treeArray[int(random(treeArray.length))];
    } else {
      println("Warning: there was some sort of problem with the image generator");
    return dead; 
  }
  }
  
}

class Strategy {
  String name = "null";

  Strategy(String nam) {
    name = nam;
  }

void action (Animal subject, String stratName) {
  if (stratName == "Wander") {
    // wander code
    println(int(random(-1,1)));

    int gainX = int(random(-2,2));
    int gainY = int(random(-2,2));
    
        if (gainY == 0 && gainX == 0) 
        return;
    // checks to make sure that the predicted values are within the map
    if ((gainX + subject.x) < 0 || (gainX + subject.x) >= worldWidth){
      gainX = -gainX;
    }
        if ((gainY + subject.y) < 0 || (gainY + subject.y) >= worldHeight){
      gainY = -gainY;
    }

    // adds the values together.
    subject.x += gainX;
    subject.y += gainY;
    
    world[subject.x][subject.y].fauna = subject;
    
        //replaces the old spot with a blank
    world[subject.x-gainX][subject.y-gainY].fauna = nullFauna;

  } 
  else {
    println("Warning: Unrecognized Strategy Type");
  }
}
}

class World{
  // please put the globals in here:
}
