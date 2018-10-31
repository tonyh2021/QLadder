A Swift Extension for UIColor supporting iOS and Mac.

## Installation

> Embedded frameworks require a minimum deployment target of iOS 8. 

### CocoaPods

Add ```pod 'SwiftColor'``` to your ```Podfile```: 

```
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'
use_frameworks!

pod 'SwiftColor'
```

### Carthage

To integrate ```SwiftColor``` into your Xcode project using Carthage, specify it in your ```Cartfile```:

```
github "icodesign/SwiftColor"
```

### Manually

You can also integrate ```SwiftColor``` directly with souce code. Clone the repo and copy ```SwiftColor.swift``` to your project.

## Usage

### Color Init

> ```SwiftColor``` provides a typealias for ```UIColor```/`NSColor` as ```Color```.

#### Initialize with Hex String

```swift
Color("000")
Color("000C")
Color("0x4DA2D9")
Color(hexString: "#4DA2D9")
Color(hexString: "#4DA2D9CC")

Color(hexString: "#4DA2D9", alpha: 0.8)

"#4DA2D9CC".color
```

#### Initialize with Hex Int

```swift
Color(hexInt: 0x4DA2D9)

Color(hexInt: 0x4DA2D9, alpha: 0.8)

(0x4DA2D9).color
```

#### Initialize with RGBA

```swift
Color(byteRed: 77, green: 162, blue: 217, alpha: 0.8)
```

#### Get/Change Color Components

```swift
let color = Color(hexString: "#4DA2D9CC")

// get color components
var (r, g, b, a) = color.colorComponents()

// change color components
var red = "000".color.red(255)
var alphaColor = Color(hexInt: 0x4DA2D9).alpha(0.8)
```

#### Convert to image

```
let image = "000".color.toImage()
```
