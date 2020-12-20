import java.util.HashMap;
import java.util.Set;
//synth names
enum Synth {
  None, Master, Test, Mic
}
//what type of synth
enum SynthKind {
  Effect, SoundGen, Singular
}// 



void populateSynths() {
  SynthManager.addSynth (new SynthType(Synth.Test, new String[]{"Test synth", "amp", "pan" } ));

  SynthManager.addSynth ( new SynthType(Synth.None, new String[]{"Dummy synth"})); 

  SynthManager.addSynth ( new SynthType(Synth.Master, new String[]{"Master track", "amp", "pan"}));

  SynthManager.addSynth ( new SynthType(Synth.Mic, new String[]{"Microphone", "amp", "pan", "in", "out"}));
}

static class SynthManager {
  static HashMap <String, SynthType> synths =  new HashMap <String, SynthType>(); 
  static String [] synthTypes = new String []{};
  static int nSynths=0; 

  static void addSynth(SynthType synth) {
    synths.put(synth.synth.toString(), synth);
    updateSynthList();
  }

  static void updateSynthList() {
    synthTypes = new String[synths.size()]; 
    Set <String> sTypes = synths.keySet(); 

    int counter=0; 
    print("SynthTypes: "); 
    for (String name : sTypes) {
      synthTypes[counter] = name.toString(); 
      counter++; 
      print(name+"  ");
    }
    println();

    nSynths   = counter;
  }

  static SynthType getSynth(Synth synthName) {
    return synths.get(synthName.toString());
  }

  static SynthType getSynth(String synthName) {
    return synths.get(synthName);
  }
  static SynthType getSynth(int index) {
    return synths.get(synthTypes[index]);
  }

  static boolean   containsSynth(String  synthTypeKey) {
    return synths.containsKey(  synthTypeKey);
  }
  static boolean   containsSynth(Synth  synthTypeKey) {
    return synths.containsKey(  synthTypeKey.toString());
  }
}


class SynthType {
  public String name;
  public Synth synth;
  String [] variables; 
  int nVariables =0;
  SynthType (Synth synth, String [] variables) {
    this.synth=synth;
    this.name = synth.toString(); 
    this.variables = variables;
    nVariables = variables.length;
  }
}
