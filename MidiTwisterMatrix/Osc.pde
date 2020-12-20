import oscP5.*;
import netP5.*;
OscP5 oscP5;
NetAddress myBroadcastLocation; 

boolean autoStartOsc = true; 

int outPort = 57120; 
int inPort = 6969; 
String outIP = "127.0.0.1"; 

static String oscAddr = "/p5"; 
static String oscStart = "start"; 
static String oscKill = "kill"; 
static String oscKillAll = "killAll"; 
static String oscAmp = "amp"; 
static String oscPan= "pan"; 

static String oscRecord= "record"; 
boolean isRecording = false; 

Group oscUIGroup; 

void startOsc() {
  oscP5 = new OscP5(this, inPort);
  myBroadcastLocation = new NetAddress(outIP, outPort);
}

void setupOsc() {
  startOsc(); 
  oscUI();
}

void onRecord(boolean val ) {
  //if (
  isRecording=!isRecording; 
  println("Recording:"+ isRecording);
  OscMessage msg=new OscMessage (oscAddr);
  msg.add(oscRecord); 
  msg.add(isRecording?1:0);
  sendOscMessage(msg); 
  println("Recording:"+ isRecording);
}

void sendOscMessage(OscMessage msg ) {
  oscP5.send(msg, myBroadcastLocation );
}


void oscUI() {
  oscUIGroup =cp5.addGroup("oscUIGroup")
    .setPosition(10, 10)
    .setBackgroundHeight(100)
    .setBackgroundColor(color(255, 50))
    ;

  int posX = 20; 
  int posY = 20; 
  int spacingX = 50; 
  int sizeY = 20; 

  cp5.addTextfield("outIP")
    .setPosition(posX, posY)
    .setSize(spacingX, sizeY)
    //.setFont(font)
    .setFocus(true)
    //.setColor(color(255,0,0))
    .setValue(outIP)
    .setGroup(oscUIGroup)
    ; 
  cp5.addTextfield("outPort")
    .setPosition(posX+=(spacingX), posY)
    .setSize(spacingX, sizeY)
    //.setFont(font)
    .setFocus(true)
    //.setColor(color(255,0,0))
    .setValue(outPort+"")
    .setGroup(oscUIGroup)
    ;

  cp5.addTextfield("inPort")
    .setPosition(posX+=spacingX, posY)
    .setSize(spacingX, sizeY)
    //.setFont(font)
    .setFocus(true)
    //.setColor(color(255,0,0))
    .setValue(inPort+"")
    .setGroup(oscUIGroup)
    ;

  cp5.addBang("connectOsc")
    .setPosition(posX+=spacingX*1.5, posY)
    .setSize(spacingX, sizeY)
    .setGroup(oscUIGroup)
    ;

  cp5.addToggle("isConnected")
    .setPosition(posX+=spacingX*1.5, posY)
    .setSize(spacingX, sizeY)
    .setValue(oscP5==null)
    .setMode(ControlP5.SWITCH)
    .setGroup(oscUIGroup)
    //.setEnabled ( false) 
    ;

  ///MAIN 
  cp5.addBang("resetSynths")
    .setPosition(posX+=spacingX*1.5, posY)
    .setSize(spacingX, sizeY)
    .setGroup(oscUIGroup)
    ;

  //cp5.addToggle("onRecord")
  //  .setPosition(posX+=spacingX*1.5, posY)
  //  .setSize(spacingX, sizeY)
  //  .setMode(ControlP5.SWITCH)
  //  .setValue(isRecording)
  //  .setGroup(oscUIGroup)
  //  ;
}

void connectOsc () {
  if (oscP5!=null) {
    println("Already connected");
  } else {
    oscP5 =  new OscP5(this, inPort);
  }
}


void setOutPort(String value) {
}

void setIp(String value) {
}
