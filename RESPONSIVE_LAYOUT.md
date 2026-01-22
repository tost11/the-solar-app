# Responsive Layout Documentation

The Solar App adapts its layout based on screen size to provide optimal user experience across mobile, tablet, and desktop devices.

## Breakpoints

- **Mobile**: < 600px width
- **Tablet**: 600px - 840px width
- **Desktop**: ≥ 840px width

---

## Device List Screen

### Mobile (< 600px)
```
┌──────────────────────┐
│  The Solar App   ☰  │
├──────────────────────┤
│                      │
│  ┌────────────────┐  │
│  │ Device 1       │  │
│  │ [Info]         │  │
│  └────────────────┘  │
│                      │
│  ┌────────────────┐  │
│  │ Device 2       │  │
│  │ [Info]         │  │
│  └────────────────┘  │
│                      │
│  ┌────────────────┐  │
│  │ Device 3       │  │
│  │ [Info]         │  │
│  └────────────────┘  │
│                      │
└──────────────────────┘
```

### Tablet/Desktop (≥ 600px)
```
┌─────────────────────────────────────────────────────────┐
│  The Solar App                                      ☰  │
├─────────────────────────────────────────────────────────┤
│                                                         │
│  ┌───────────────┐  ┌───────────────┐  ┌────────────┐ │
│  │ Device 1      │  │ Device 2      │  │ Device 3   │ │
│  │ [Info]        │  │ [Info]        │  │ [Info]     │ │
│  └───────────────┘  └───────────────┘  └────────────┘ │
│                                                         │
│  ┌───────────────┐  ┌───────────────┐  ┌────────────┐ │
│  │ Device 4      │  │ Device 5      │  │ Device 6   │ │
│  │ [Info]        │  │ [Info]        │  │ [Info]     │ │
│  └───────────────┘  └───────────────┘  └────────────┘ │
│                                                         │
└─────────────────────────────────────────────────────────┘
```
**Layout**: Responsive grid (2-4 columns based on width)

---

## Device Detail Screen

### Mobile (< 600px)
```
┌──────────────────────┐
│  Device Name     ←  │
├──────────────────────┤
│ Device Info Cards    │
│ ┌──────────────────┐ │
│ │ Model: HMS-800   │ │
│ │ Status: Online   │ │
│ └──────────────────┘ │
│                      │
│ [Connect] [Menu ⋮]   │
│                      │
│ ── Live Data ──      │
│ ┌────────┐           │
│ │ Power  │           │
│ │ 450W   │           │
│ └────────┘           │
│ ┌────────┐           │
│ │ Voltage│           │
│ │ 230V   │           │
│ └────────┘           │
│                      │
│ ── Graph ──          │
│ ┌──────────────────┐ │
│ │    /\  /\        │ │
│ │   /  \/  \       │ │
│ └──────────────────┘ │
└──────────────────────┘
```
**Layout**: Single column, vertical stack

### Tablet (600px - 840px)
```
┌────────────────────────────────────────────┐
│  Device Name                           ←  │
├────────────────────────────────────────────┤
│ ┌────────────┐  ┌────────────┐            │
│ │ Model      │  │ Status     │            │
│ │ HMS-800    │  │ Online     │            │
│ └────────────┘  └────────────┘            │
│                                            │
│ [Connect]              [Menu ⋮]           │
│                                            │
│ ──────────── Live Data ─────────────      │
│ ┌──────┐ ┌──────┐ ┌──────┐                │
│ │Power │ │Volt  │ │Freq  │                │
│ │450W  │ │230V  │ │50Hz  │                │
│ └──────┘ └──────┘ └──────┘                │
│ ┌──────┐ ┌──────┐ ┌──────┐                │
│ │Daily │ │Total │ │Temp  │                │
│ │5.2kWh│ │890kWh│ │45°C  │                │
│ └──────┘ └──────┘ └──────┘                │
│                                            │
│ ───────────── Graph ──────────────        │
│ ┌────────────────────────────────────┐    │
│ │         /\      /\                 │    │
│ │        /  \    /  \                │    │
│ │       /    \  /    \               │    │
│ └────────────────────────────────────┘    │
└────────────────────────────────────────────┘
```
**Layout**: 3-column data grid, full-width graph

### Desktop (≥ 840px)
```
┌─────────────────────────────────────────────────────────────────┐
│  Device Name                                                ←  │
├─────────────────────────────────────────────────────────────────┤
│ ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────┐          │
│ │ Model    │ │ Status   │ │ Firmware │ │ Uptime   │          │
│ │ HMS-800  │ │ Online   │ │ v1.2.3   │ │ 5d 3h    │          │
│ └──────────┘ └──────────┘ └──────────┘ └──────────┘          │
│                                                                 │
│ [Connect]                                       [Menu ⋮]       │
│                                                                 │
│ ┌─ Live Data ────────────┐ ┌─ Graph ───────────────────────┐  │
│ │ ┌────┐ ┌────┐ ┌────┐  │ │           /\      /\          │  │
│ │ │Pwr │ │Volt│ │Freq│  │ │          /  \    /  \         │  │
│ │ │450W│ │230V│ │50Hz│  │ │         /    \  /    \        │  │
│ │ └────┘ └────┘ └────┘  │ │        /      \/      \       │  │
│ │ ┌────┐ ┌────┐ ┌────┐  │ │                                │  │
│ │ │Day │ │Tot │ │Temp│  │ └────────────────────────────────┘  │
│ │ │5.2 │ │890 │ │45°C│  │                                     │
│ │ └────┘ └────┘ └────┘  │                                     │
│ └────────────────────────┘                                     │
└─────────────────────────────────────────────────────────────────┘
```
**Layout**: 4-column data grid, side-by-side with graph

---

## Configuration Screens

### Mobile (< 600px)
```
┌──────────────────────┐
│  WiFi Setup      ←  │
├──────────────────────┤
│                      │
│ SSID:                │
│ ┌──────────────────┐ │
│ │ MyNetwork        │ │
│ └──────────────────┘ │
│                      │
│ Password:            │
│ ┌──────────────────┐ │
│ │ ••••••••         │ │
│ └──────────────────┘ │
│                      │
│                      │
│ [Save] [Cancel]      │
│                      │
└──────────────────────┘
```
**Layout**: Full width, standard navigation

### Tablet/Desktop (≥ 600px)
```
┌───────────────┬───────────────────────┬─────────────────┐
│               │  WiFi Setup       ×   │                 │
│               ├───────────────────────┤                 │
│  Blurred      │                       │   Blurred       │
│  Previous     │ SSID:                 │   Previous      │
│  Screen       │ ┌───────────────────┐ │   Screen        │
│  (Device      │ │ MyNetwork         │ │   (Device       │
│  Detail)      │ └───────────────────┘ │   Detail)       │
│               │                       │                 │
│  [≡] Device   │ Password:             │   450W          │
│  ┌──────┐     │ ┌───────────────────┐ │   ┌─────┐      │
│  │Power │     │ │ ••••••••          │ │   │  /\ │      │
│  │450W  │     │ └───────────────────┘ │   │ /  \│      │
│  └──────┘     │                       │   └─────┘      │
│               │                       │                 │
│               │ [Save]   [Cancel]     │                 │
│               │                       │                 │
│               │     (600px max)       │                 │
└───────────────┴───────────────────────┴─────────────────┘
```
**Features**:
- 600px max width, centered
- Blurred background (previous screen visible)
- 30% black overlay + blur (sigma: 5)
- Material elevation with rounded corners
- Slide-in transition animation

---

## Key Features

### Responsive Grid Behavior
- **Mobile**: 2 columns (data fields), 1 column (devices)
- **Tablet**: 3 columns (data fields), 2-3 columns (devices)
- **Desktop**: 4 columns (data fields), 3-4 columns (devices)

### Data Field Cards
- **Min width**: 130px
- **Max width**: 180px
- **Auto-wrap**: Based on available space

### Navigation Pattern
- **Mobile**: Full-screen push navigation
- **Tablet/Desktop (config)**: Modal overlay with blur
- **Tablet/Desktop (detail)**: Full-screen navigation

### Graph Display
- **Mobile**: Full width below data fields (vertical stack)
- **Tablet**: Full width below data fields
- **Desktop**: Side-by-side with data fields

---

## Implementation

**Breakpoint Detection**: `lib/utils/responsive_breakpoints.dart`
```dart
ResponsiveBreakpoints.isMobile(context)    // < 600px
ResponsiveBreakpoints.isTablet(context)    // 600-840px
ResponsiveBreakpoints.isDesktop(context)   // ≥ 840px
```

**Navigation Helper**: `lib/utils/navigation_utils.dart`
```dart
// Configuration screens (with blur on tablet/desktop)
NavigationUtils.pushConfigurationScreen(context, screen);

// Standard screens (full screen)
NavigationUtils.push(context, screen);
```

**Custom Route**: `lib/utils/constrained_modal_route.dart`
- Extends `PageRouteBuilder`
- Non-opaque for blur effect
- Responsive width constraints
- Slide transition animation
