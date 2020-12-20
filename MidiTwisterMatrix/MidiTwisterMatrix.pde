/*
Midi Fighter Twister as Supercollider mixer
Constantinos Miltiadis 
December 2020 
Helsinki 
studioany.com
c.miltiadis@gmail.com
*/
/*
TO DO 
- send to SC 
- Handshake 
- Color - active inactive etc 
*/
import themidibus.*; //Import the library

MidiBus myBus; // The MidiBus
Matrix matrix ; 
boolean printlnCC= false;

void setup() {
  size(800, 800);
  background(0);
  //start UI
  cp5 = new ControlP5(this);
  //start OSC
  if ( autoStartOsc) setupOsc(); 
  //get synth list
  populateSynths(); 
  //start matrix
  matrix = new Matrix( cp5); 
  

  matrix.setChannel(3,"Master");

  // setupKnobs(); 

  MidiBus.list(); // List all available Midi devices on STDOUT. This will show each device's index and name.
  // Either you can
  myBus = new MidiBus(this, 0, 1); // Create a new MidiBus using the device index to select the Midi input and output devices respectively.

  // or you can ...
  //                   Parent         In                   Out
  //                     |            |                     |
  //myBus = new MidiBus(this, "IncomingDeviceName", "OutgoingDeviceName"); // Create a new MidiBus using the device names to select the Midi input and output devices respectively.
  // or for testing you could ...
  //myBus = new MidiBus(this, 0, "Java Sound Synthesizer"); // Create a new MidiBus with no input device and the default Java Sound Synthesizer as the output device.
}

void draw() {
  background(0); 
  /*
  int channel = 0;
   int pitch = 64;
   int velocity = 127;
   
   myBus.sendNoteOn(channel, pitch, velocity); // Send a Midi noteOn
   delay(200);
   myBus.sendNoteOff(channel, pitch, velocity); // Send a Midi nodeOff
   
   int number = 0;
   int value = 90;
   
   myBus.sendControllerChange(channel, number, value); // Send a controllerChange
   delay(2000);
   
   */
}

void noteOn(int channel, int pitch, int velocity) {
  // Receive a noteOn
  println();
  println("Note On:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void noteOff(int channel, int pitch, int velocity) {
  // Receive a noteOff
  println();
  println("Note Off:");
  println("--------");
  println("Channel:"+channel);
  println("Pitch:"+pitch);
  println("Velocity:"+velocity);
}

void controllerChange(int channel, int number, int value) {
  if (printlnCC) {
    // Receive a controllerChange
    println();
    println("Controller Change:");
    println("--------");
    println("Channel:"+channel);
    println("Number:"+number);
    println("Value:"+value);
  }
  OnCC(channel, number, value);
}

void delay(int time) {
  int current = millis();
  while (millis () < current+time) Thread.yield();
}
