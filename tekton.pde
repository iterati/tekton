import processing.serial.*;
import controlP5.*;

Serial port;
ControlP5 cp5;

Group grpPalette;
Button[] btnPalette = new Button[32 * 4];
Button btnGlow;
int activeColor = -1;
int activeVariant = -1;

Mode mode;
Boolean init = true;
Boolean lightConnected = false;

void setup() {
  int v, xo, yo;
  size(800, 600);

  cp5 = new ControlP5(this);

  grpPalette = cp5.addGroup("palette")
    .setPosition(0, 0)
    .hideBar()
    .hideArrow();

  btnGlow = cp5.addButton("glow")
    .setPosition(0, 0)
    .setSize(40, 40)
    .setColorBackground(color(240))
    .setCaptionLabel("")
    .setGroup(grpPalette)
    .hide();

  for (int g = 0; g < 4; g++) {
    for (int s = 0; s < 4; s++) {
      for (int i = 0; i < 8; i++) {
        xo = (g % 2) * 400;
        yo = (g / 2) * 182;
        v = (s << 6) + i + (g * 8);
        btnPalette[i] = cp5.addButton("palette" + v, v)
          .setPosition(xo + 44 + (i * 40), yo + 230 + + (s * 40))
          .setCaptionLabel("" + v)
          .setSize(32, 32)
          .setGroup(grpPalette)
          .setColorBackground(getColor(v));
      }
    }
  }

  for (String p: Serial.list()) {
    try {
      port = new Serial(this, p, 57600);
      lightConnected = true;
    } catch (Exception e) {
    }
  }

  mode = new Mode(0.0, 0.0);
  mode.hide();
  init = false;

  if (!lightConnected) {
    mode.tlLoading.setText("Connect light and restart");
  }
}

void sendValue(int addr, int val) {
  port.write('W');
  port.write(addr);
  port.write(val);
  mode.update(addr, val);
}

void loadMode() {
  String[] strs = loadStrings(mode.tfPath.getText());
  decompressMode(strs[0]);
}

void saveMode() {
  String[] strs = new String[1];
  strs[0] = compressMode();
  saveStrings(mode.tfPath.getText(), strs);
}

void draw() {
  int in1, in2;

  background(8);
  if (lightConnected && port.available() > 1) {
    in1 = port.read();
    in2 = port.read();
    if (in1 == 100) {
      port.write('D');
    } else if (in1 == 101) {
      mode.hide();
      btnGlow.hide();
      activeColor = -1;
      activeVariant = -1;
    } else if (in1 == 102) {
      mode.setLightIdx(in2);
      mode.show();
    } else if (in1 >= 0 && in1 < 38) {
      mode.update(in1, in2);
    }
  } else {
  }
}

void controlEvent(ControlEvent theEvent) {
  int val = int(theEvent.getValue());
  String evt = theEvent.getName();

  if (!init) {
    if (evt.startsWith("accMode")) {
      sendValue(0, val);
    } else if (evt.startsWith("accSens")) {
      sendValue(1, val);
    } else if (evt.startsWith("pattern0")) {
      sendValue(2, val);
    } else if (evt.startsWith("pattern1")) {
      sendValue(20, val);
    } else if (evt.startsWith("color")) {
      if (val % 16 < mode.numColors[val >> 6]) {
        activeVariant = val >> 6;
        activeColor = val % 16;
        btnGlow.setPosition(80 + (activeColor * 40), 96 + (activeVariant * 40));
        btnGlow.show();
      }
    } else if (evt.startsWith("lessA")) {
      mode.setNumColors(0, mode.numColors[0] - 1);
      sendValue(3, mode.numColors[0]);
    } else if (evt.startsWith("lessB")) {
      mode.setNumColors(1, mode.numColors[1] - 1);
      sendValue(21, mode.numColors[1]);
    } else if (evt.startsWith("moreA")) {
      mode.setNumColors(0, mode.numColors[0] + 1);
      sendValue(3, mode.numColors[0]);
      port.write('R');
      port.write(mode.numColors[0] + 3);
    } else if (evt.startsWith("moreB")) {
      mode.setNumColors(1, mode.numColors[1] + 1);
      sendValue(21, mode.numColors[1]);
      port.write('R');
      port.write(mode.numColors[1] + 21);
    } else if (evt.startsWith("reloadMode")) {
      port.write('X');
    } else if (evt.startsWith("writeMode")) {
      port.write('S');
    } else if (evt.startsWith("saveMode")) {
      // read from textfield and try to write more to disk
      saveMode();
    } else if (evt.startsWith("loadMode")) {
      loadMode();
    } else if (evt.startsWith("nextMode")) {
      port.write('N');
    } else if (evt.startsWith("prevMode")) {
      port.write('P');
    } else if (evt.startsWith("palette")) {
      if (activeColor >= mode.numColors[activeVariant]) {
      } else if (activeVariant < 0 || activeColor < 0) {
      } else {
        sendValue((activeVariant * 18) + activeColor + 4, val);
      }
    }
  } else if (theEvent.isGroup()) {
  } else if (theEvent.isController()) {
  }
}

char encode(int i) {
  return char(i + 48);
}

int decode(char c) {
  return int(c) - 48;
}

String compressMode() {
  char[] rtn = new char[70];
  rtn[0] = 'Z';
  rtn[1] = encode((mode.accSens << 3) + mode.accMode);
  for (int v = 0; v < 2; v++) {
    rtn[(v * 34) + 2] = encode(mode.pattern[v]);
    rtn[(v * 34) + 3] = encode(mode.numColors[v]);
    for (int s = 0; s < 16; s++) {
      rtn[(v * 34) + (s * 2) + 4] = encode((mode.colors[v][s] >> 6));
      rtn[(v * 34) + (s * 2) + 5] = encode((mode.colors[v][s] % 64));
    }
  }

  return new String(rtn);
}

void decompressMode(String s) {
  if (s.length() == 70 && s.charAt(0) == 'Z') {
    sendValue(0, decode(s.charAt(1)) % 8);
    sendValue(1, decode(s.charAt(1)) >> 3);
    for (int v = 0; v < 2; v++) {
      sendValue((v * 18) + 2, decode(s.charAt((v * 34) + 2)));
      sendValue((v * 18) + 3, decode(s.charAt((v * 34) + 3)));
      for (int c = 0; c < 16; c++) {
        sendValue((v * 18) + c + 4,
            (decode(s.charAt((v * 34) + (2 * c) + 4)) << 6) +
            decode(s.charAt((v * 34) + (2 * c) + 5)));
      }
    }
  }
}
