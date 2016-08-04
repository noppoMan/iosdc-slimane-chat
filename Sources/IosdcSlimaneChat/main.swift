#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif

import Slimane

let logger = Logger(name: "Slimane", appender: SlimaneStdoutAppender(), levels: .info)

var pm = PM()

do {
  if Process.arguments.count > 1 {
      let mode = Process.arguments[1]

      if mode != "--cluster" {
          fatalError("Invalid mode")
      }

      // For Cluster app
      if Cluster.isMaster {
          logger.info("Cluster mode ready...")

          try pm.createWorkers()

          let usr2Signal = SignalWrap()

          //Should use Swift.enum
          usr2Signal.start(SIGUSR2) { _ in
              do {
                  logger.info("Got USR2 Signal............")
                  logger.info("Start to fork new children......")
                  try pm.gracefulRestart()
              } catch {
                  logger.fatal("\(error)")
                  exit(1)
              }
          }

          try Slimane().listen(port: PORT)
      } else {
          try launchApp()
      }
  } else {
      // for single thread app
      try launchApp()
  }
} catch {
    print(error)
    exit(1)
}
