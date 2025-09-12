# M5Dial-UserDemo Copilot Instructions

## Project Overview
ESP32-S3 based hardware demo for M5Stack's dial device featuring a circular display, rotary encoder, and various sensors. Built with ESP-IDF v5.1.3 using a custom app framework called "MOONCAKE".

## Architecture Patterns

### Hardware Abstraction Layer (HAL)
- **Central HAL class**: `main/hal/hal.h` - Initialize all hardware components
- **Component structure**: Each hardware component has its own subdirectory (`buzzer/`, `display/`, `tp/`, etc.)
- **Display backend**: Uses LovyanGFX library for graphics with LGFX_StampRing for the circular display
- **Key components**: Encoder, touchpad (FT3267), RTC (PCF8563), buzzer

```cpp
// HAL usage pattern throughout codebase
HAL::HAL hal;
hal.init();  // Initialize all hardware
auto userData = (HAL::HAL*)getUserData();  // Apps access HAL via userData
```

### MOONCAKE App Framework
- **Base class**: `main/apps/app.h` defines `APP_BASE` with lifecycle methods
- **Lifecycle**: `onSetup()` → `onCreate()` → `onRunning()` loop → `onDestroy()`
- **Apps location**: Each app in `main/apps/app_*/` with pattern `app_[name].h/.cpp`
- **Launcher**: `main/apps/launcher/` manages app switching via circular menu

```cpp
// Standard app structure
class YourApp : public MOONCAKE::APP_BASE {
    void onSetup() override { setAppName("Your App"); }
    void onCreate() override { /* Init GUI */ }
    void onRunning() override { /* Main loop */ }
};
```

### GUI Architecture
- **Base GUI**: `main/apps/utilities/gui_base/gui_base.h` provides common drawing functions
- **Canvas system**: Apps receive `LGFX_Sprite* canvas` for double-buffered rendering
- **Theme support**: `setThemeColor()` for consistent app theming
- **Common elements**: `_draw_quit_button()`, `_draw_top_banner()`, `_draw_top_icon()`

## Build & Flash Workflow

### Standard ESP-IDF Commands
```bash
# Setup (one-time)
. $IDF_PATH/export.sh

# Build
idf.py build

# Flash and monitor
idf.py -p /dev/ttyACM0 flash monitor
```

### Project Scripts
- **`flash.sh`**: Automated build+flash+monitor with 1.5Mbps baud rate
- **`hotplugSetup.sh`**: USB permissions setup for development

## Configuration Patterns

### CMakeLists.txt Global Defines
- `ENABLE_FACTORY_TEST`: Enables factory test mode (hold encoder button on boot)
- Font definitions: `GUI_FONT_CN_BIG`, `GUI_FONT_CN_SMALL` for Chinese text support
- WiFi credentials for factory testing

### Component Integration
- **LovyanGFX**: Graphics library configuration in `components/lv_conf.h`
- **LVGL**: Available but disabled by default (`#define LVGL_ENABLE 0` in `hal.h`)
- **RC522**: RFID component in `components/esp-idf-rc522/`

## Development Conventions

### App Development Pattern
1. **Copy template**: Use `main/apps/app_template/` as starting point
2. **Data structure**: Define `APP_NAME::Data_t` struct for app state
3. **GUI class**: Inherit from `GUI_Base` for rendering
4. **HAL access**: Cast `getUserData()` to `HAL::HAL*` for hardware access
5. **Registration**: Add to launcher in `main/apps/launcher/launcher.h`

### File Organization
- **HAL components**: `main/hal/[component]/hal_[component].hpp`
- **Apps**: `main/apps/app_[name]/app_[name].h` + GUI in `gui/` subfolder
- **Utilities**: Shared code in `main/apps/utilities/`

### Hardware Testing
- **Factory mode**: Hold encoder button during boot for comprehensive hardware test
- **Individual tests**: Uncomment test calls in `main.cpp` for specific components
- **Debug helpers**: `HAL::encoder_test()`, `HAL::tp_test()`, `HAL::rtc_test()`

## Key Integration Points

### Encoder Handling
```cpp
// Encoder provides both rotation and button press
hal.encoder.getCount();  // Get rotation value
hal.encoder.btn.read();  // Get button state
```

### Display Rendering
```cpp
// Standard rendering pattern in apps
canvas->fillScreen(TFT_BLACK);
canvas->setTextColor(theme_color);
canvas->drawString("Text", x, y);
canvas->pushSprite(0, 0);  // Commit to display
```

### Memory Considerations
- ESP32-S3 with PSRAM - large graphics operations are feasible
- Use `LGFX_Sprite` for off-screen rendering to avoid flicker
- Components like LVGL available but disabled for memory optimization
