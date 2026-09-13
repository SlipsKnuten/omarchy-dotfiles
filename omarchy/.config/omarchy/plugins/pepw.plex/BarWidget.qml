import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

BarWidget {
  id: root
  moduleName: "pepw.plex"

  readonly property string serviceName: "plexmediaserver.service"
  readonly property string helperPath: "/usr/local/bin/plex-service-toggle"

  property string activeState: "unknown"
  property string unitFileState: "unknown"
  property bool busy: false
  property bool turningOn: false
  property string statusOutput: ""
  property string actionError: ""

  readonly property bool running: activeState === "active"
  readonly property bool enabledAtBoot: unitFileState === "enabled"
  readonly property bool available: activeState !== "not-found"

  readonly property string tooltip: {
    if (busy) return turningOn ? "Plex: Turning on…" : "Plex: Turning off…"
    if (!available) return "Plex Media Server is not installed"
    if (actionError !== "") return "Plex: " + actionError + " — click to retry"
    if (activeState === "unknown") return "Plex: Checking…"
    if (running && enabledAtBoot) return "Plex: Running · starts at boot — click to turn off"
    if (running) return "Plex: Running · not enabled at boot — click to turn off"
    if (enabledAtBoot) return "Plex: Off · starts at boot — click to turn on"
    return "Plex: Off · stays off after reboot — click to turn on"
  }

  implicitWidth: button.implicitWidth
  implicitHeight: button.implicitHeight

  function refresh() {
    if (!statusProcess.running) {
      statusOutput = ""
      statusProcess.running = true
    }
  }

  function applyStatus(output, exitCode) {
    var nextActive = "unknown"
    var nextUnitFile = "unknown"
    var lines = String(output || "").split("\n")

    for (var i = 0; i < lines.length; i++) {
      var separator = lines[i].indexOf("=")
      if (separator < 0) continue
      var key = lines[i].slice(0, separator)
      var value = lines[i].slice(separator + 1)
      if (key === "ActiveState") nextActive = value
      else if (key === "UnitFileState") nextUnitFile = value
    }

    if (exitCode !== 0 && nextActive === "unknown") nextActive = "not-found"
    activeState = nextActive
    unitFileState = nextUnitFile
  }

  function setPlex(on) {
    if (busy || !available) return
    actionError = ""
    turningOn = on
    busy = true
    actionProcess.command = ["pkexec", helperPath, on ? "on" : "off"]
    actionProcess.running = true
  }

  function turnOn() { setPlex(true) }
  function turnOff() { setPlex(false) }

  function togglePlex() {
    if (activeState === "unknown") {
      refresh()
      return
    }
    setPlex(!running)
  }

  Process {
    id: statusProcess
    command: ["systemctl", "show", root.serviceName,
      "--property=ActiveState", "--property=UnitFileState", "--no-pager"]

    stdout: StdioCollector {
      waitForEnd: true
      onStreamFinished: root.statusOutput = text
    }

    onExited: function(exitCode) {
      root.applyStatus(root.statusOutput, exitCode)
    }
  }

  Process {
    id: actionProcess

    stderr: StdioCollector {
      id: actionStderr
      waitForEnd: true
    }

    onExited: function(exitCode) {
      root.busy = false
      if (exitCode !== 0) {
        var detail = String(actionStderr.text || "").trim()
        root.actionError = detail !== "" ? detail : "Could not change the service state"
        Quickshell.execDetached(["notify-send", "--urgency=critical", "Plex", root.actionError])
      }
      root.refresh()
    }
  }

  Timer {
    interval: 5000
    running: true
    repeat: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }

  IpcHandler {
    target: "pepw.plex"

    function status(): string {
      return JSON.stringify({
        activeState: root.activeState,
        unitFileState: root.unitFileState,
        busy: root.busy,
        error: root.actionError
      })
    }

    function refresh(): string { root.refresh(); return "ok" }
    function turnOn(): string { root.turnOn(); return "ok" }
    function turnOff(): string { root.turnOff(); return "ok" }
    function togglePlex(): string { root.togglePlex(); return "ok" }
  }

  BarIconButton {
    id: button
    anchors.fill: parent
    bar: root.bar
    text: "❯"
    fontSize: Style.font.iconLarge
    foreground: root.running ? "#e5a00d" : (root.bar ? Qt.darker(root.bar.barForeground, 1.55) : "#777777")
    active: root.actionError !== ""
    activeColor: root.bar ? root.bar.urgent : Color.urgent
    dimmed: root.busy
    interactive: root.available && !root.busy
    tooltipText: root.tooltip
    onPressed: root.togglePlex()
  }
}
