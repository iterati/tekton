import controlP5.*;

int[][] palette = new int[][] {
  {0, 0, 0},
  {255, 255, 255},
  {64, 0, 0},
  {64, 64, 0},
  {0, 64, 0},
  {0, 64, 64},
  {0, 0, 64},
  {64, 0, 64},
  {255, 0, 0},
  {255, 0, 0},
  {224, 32, 0},
  {192, 64, 0},
  {160, 96, 0},
  {128, 128, 0},
  {96, 160, 0},
  {64, 192, 0},
  {32, 224, 0},
  {0, 255, 0},
  {0, 224, 32},
  {0, 192, 64},
  {0, 160, 96},
  {0, 128, 128},
  {0, 96, 160},
  {0, 64, 192},
  {0, 32, 224},
  {0, 0, 255},
  {32, 0, 224},
  {64, 0, 192},
  {96, 0, 160},
  {128, 0, 128},
  {160, 0, 96},
  {192, 0, 64},
  {224, 0, 32},
};


class Mode {
  Group grpMode;
  Textlabel tlTitle, tlLoading;
  DropdownList ddlAccMode, ddlAccSens;
  DropdownList[] ddlPattern = new DropdownList[2];
  Textfield tfPath;
  Button btnReload, btnWrite, btnSave, btnLoad;
  Button[] btnCycle = new Button[2];
  Button[] btnLess = new Button[2];
  Button[] btnMore = new Button[2];
  Button[][] btnColors = new Button[2][16];
  int accMode, accSens;
  int[] pattern = new int[2];
  int[] numColors = new int[2];
  int[][] colors = new int[2][16];

  Mode(float x, float y) {
    grpMode = cp5.addGroup("mode")
      .setPosition(x, y)
      .setBackgroundColor(color(192))
      .hideBar()
      .hideArrow();

    tlLoading = cp5.addTextlabel("loading")
      .setText("Loading data from light...")
      .setPosition(120, 100)
      .setColorValue(0xff8888ff)
      .setFont(createFont("Arial", 48))
      .hide();

    tlTitle = cp5.addTextlabel("title")
      .setText("Mode 0")
      .setPosition(330, 20)
      .setColorValue(0xff8888ff)
      .setFont(createFont("Arial", 32))
      .setGroup(grpMode);

    btnCycle[0] = cp5.addButton("prevMode")
      .setPosition(280, 30)
      .setSize(20, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("<<")
      .setGroup(grpMode);

    btnCycle[1] = cp5.addButton("nextMode")
      .setPosition(490, 30)
      .setSize(20, 20)
      .setColorBackground(color(64))
      .setCaptionLabel(">>")
      .setGroup(grpMode);

    for (int v = 0; v < 2; v++) {
      for (int s = 0; s < 16; s++) {
        btnColors[v][s] = cp5.addButton("color" + v + "_" + s)
          .setValue((v << 6) + s)
          .setPosition(84 + (s * 40), 100 + (v * 40))
          .setSize(32, 32)
          .setColorBackground(color(64))
          .setCaptionLabel("")
          .setGroup(grpMode);
      }
    }

    btnLess[0] = cp5.addButton("lessA")
      .setPosition(34, 104)
      .setSize(40, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("Less")
      .setGroup(grpMode);

    btnLess[1] = cp5.addButton("lessB")
      .setPosition(34, 144)
      .setSize(40, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("Less")
      .setGroup(grpMode);

    btnMore[0] = cp5.addButton("moreA")
      .setPosition(726, 104)
      .setSize(40, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("More")
      .setGroup(grpMode);

    btnMore[1] = cp5.addButton("moreB")
      .setPosition(726, 144)
      .setSize(40, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("More")
      .setGroup(grpMode);

    btnReload = cp5.addButton("reloadMode")
      .setPosition(110, 190)
      .setSize(80, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("Reload Mode")
      .setGroup(grpMode);

    btnSave = cp5.addButton("writeMode")
      .setPosition(210, 190)
      .setSize(80, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("Write Mode")
      .setGroup(grpMode);

    btnWrite = cp5.addButton("saveMode")
      .setPosition(640, 190)
      .setSize(30, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("Save")
      .setGroup(grpMode);

    btnLoad = cp5.addButton("loadMode")
      .setPosition(680, 190)
      .setSize(30, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("Load")
      .setGroup(grpMode);

    tfPath = cp5.addTextfield("path")
      .setValue("")
      .setPosition(490, 190)
      .setSize(140, 20)
      .setColorBackground(color(64))
      .setCaptionLabel("")
      .setGroup(grpMode);

    ddlPattern[0] = buildPatternDropdown(0)
      .setPosition(70, 70)
      .setSize(150, 500)
      .setItemHeight(15)
      .setColorBackground(color(64))
      .setCaptionLabel("Pattern 1")
      .setGroup(grpMode);

    ddlAccMode = buildAccModeDropdown()
      .setPosition(240, 70)
      .setSize(150, 500)
      .setItemHeight(15)
      .setColorBackground(color(64))
      .setCaptionLabel("Trigger Mode")
      .setGroup(grpMode);

    ddlAccSens = buildAccSensDropdown()
      .setPosition(410, 70)
      .setSize(150, 500)
      .setItemHeight(15)
      .setColorBackground(color(64))
      .setCaptionLabel("Sensitivity")
      .setGroup(grpMode);

    ddlPattern[1] = buildPatternDropdown(1)
      .setPosition(580, 70)
      .setSize(150, 500)
      .setItemHeight(15)
      .setColorBackground(color(64))
      .setCaptionLabel("Pattern 2")
      .setGroup(grpMode);
  }

  void setLightIdx(int i) {
    grpMode.setCaptionLabel("Mode " + (1 + i));
    tlTitle.setText("Mode " + (1 + i));
    tfPath.setValue("mode" + (1 + i) + ".mde");
  }

  void update(int addr, int val) {
    if (addr == 0) {
      setAccSens(val);
    } else if (addr == 1) {
      setAccSens(val);
    } else if (addr == 2) {
      setPattern(0, val);
    } else if (addr == 3) {
      setNumColors(0, val);
    } else if (addr < 20) {
      setColor(0, addr - 4, val);
    } else if (addr == 20) {
      setPattern(1, val);
    } else if (addr == 21) {
      setNumColors(1, val);
    } else if (addr < 38) {
      setColor(1, addr - 22, val);
    }
  }

  void hide() {
    grpMode.hide();
    tlLoading.show();
  }

  void show() {
    tlLoading.hide();
    grpMode.show();
  }

  void setAccMode(int val) {
    ddlAccMode.setCaptionLabel(getAccModeName(val));
    accMode = val;
  }

  void setAccSens(int val) {
    ddlAccSens.setCaptionLabel(getAccSensName(val));
    accSens = val;
  }

  void setPattern(int var, int val) {
    ddlPattern[var].setCaptionLabel(getPatternName(var, val));
    pattern[var] = val;
  }

  void setColor(int var, int slot, int val) {
    btnColors[var][slot].setColorBackground(getColor(val));
    colors[var][slot] = val;
    setNumColors(var, numColors[var]);
  }

  void setNumColors(int var, int val) {
    if (val < 1) {
      return;
    }
    numColors[var] = val;
    if (val == 1) {
      btnLess[var].hide();
      btnMore[var].show();
    } else if (val == 16) {
      btnLess[var].show();
      btnMore[var].hide();
    } else {
      btnLess[var].show();
      btnMore[var].show();
    }
    for (int i = 0; i < 16; i++) {
      if (i < val) {
        btnColors[var][i].setCaptionLabel("");
      } else {
        btnColors[var][i].setCaptionLabel("off").setColorBackground(0);
      }
    }
  }
}


int getColor(int v) {
  int shade = v >> 6;
  int alpha = 63 + (192 >> shade);
  return (alpha << 24) + (palette[v % 32][0] << 16) + (palette[v % 32][1] << 8) + palette[v % 32][2];
}

DropdownList buildAccSensDropdown() {
  DropdownList dd = cp5.addDropdownList("accSens");
  dd.setBackgroundColor(color(0));
  dd.setItemHeight(20);
  dd.setBarHeight(15);
  for (int j = 0; j < 3; j++) {
    dd.addItem(getAccSensName(j), j);
  }
  dd.setColorBackground(color(60));
  dd.setColorActive(color(255, 128));
  dd.close();
  return dd;
}

DropdownList buildAccModeDropdown() {
  DropdownList dd = cp5.addDropdownList("accMode");
  dd.setBackgroundColor(color(200));
  dd.setItemHeight(20);
  dd.setBarHeight(15);
  for (int j = 0; j < 5; j++) {
    dd.addItem(getAccModeName(j), j);
  }
  dd.setColorBackground(color(60));
  dd.setColorActive(color(255, 128));
  dd.close();
  return dd;
}

DropdownList buildPatternDropdown(int var) {
  DropdownList dd = cp5.addDropdownList("pattern" + var);
  dd.setBackgroundColor(color(200));
  dd.setItemHeight(20);
  dd.setBarHeight(15);
  for (int j = 0; j < 48; j++) {
    dd.addItem(getPatternName(var, j), j);
  }
  dd.setColorBackground(color(60));
  dd.setColorActive(color(255, 128));
  dd.close();
  return dd;
}

String getPatternName(int var, int val) {
  if (val == 0) {
    return "PATTERN " + (var + 1) + ": STROBE FAST";
  } else if (val == 1) {
    return "PATTERN " + (var + 1) + ": STROBE";
  } else if (val == 2) {
    return "PATTERN " + (var + 1) + ": STROBE SLOW";
  } else if (val == 3) {
    return "PATTERN " + (var + 1) + ": NANODOPS";
  } else if (val == 4) {
    return "PATTERN " + (var + 1) + ": DOPS";
  } else if (val == 5) {
    return "PATTERN " + (var + 1) + ": STROBIE";
  } else if (val == 6) {
    return "PATTERN " + (var + 1) + ": SEIZURE";
  } else if (val == 7) {
    return "PATTERN " + (var + 1) + ": ULTRA";
  } else if (val == 8) {
    return "PATTERN " + (var + 1) + ": HYPER";
  } else if (val == 9) {
    return "PATTERN " + (var + 1) + ": MEGA";
  } else if (val == 10) {
    return "PATTERN " + (var + 1) + ": PULSE STROBE";
  } else if (val == 11) {
    return "PATTERN " + (var + 1) + ": PULSE FAST";
  } else if (val ==12) { 
    return "PATTERN " + (var + 1) + ": PULSE";
  } else if (val == 13) {
    return "PATTERN " + (var + 1) + ": PULSE SLOW";
  } else if (val == 14) {
    return "PATTERN " + (var + 1) + ": LAZER";
  } else if (val == 15) {
    return "PATTERN " + (var + 1) + ": TRACER";
  } else if (val == 16) {
    return "PATTERN " + (var + 1) + ": TAZER";
  } else if (val == 17) {
    return "PATTERN " + (var + 1) + ": DASHDOPS2";
  } else if (val == 18) {
    return "PATTERN " + (var + 1) + ": DASHDOPS7";
  } else if (val == 19) {
    return "PATTERN " + (var + 1) + ": DASHSTROBE";
  } else if (val == 20) {
    return "PATTERN " + (var + 1) + ": DASHDASH";
  } else if (val == 21) {
    return "PATTERN " + (var + 1) + ": QUICKE";
  } else if (val == 22) {
    return "PATTERN " + (var + 1) + ": BLINKE";
  } else if (val == 23) {
    return "PATTERN " + (var + 1) + ": STRIBBON";
  } else if (val == 24) {
    return "PATTERN " + (var + 1) + ": RAZOR";
  } else if (val == 25) { 
    return "PATTERN " + (var + 1) + ": EDGE";
  } else if (val == 26) {
    return "PATTERN " + (var + 1) + ": SWORD";
  } else if (val == 27) {
    return "PATTERN " + (var + 1) + ": BARBWIRE";
  } else if (val == 28) {
    return "PATTERN " + (var + 1) + ": LEGO MINI";
  } else if (val == 29) {
    return "PATTERN " + (var + 1) + ": LEGO";
  } else if (val == 30) {
    return "PATTERN " + (var + 1) + ": LEGO HUGE";
  } else if (val == 31) {
    return "PATTERN " + (var + 1) + ": CHASE SHORT";
  } else if (val == 32) {
    return "PATTERN " + (var + 1) + ": CHASE";
  } else if (val == 33) {
    return "PATTERN " + (var + 1) + ": CHASE LONG";
  } else if (val == 34) {
    return "PATTERN " + (var + 1) + ": MORPH";
  } else if (val == 35) {
    return "PATTERN " + (var + 1) + ": MORPH SLOW";
  } else if (val == 36) {
    return "PATTERN " + (var + 1) + ": MORPH STROBE";
  } else if (val == 37) {
    return "PATTERN " + (var + 1) + ": MORPH HYPER";
  } else if (val == 38) {
    return "PATTERN " + (var + 1) + ": RIBBON5";
  } else if (val == 39) {
    return "PATTERN " + (var + 1) + ": RIBBON10";
  } else if (val == 40) {
    return "PATTERN " + (var + 1) + ": RIBBON20";
  } else if (val == 41) {
    return "PATTERN " + (var + 1) + ": COMET SHORT";
  } else if (val == 42) {
    return "PATTERN " + (var + 1) + ": COMET";
  } else if (val == 43) {
    return "PATTERN " + (var + 1) + ": COMET LONG";
  } else if (val == 44) {
    return "PATTERN " + (var + 1) + ": CANDY2";
  } else if (val == 45) {
    return "PATTERN " + (var + 1) + ": CANDY3";
  } else if (val == 46) {
    return "PATTERN " + (var + 1) + ": CANDOPS";
  } else if (val == 47) {
    return "PATTERN " + (var + 1) + ": CANDYCRUSH";
  }
  return "";
}

String getAccSensName(int val) {
  if (val == 0) {
    return "ACCEL SENSITIVITY: LOW";
  } else if (val == 1) {
    return "ACCEL SENSITIVITY: MEDIUM";
  } else if (val == 2) {
    return "ACCEL SENSITIVITY: HIGH";
  }
  return "";
}

String getAccModeName(int val) {
  if (val == 0) {
    return "ACCEL MODE: OFF";
  } else if (val == 1) {
    return "ACCEL MODE: SPEED";
  } else if (val == 2) {
    return "ACCEL MODE: TILT X";
  } else if (val == 3) {
    return "ACCEL MODE: TILT Y";
  } else if (val == 4) {
    return "ACCEL MODE: FLIP Z";
  }
  return "";
}
