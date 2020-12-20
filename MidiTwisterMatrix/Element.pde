import controlP5.*;
ControlP5 cp5;

//Colors
int colorKnobEmpty = color(0, 0, 150, 80); 
int colorKnobAssigned = color(150, 0, 150, 80);
int colorKnobPressed =  color(0, 0, 150, 80); 
int colorUtilityKnob = color(0, 150, 0, 80); 

class Element {
  //int id=-1;
  Matrix matrix; 
  int index = -1; 
  float []value; 
  Knob [] knob;
  boolean isPressed = false; 
  boolean hasStarted=false;
  SynthType synth= null; 

  float [] variables; 

  Knob [] utilityKnobs; 

  //util 
  boolean [] isUtility ; 
  int [] utilParentId; 

  boolean isInitialized = false; 
  boolean isAssigned = false; 

  int tempSynthSelect =-1; 

  void setKnobColor(int panel, color c) {
    knob[panel].setColorBackground(c);
  }

  void reset() {
    isAssigned = false; 
    hasStarted = false; 

    for (int i=0; i<knob.length; i++) {
      value[i]=0; 
      knob[i].setValue(0);
      knob[i].setLabel (i==0? (index+": empty") : (i+":"+index));
      //color
      setKnobColor(i, colorKnobEmpty);
    }

    synth=null;
  }

  Element(Matrix matrix, int index, ControlP5 cp5, float posX, float posY, float size, Group [] panelGroups) {
    this.matrix = matrix; 
    this.index = index; 

    int nPanels = panelGroups.length; 
    this.value  =new float[nPanels];
    isInitialized= true;

    knob = new Knob[max(0, panelGroups.length)]; 

    isUtility= new boolean [nPanels]; 
    utilParentId = new int[nPanels]; 

    for (int i=0; i<knob.length; i++) {
      knob[i] =  cp5.addKnob("p"+i+"knob"+index)
        .setRange(0, 1)
        .setValue(0)
        .setPosition(posX, posY)
        .setRadius(size)
        .setColorBackground(colorKnobEmpty) 
        .setColorActive(color(255, 0, 0))
        .setLabel( (i==0)? (index+": empty") : (i+":"+index))
        .setDragDirection(Knob.VERTICAL)
        .setGroup(panelGroups[i]); 
      ;
    }
  }
  void setPressed(boolean isPressed, int panel) {
    this.isPressed = isPressed; 
    if (isPressed) {
      //if depressed after selecting a synth (when we dont have already one) then assign synth 
      if (isAssigned==false  && panel==0  && tempSynthSelect>=0) {
        setSynth(SynthManager.getSynth(tempSynthSelect));
        return;
      }

      if (isAssigned && !hasStarted) {
        onStartSynth();
        //sendAmp();
      }
    } else {// when depressed
    }
    //ui
    if (matrix.updateVisuals) {
      knob[panel].setColorBackground/*Foreground*/( isPressed? color(0, 125, 125): color(125, 125, 0));
    }
  }
  void setValue(float value, int panel) {
    this.value[panel] = value;

    //util
    if (isUtility[panel]) {
      int parentId = utilParentId[panel];
      println("util "+index+" parent:"+ parentId); 
      matrix.elements[parentId].variables[index] = value; 
      matrix.onSendProperty(parentId, matrix.elements[parentId].synth.variables[index], value); 
      //matrix.elements[utilParentId[panel]].sendFromUtil(index, ;
    } else {

      //chose synth
      if (panel==0) {
        if (isPressed==false) {
          if ((isAssigned==false)) {
            int whichSynth =constrain(floor(SynthManager.nSynths*value), 0, SynthManager.nSynths-1) ;
            if (tempSynthSelect != whichSynth) {
              tempSynthSelect = whichSynth ; 
              knob[0].setLabel ("-"+SynthManager.synthTypes[whichSynth]+"-"); 
              println("Selecting synth:  "+SynthManager.synthTypes[whichSynth]);//works
            }
          }
        }
        //focus
        if (isAssigned) {
          matrix.setFocusedChannel(index);
        }

        if (hasStarted) {
          if (!isPressed)onSendAmp();
          else  onSendPan();
        }
      }
    }
    //ui
    if (matrix.updateVisuals) {
      knob[panel].setValue(value);
    }
  }

  void onSendAmp() {
    matrix.onSendAmp(this.index, value[0]); 
    //println("->send amp");
  }
  void onSendPan() {
    matrix.onSendPan(this.index, value[0]); 
    //println("->send pan");
  }
  void onStartSynth() {
    println("starting synth channel "+index);
    matrix.onSynthStart(this);
    hasStarted=true;
  }


  void setSynth(  Synth synthTypeKey) {
    if ( SynthManager.containsSynth(synthTypeKey)) {
      setSynth(SynthManager.getSynth(synthTypeKey));
    } else {
      println("*Synth name not found");
    }
  }

  void setSynth(SynthType synth) {
    if (isAssigned) {
      println("*Channel already assigned ("+index+ ")"); 
      return;
    }

    println("Assinging selected synth:" + synth.name);
    this.synth = synth; 
    this.variables= new float [synth.nVariables]; 
    //set knob label 
    setLabel(0, this.synth.name);  
    isAssigned= true;

    //get utility knobs 
    utilityKnobs = new Knob [synth.nVariables]; 
    println(index+ " UKnobs:"+ utilityKnobs.length); 

    //set color 
    setKnobColor(0, colorKnobAssigned);
  }

  void setFocused(boolean val) {
    if (val==true) {

      int nVariables = synth.nVariables; 
      if (nVariables>=16) {
        println("*Variables more than 16"); 
        return;
      }
      println("Focusing:"+ index); 
      for (int i=0; i< nVariables; i++) {
        matrix.elements[i].setUtilityKnob(index, 1, this.synth.variables[i], variables[i]);
      }
    } else {
      println("DeFocusing:"+ index); 
      for (int i=0; i< synth.nVariables; i++) {
        matrix.elements[i].releaseUtilityKnob(1);
      }
    }
  }

  void releaseUtilityKnob(int panel) {
    isUtility[panel]= false; 
    utilParentId [panel]= -1;
    knob[panel].setLabel(""); 
    //knob[panel].setValue(value) ;
    //set color 
    setKnobColor(panel, colorKnobEmpty);
  }

  void setUtilityKnob( int parentId, int panel, String label, float value) {//FIXME add channel id 
    isUtility[panel]= true; 
    utilParentId [panel]= parentId;
    //label 
    knob[panel].setLabel(label); 
    knob[panel].setValue(value) ;
    //set color 
    setKnobColor(panel, colorUtilityKnob);
  }

  void setLabel(int panel, String label) {
    knob[panel].setLabel(label);
  }

  //set synth
  //void setSynth(SynthType synth) {
  //  if (synth==null) {
  //    this.synth = synth; 
  //    knob[0].setLabel(synth.name);
  //  } else {
  //    println("Delete old synth first");
  //  }
  //}
}
