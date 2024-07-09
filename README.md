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
  @Logger("subsystem", "category", .ignoreFile) private var logger
  var body: some View {
    EmptyView()
      .onAppear { logger.info("on appear") } 
  }
}
```

## Features

### Changing the Log File name
```swift
struct ContentView: View {
    @Logger("View", "ContentView") private var logger

    var body: some View {
        Button("click") {
            // action
        }
        .onAppear {
            switch logger.changeTextFileName(to: "newName") {
            case .success: break
            case .failure:
                // handle Errors
                break
            }
        }
    }
}
```

Changing the file name is persistent within the app launches. However, if the user removes the app, the desired name needs to be added again otherwise "Logs.txt" will be the default file

### Enable/Disable Loggers
If you wish to enable or disable certain loggers you can do either individually or using the provided API to make handle in batch.

```swift
struct SomeView: View {
    @Logger("one", "two") private var logger
    var body: some View {
        EmptyView()
            .onAppear {
                logger.disable()
                logger.enable()
                // logger.isDisabled -> Check if the current logger is disabled
            }
    }
}
```

you can also make a batch request using a configuration 

```swift
struct SomeView: View {
    private let configurator = LoggerConfigurator()
    var body: some View {
        EmptyView()
            .onAppear {
                configurator.disableLoggers( /* array of identifiers for the logger */ )
            }
    }
}
```

if you wish to enable the disabled loggers

```swift
public func enableDisabledLoggers()
```

### Reusability
If you provide the same subsystem and category to the logger, the existing logger will be returned.

### Weakly held.
The loggers are weakly held using `NSMapTable` once the objects or values holding onto the logger released from the memory, they are automatically removed.

### Write at a file.
The main objective of this library is to provide support for writing the logs to a file. There isn't an official support from Apple for this.
The logs are automatically written to a file in the document directory of the phone into a file named Logs.txt

## Installation
Use https://github.com/JohnDemirci/JDLogger.git to add to your project by clicking `Add Package Dependencies` on XCode

## Future work
- Make the file reading more performant
- Add flexibility for the users to name the log file instead of coming up with a pre-defined name.
