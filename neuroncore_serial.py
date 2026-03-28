import sys, time
from collections import deque
from datetime import datetime

from PyQt5 import QtCore, QtGui, QtWidgets
from PyQt5.QtCore import Qt, pyqtSignal, QTimer

import serial
import serial.tools.list_ports

from matplotlib.backends.backend_qt5agg import FigureCanvasQTAgg as FigureCanvas
from matplotlib.figure import Figure
import numpy as np

# -------- Serial reader thread ----------
class SerialReader(QtCore.QThread):
    line_received = pyqtSignal(str)
    bytes_received = pyqtSignal(bytes)
    error = pyqtSignal(str)
    opened = pyqtSignal()

    def __init__(self, port, baud, parent=None):
        super().__init__(parent)
        self.port = port
        self.baud = baud
        self._running = False
        self._ser = None

    
    def write(self, data):
        if self._ser and self._ser.is_open:
            try:
                self._ser.write(data)
            except Exception as e:
                self.error.emit(f"Write error: {e}")

    def run(self):
        try:
            self._ser = serial.Serial(self.port, self.baud, timeout=0.1)
            self.opened.emit()
        except Exception as e:
            self.error.emit(f"Open error: {e}")
            return

        self._running = True
        buffer = b""

        while self._running:
            try:
                data = self._ser.read(1024)

                if data:

                    # send raw bytes for binary plotter
                    self.bytes_received.emit(data)

                    # also keep ASCII monitor working
                    buffer += data
                    while b"\n" in buffer or b"\r" in buffer:
                        if b"\n" in buffer:
                            idx = buffer.find(b"\n")
                            line = buffer[:idx]
                            buffer = buffer[idx+1:]
                        else:
                            idx = buffer.find(b"\r")
                            line = buffer[:idx]
                            buffer = buffer[idx+1:]

                        try:
                            text = line.decode("utf-8", errors="ignore")
                            self.line_received.emit(text)
                        except:
                            pass

                else:
                    self.msleep(2)

            except Exception as e:
                self.error.emit(f"Read error: {e}")
                break

        try:
            if self._ser and self._ser.is_open:
                self._ser.close()
        except:
            pass

    def stop(self):
        self._running = False
        self.wait(500)

# -------- Main application ----------
class SerialMonitorApp(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("NeuronCore Serial Moniter")
        self.resize(1536, 864)
        # self.setStyleSheet("QWidget { font-size: 14pt; } QTextEdit { font-size: 10pt; }")

        self._reader = None
        self._plot_buffers = None
        self._max_points = 1000
        self._packet = []
        self._view_offset = 0
        # self._last_byte_time = time.time()

        self._init_ui()
        # self._break_timeout = (1/int(self.baud_combo.currentText())) * 10   #idle break
        self._connect_signals()
        self._plot_initialized = False
        self.refresh_ports()

        # default toggles
        self.autoscroll = True
        self.show_timestamps = False

    # ---------- UI ----------
    def _init_ui(self):
        central = QtWidgets.QWidget()
        self.setCentralWidget(central)
        mainlay = QtWidgets.QVBoxLayout(central)
        mainlay.setContentsMargins(8,8,8,8)

        # top controls
        top_h = QtWidgets.QHBoxLayout()
        mainlay.addLayout(top_h)

        top_h.addWidget(QtWidgets.QLabel("Port:"))
        self.port_combo = QtWidgets.QComboBox(); self.port_combo.setMinimumWidth(360)
        top_h.addWidget(self.port_combo)
        self.refresh_btn = QtWidgets.QPushButton("Refresh")
        top_h.addWidget(self.refresh_btn)

        top_h.addSpacing(8)
        top_h.addWidget(QtWidgets.QLabel("Baud:"))
        self.baud_combo = QtWidgets.QComboBox(); self.baud_combo.setEditable(True)
        for b in ["300","1200","2400","4800","9600","14400","19200","38400","57600","115200","230400","250000","500000","1000000"]:
            self.baud_combo.addItem(b)
        self.baud_combo.setCurrentText("500000")
        self.baud_combo.setMinimumWidth(110)
        top_h.addWidget(self.baud_combo)

        top_h.addSpacing(8)
        self.connect_btn = QtWidgets.QPushButton("Connect")
        top_h.addWidget(self.connect_btn)

        top_h.addStretch()

        # toolbar buttons: autoscroll, timestamp, clear
        self.autoscroll_btn = QtWidgets.QPushButton("Autoscroll: ON")
        self.autoscroll_btn.setCheckable(True); self.autoscroll_btn.setChecked(True)
        self.timestamp_btn = QtWidgets.QPushButton("Timestamps: OFF")
        self.timestamp_btn.setCheckable(True)
        self.clear_btn = QtWidgets.QPushButton("Clear Output")
        for w in (self.autoscroll_btn, self.timestamp_btn, self.clear_btn):
            w.setMinimumWidth(110)
            top_h.addWidget(w)

        # mode toggle (Monitor / Plotter)
        self.mode_toggle = QtWidgets.QPushButton("Switch to Plotter")
        self.mode_toggle.setCheckable(True)
        top_h.addWidget(self.mode_toggle)

        # stacked area: monitor / plotter
        self.stack = QtWidgets.QStackedWidget()
        mainlay.addWidget(self.stack, 1)

        # --- Monitor page
        monw = QtWidgets.QWidget(); monlay = QtWidgets.QVBoxLayout(monw)
        self.text_area = QtWidgets.QPlainTextEdit(); self.text_area.setReadOnly(True)
        # nicer font
        font = QtGui.QFont("Consolas" if sys.platform.startswith("win") else "Monospace", 11)
        font.setStyleHint(QtGui.QFont.Monospace)
        self.text_area.setFont(font)
        monlay.addWidget(self.text_area, 1)

        send_h = QtWidgets.QHBoxLayout()
        self.send_edit = QtWidgets.QLineEdit()
        self.send_btn = QtWidgets.QPushButton("Send")

        # 🔥 Move dropdown here
        self.le_combo = QtWidgets.QComboBox()
        self.le_combo.addItems(["No line ending","\\n (LF)","\\r (CR)","\\r\\n (CRLF)"])
        self.le_combo.setMinimumWidth(120)

        send_h.addWidget(self.send_edit, 1)
        send_h.addWidget(self.send_btn)
        send_h.addWidget(self.le_combo)
        monlay.addLayout(send_h)
        self.stack.addWidget(monw)

        # --- Plotter page
        plotw = QtWidgets.QWidget(); plotlay = QtWidgets.QVBoxLayout(plotw)
        ctrl_h = QtWidgets.QHBoxLayout()
        ctrl_h.addWidget(QtWidgets.QLabel("Traces:"))
        self.traces_spin = QtWidgets.QSpinBox(); self.traces_spin.setRange(1,8); self.traces_spin.setValue(4)
        ctrl_h.addWidget(self.traces_spin)
        self.clear_plot = QtWidgets.QPushButton("Clear Plot")
        ctrl_h.addWidget(self.clear_plot)
        self.autoscale_cb = QtWidgets.QCheckBox("Autoscale"); self.autoscale_cb.setChecked(True)
        ctrl_h.addWidget(self.autoscale_cb)
        ctrl_h.addStretch()
        plotlay.addLayout(ctrl_h)

        self.scrollbar = QtWidgets.QScrollBar(Qt.Horizontal)
        self.scrollbar.setMinimum(0)
        self.scrollbar.setMaximum(0)
        self.scrollbar.setPageStep(self._max_points)
        self.scrollbar.setSingleStep(10)
        self.scrollbar.update()
        plotlay.addWidget(self.scrollbar)

        self.fig = Figure(figsize=(6,4), dpi=100); self.canvas = FigureCanvas(self.fig); self.ax = self.fig.add_subplot(111)
        self.ax.set_xlabel("Samples"); self.ax.set_ylabel("Value"); self.fig.tight_layout()
        plotlay.addWidget(self.canvas, 1)
        self.stack.addWidget(plotw)

        # status bar at bottom
        status_h = QtWidgets.QHBoxLayout()
        self.status_label = QtWidgets.QLabel("Disconnected")
        status_h.addWidget(self.status_label)
        status_h.addStretch()
        mainlay.addLayout(status_h)

        # apply dark theme (Arduino-ish)
        self._apply_dark_theme()

    def _apply_dark_theme(self):
        # Arduino-like dark theme (rounded edges, subtle gradients)
        style = """
        QWidget { background: #636363; color: #E6E6E6; }
        QPlainTextEdit, QTextEdit { background: #1E2124; color: #E6E6E6; border: 1px solid #323539; border-radius:6px; padding:6px; }
        QComboBox, QLineEdit, QSpinBox { background: #2A2D31; color: #E6E6E6; border: 1px solid #3A3D41; border-radius:6px; padding:4px; }
        QPushButton { background: qlineargradient(x1:0, y1:0, x2:0, y2:1, stop:0 #3a3f44, stop:1 #2b2f33); border:1px solid #151618; color:#f0f0f0; padding:6px; border-radius:6px; }
        QPushButton:checked { background: qlineargradient(x1:0,y1:0,x2:0,y2:1, stop:0 #5a6b5a, stop:1 #3d4b3d); }
        QLabel { color: #cfcfcf; }
        QToolTip { background: #2b2b2b; color: #eaeaea; border: 1px solid #555; }
        """
        self.setStyleSheet(style)
    
    def _on_scroll(self, value):
        self._view_offset = value
        self._auto_follow = (value == self.scrollbar.maximum())

    # ---------- Signals ----------
    def _connect_signals(self):
        self.refresh_btn.clicked.connect(self.refresh_ports)
        self.connect_btn.clicked.connect(self.on_connect_clicked)
        self.send_btn.clicked.connect(self.send_text)
        self.mode_toggle.clicked.connect(self.on_mode_toggle)
        self.traces_spin.valueChanged.connect(self._on_traces_changed)
        self.scrollbar.valueChanged.connect(self._on_scroll)
        self.clear_plot.clicked.connect(self._clear_plot)
        self.autoscroll_btn.clicked.connect(self._toggle_autoscroll)
        self.timestamp_btn.clicked.connect(self._toggle_timestamps)
        self.clear_btn.clicked.connect(self._clear_output)

    # ---------- Ports ----------
    def refresh_ports(self):
        """Updated: show chip/manufacturer-friendly names like 'CH340', 'FT232', 'CP2102', 'Arduino'."""
        self.port_combo.clear()
        ports = serial.tools.list_ports.comports()
        if not ports:
            self.port_combo.addItem("(no serial ports)", "")
            return

        for p in ports:
            # clean inputs
            desc = (p.description or "").strip()
            manuf = (p.manufacturer or "").strip()
            prod = (p.product or "").strip()
            hwid = (p.hwid or "").strip().lower()

            # Heuristics to find a short chip/board name
            chip = ""
            # check description/product strings first
            d = desc.upper()
            pr = prod.upper()
            mf = manuf.upper()

            if "CH340" in d or "CH341" in d or "CH340" in pr or "CH341" in pr or "wch" in hwid:
                chip = "CH340"
            elif "CP210" in d or "CP210" in pr or "SILICON" in mf or "CP210" in mf:
                chip = "CP2102"
            elif "FTDI" in mf or "FT232" in d or "FT232" in pr or "FTDI" in d:
                chip = "FT232"
            elif "ARDUINO" in d or "ARDUINO" in pr or "UNO" in d or "MEGA" in d:
                # prefer board name if present
                chip = desc if desc else "Arduino"
            elif "STM" in d or "STM" in pr or "STMICRO" in mf:
                chip = "STM32"
            else:
                # fallback to manufacturer/product/description
                if manuf:
                    chip = manuf
                elif prod:
                    chip = prod
                elif desc:
                    chip = desc
                else:
                    chip = p.device

            display = f"{p.device} — {chip}"
            self.port_combo.addItem(display, p.device)

        self.port_combo.setCurrentIndex(0)
    
    def _process_packet(self, packet):

        traces = self.traces_spin.value()

        for i in range(min(8, traces)):
            self._plot_buffers[i].append(packet[i])
    
    def _on_bytes(self, data):

        if not self.mode_toggle.isChecked():
            return

        for b in data:

            # Wait for header (255)
            if not hasattr(self, "_sync"):
                self._sync = False

            if not self._sync:
                if b == 255:
                    self._sync = True
                    self._packet = []
                continue

            # Collect 8 bytes after header
            self._packet.append(b)

            if len(self._packet) == 8:
                self._process_packet(self._packet)
                self._packet = []
                self._sync = False

    # def _flush_packet(self):

    #     if not self._packet:
    #         return

    #     traces = self.traces_spin.value()

    #     for i in range(min(len(self._packet), traces)):
    #         self._plot_buffers[i].append(self._packet[i])

    #     self._packet.clear()

    # ---------- Connect / Disconnect ----------
    def on_connect_clicked(self):
        if self._reader and self._reader.isRunning():
            self._disconnect()
        else:
            self._connect()

    def _connect(self):
        port = self.port_combo.currentData()
        if not port:
            self._set_status("No port selected", error=True); return
        try:
            baud = int(self.baud_combo.currentText())
        except Exception:
            self._set_status("Invalid baud", error=True); return

        self._reader = SerialReader(port, baud)
        self._reader.line_received.connect(self._on_line)
        self._reader.bytes_received.connect(self._on_bytes)
        self._reader.error.connect(lambda e: self._set_status(e, error=True))
        self._reader.opened.connect(lambda: self._set_status(f"Connected {port} @ {baud}"))
        self._reader.start()
        self.connect_btn.setText("Disconnect")

    def _disconnect(self):
        if self._reader:
            self._reader.stop()
            self._reader = None
        self.connect_btn.setText("Connect")
        self._set_status("Disconnected")

    def _set_status(self, txt, error=False):
        self.status_label.setText(txt)
        if error:
            self.status_label.setStyleSheet("color: #ff8080;")
        else:
            self.status_label.setStyleSheet("")

    # ---------- Incoming lines ----------
    def _on_line(self, line):
        if self.mode_toggle.isChecked():
            # plotter mode
            self._process_plot_line(line)
        else:
            # monitor mode
            out = line.strip()
            if self.show_timestamps:
                out = f"[{datetime.now().strftime('%H:%M:%S')}] --> {out}"
                self._append_text(out + "\n")
            else:
                self._append_text(out + "\n")


    def _append_text(self, text):
        scrollbar = self.text_area.verticalScrollBar()
        at_bottom = scrollbar.value() == scrollbar.maximum()

        cursor = self.text_area.textCursor()
        cursor.movePosition(QtGui.QTextCursor.End)
        cursor.insertText(text)

        # Only autoscroll if enabled and user was already at bottom
        if self.autoscroll and at_bottom:
            scrollbar.setValue(scrollbar.maximum())




    def _clear_output(self):
        self.text_area.clear()

    def _toggle_autoscroll(self):
        self.autoscroll = self.autoscroll_btn.isChecked()
        self.autoscroll_btn.setText("Autoscroll: ON" if self.autoscroll else "Autoscroll: OFF")

    # When turning autoscroll back ON, immediately jump to bottom
        if self.autoscroll:
            scrollbar = self.text_area.verticalScrollBar()
            scrollbar.setValue(scrollbar.maximum())


    def _toggle_timestamps(self):
        self.show_timestamps = self.timestamp_btn.isChecked()
        self.timestamp_btn.setText("Timestamps: ON" if self.show_timestamps else "Timestamps: OFF")

    # ---------- Send ----------
    def send_text(self):
        port = self.port_combo.currentData()
        if not port or not self._reader:
            self._set_status("Not connected", error=True)
            return

        text = self.send_edit.text()
        if text is None:
            return

        ending = ""
        le_idx = self.le_combo.currentIndex()

        if le_idx == 1:
            ending = "\n"
        elif le_idx == 2:
            ending = "\r"
        elif le_idx == 3:
            ending = "\r\n"

        try:
            self._reader.write((text + ending).encode())

            self._set_status(f"Sent: {text!r}")

        except Exception as e:
            self._set_status(f"Send error: {e}", error=True)

    # ---------- Plot handling ----------
    def _init_plot_state(self):
        self.traces = self.traces_spin.value()
        self._setup_plot_lines()
        self._plot_buffers = [deque(maxlen=5000) for _ in range(8)]
        self.plot_timer = QTimer(); self.plot_timer.setInterval(120); self.plot_timer.timeout.connect(self._update_plot); self.plot_timer.start()

    def _on_traces_changed(self, v):
        self._setup_plot_lines()
        self._plot_buffers = [deque(maxlen=5000) for _ in range(8)]
        self._view_offset = 0
        self.scrollbar.setValue(0)
        self._auto_follow = True

    def _setup_plot_lines(self):
        self.fig.clear()

        traces = self.traces_spin.value()

        self.axes = self.fig.subplots(traces, 1, sharex=True)

        if traces == 1:
            self.axes = [self.axes]

        self.lines = []
        colors = ['C0','C1','C2','C3','C4','C5','C6','C7']

        for i in range(traces):
            ax = self.axes[i]
            ax.set_ylabel(f"ch{i}")
            ax.grid(True, linestyle="--", alpha=0.4)

            line, = ax.plot([], [], color=colors[i])
            self.lines.append(line)

            ax.set_ylim(-300, 300)

        self.axes[-1].set_xlabel("Samples")

        # 🔥 KEY FIXES
        self.fig.subplots_adjust(hspace=0.35)
        self.fig.tight_layout()

        self.canvas.draw()
    
    def showEvent(self, event):
        super().showEvent(event)

        if not self._plot_initialized:
            self._plot_initialized = True
            QtCore.QTimer.singleShot(100, self._delayed_plot_init)

    def _delayed_plot_init(self):
        self._init_plot_state()
        self._setup_plot_lines()
        self.canvas.draw_idle()

    def _fix_initial_layout(self):
        self._setup_plot_lines()
        self.canvas.draw_idle()

    def resizeEvent(self, event):
        super().resizeEvent(event)

        # Re-adjust layout when window size changes
        QtCore.QTimer.singleShot(50, self._on_resize_fix)

    def _on_resize_fix(self):
        self.fig.tight_layout()
        self.canvas.draw_idle()


    def _clear_plot(self):
        for buf in self._plot_buffers:
            buf.clear()
        self._setup_plot_lines()

    def _process_plot_line(self, line):
        tokens = [t for t in line.replace(',', ' ').split() if t!='']
        values = []
        for t in tokens:
            try:
                values.append(float(t))
            except Exception:
                pass
            if len(values) >= 8:
                break
        traces = self.traces_spin.value()
        for i in range(traces):
            if i < len(values):
                self._plot_buffers[i].append(values[i])
            else:
                self._plot_buffers[i].append(self._plot_buffers[i][-1] if len(self._plot_buffers[i])>0 else 0.0)

    def _update_plot(self):
        traces = self.traces_spin.value()

        max_len = max(len(b) for b in self._plot_buffers[:traces])

        scroll_max = max(0, max_len - self._max_points)

        self.scrollbar.blockSignals(True)
        self.scrollbar.setMaximum(scroll_max)
        self.scrollbar.setPageStep(self._max_points)
        self.scrollbar.blockSignals(False)

        if not any(len(b) > 0 for b in self._plot_buffers[:traces]):
            return

        if not hasattr(self, "_auto_follow"):
            self._auto_follow = True

        if self._auto_follow:
            self._view_offset = self.scrollbar.maximum()
            self.scrollbar.setValue(self._view_offset)

        for i, line in enumerate(self.lines):
            y = np.array(self._plot_buffers[i])
            x = np.arange(len(y))
            line.set_data(x, y)

            # Always keep X range dynamic
            window = self._max_points

            start = self._view_offset
            end = start + window

            if len(y) < window:
                start = 0
                end = window

            self.axes[i].set_xlim(start, end)

            if self.autoscale_cb.isChecked():
                self.axes[i].relim()
                self.axes[i].autoscale_view()
                self.axes[i].set_autoscaley_on(True)
            else:
                # Strictly fix Y limits to -300..300 for every subplot
                self.axes[i].set_autoscaley_on(False)
                self.axes[i].set_ylim(-300, 300)
                # Also freeze the margin behavior
                self.axes[i].margins(y=0)

        # Prevent layout from shifting plots vertically
        self.fig.subplots_adjust(hspace=0.35)
        self.canvas.draw_idle()

    def on_mode_toggle(self, checked):
        if checked:
            self.stack.setCurrentIndex(1)
            self.mode_toggle.setText("Switch to Monitor")

            # 🔥 FORCE FULL REBUILD when entering plotter
            QtCore.QTimer.singleShot(50, self._force_plot_refresh)

        else:
            self.stack.setCurrentIndex(0)
            self.mode_toggle.setText("Switch to Plotter")

    def _force_plot_refresh(self):
        self.fig.clear()

        self._setup_plot_lines()

        # 🔥 VERY IMPORTANT: force canvas + layout refresh
        self.canvas.resize(self.canvas.size())
        self.canvas.draw()
        self.canvas.flush_events()

    def closeEvent(self, event):
        try:
            if self._reader:
                self._reader.stop()
        except Exception:
            pass
        event.accept()

# ---------- main ----------
def main():
    app = QtWidgets.QApplication(sys.argv)
    w = SerialMonitorApp()
    w.show()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
