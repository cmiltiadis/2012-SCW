void resetSynths() {
  println("Reset Synths");
  matrix.killAll(); 
  //cp5.remove( 
  //cp5 = new ControlP5(this); 
  //matrix = new Matrix(cp5);
}

class Matrix {
  HashMap <String, Integer> channels;// =new HashMap<>();
  //OscP5 osc;
  int nKnobs= 16;
  Element [] elements  ; 
  int knobSize = 25;   
  float spacing =knobSize*2 +15; 
  int startX = 100;  
  int startY = 100; 

  final int  nChannels = 16; 

  //int nPanelGroups = 1; 
  Group [] panelGroups = new Group[4]; 
  //Group panel1, panel2, panel3, panel4; 

  boolean updateVisuals = true; 

  boolean sendOsc = true; 

  int focusedPanel =-1; 
  int focusedChannel = -1; 


  /*
  Matrix (ControlP5 cp5) {
   Matrix(cp5, null); 
   }*/

  Matrix (ControlP5 cp5) {
    //make UI Panels
    for (int i=0; i<  panelGroups.length; i++) {
      panelGroups[i]= cp5.addGroup("Panel_"+ i)
        .setPosition(startX +((i%2))*(4+0.5)*spacing, startY + floor(i/2)*spacing*(4+0.5))
        //.setSize(spacing*4,spacing*4)
        //.seSize(100,100)
        .setBackgroundHeight(300)
        //.setBackgroundWidth(300)
        .setBackgroundColor(color(125))
        ;
    };
    channels=new HashMap<String, Integer>();
    //
    elements = new Element [nKnobs]; 
    for (int i=0; i<nKnobs; i++) {
      int posX = i%4;
      int posY = floor(i/4); 
      elements [i] = new Element (this, i, cp5, /*startX +*/ posX*spacing, /* startY+*/ posY*spacing, knobSize, panelGroups );
    }
  }

  void setFocusedChannel(int index) {
    if (focusedChannel!=index) {
      println("Focus:"+index); 
      if (focusedChannel>=0) elements[focusedChannel].setFocused(false);
      
      focusedChannel= index; 
      elements[index].setFocused(true);
    }
  }

  void setActivePanel(int panelN) {

    if (panelN!= focusedPanel) {
      if (focusedPanel>=0 && focusedPanel<panelGroups.length)
        panelGroups[ focusedPanel].setBackgroundColor(color(50, 125, 125)); 
      focusedPanel= panelN; 
      panelGroups[ focusedPanel].setBackgroundColor(color(125, 125, 0));
    }
  }

  void setChannel(int channel, String synthTypeKey) {
    if (channel<0 || channel>nChannels) {
      println("*Channel number invalid");  
      return;
    }
    if ( SynthManager.containsSynth(synthTypeKey)) {
      setChannel(channel, SynthManager.getSynth(synthTypeKey));
    } else {
      println("*Synth name not found");
    }
  }

  void setChannel(int channel, SynthType synth) {
    if (channel<0 || channel>nChannels) {
      println("*Channel number invalid");  
      return;
    }
    if (elements[channel].isAssigned==true) {
      println("*Channel is occupied");
      return;
    }

    elements[channel].setSynth(synth);
  }

  //MIDI receiver 
  void MidiFighterCC(int channel, int number, int valueUnNormalized) {

    //changed panel (1 of 4) 
    if (channel==3 && number <4) {
      setActivePanel(number); 
      return;
    }

    float value = valueUnNormalized/127.0; //critical
    int panel = floor(number/16); 
    //setActivePanel(panel); 
    int posX = number%4; 
    int posY = floor((number-panel*16)/4); 


    switch (channel) {
    case 0: 
      elements [posX+ posY*4].setValue(value, panel); 
      break; 
    case 1: //pressed 
      elements [posX+ posY*4]. setPressed( value!=0, panel); 
      break; 
    default: 
      println ("Uncaught midi channel");
    }
  }

  /*  OSC  */
  void onSynthStart(Element element) {
    //register synth to map
    channels.put(element.synth.name, element.index);
    //osc
    OscMessage msg=new OscMessage (oscAddr);
    msg.add("start");
    msg.add(element.index);
    msg.add (element.synth.name );
    msg.add(0); //dont play yet
    println("Sending OSC start"); 
    //send
    sendOscMessage(msg);
  }

  void onSynthPlay() {
  }

  void  onSendProperty(int index, String property, float value) {
    OscMessage msg=new OscMessage (oscAddr);
    msg.add(index); 
    msg.add(property); 
    msg.add( value); 
    //send
    sendOscMessage(msg);
  }

  void onSendAmp(int id, float amp) {
    OscMessage msg=new OscMessage (oscAddr);
    msg.add(oscAmp);
    msg.add(id);
    msg.add (constrain(amp, 0, 1) );
    //send
    sendOscMessage(msg);
  }

  void onSendPan(int id, float pan) {
    OscMessage msg=new OscMessage (oscAddr);
    msg.add(oscPan);
    msg.add(id);
    msg.add (constrain(pan, 0, 1)*2f-1 );
    //send
    sendOscMessage(msg);
  }
  void OnStopSynth(Element e) {
    println("Kill "+e.index); 
    OscMessage msg=new OscMessage (oscAddr);
    msg.add(oscKill);
    msg.add (e.synth.name );
    //send
    sendOscMessage(msg);
  }

  void reset() {
    println("Matrix reset"); 
    for (Element element : elements) {
      element.reset();
    }
  }
  void killAll() {
    println("Kill All"); 

    OscMessage msg=new OscMessage (oscAddr);
    msg.add(oscKillAll);
    //send
    sendOscMessage(msg);

    //
    reset();
  }
}
