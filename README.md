# JDLogger
A logger for both Console and File.


## Usage
simply use the provided `@Logger` propertyWrapper
```swift
sturct SomeView: View {
  @Logger("subsystem", "category") private var logger
  var body: some View {
    EmptyView()
      .onAppear { logger.info("on appear") } 
  }
}
```

If you do not want to write to a file, you can opt out

```swift
sturct SomeView: View {
  @Logger("subsystem", "category", shouldLogToFile: false) private var logger
  var body: some View {
    EmptyView()
      .onAppear { logger.info("on appear") } 
  }
}
```

## Features

### Reusability
If you provide the same subsystem and category to the logger, the existing logger will be returned.

### Weakly held.
The loggers are weakly held using `NSMapTable` once the objects or values holding onto the logger released from the memory, they are automatically removed.

### Write at a file.
The main objective of this library is to provide support for writing the logs to a file. There isn't an official support from Apple for this.
The logs are automatically written to a file in the document directory of the phone into a file named Logs.txt

## Installation
Use https://github.com/JohnDemirci/JDLogger.git to add to your project by clicking `Add Package Dependencies` on XCode
