#if os(Linux)
    import Glibc
#else
    import Darwin.C
#endif


import Suv

private var workers = [Worker]()

struct PM {
    
    init(){}

    let cpus = OS.cpus()

    func observeWorker(_ worker: Worker){
        worker.onIPC { event in
            switch event {
            case .online:
                logger.info("Worker [\(worker.id)] is online")
            case .message(let message):
                logger.info("\(message)")
            case .exit(let status):
                logger.info("Worker [\(worker.id)] was exited with \(status)")
                if status > 0 {
                    do {
                        try self.createWorker()
                    } catch {
                        logger.fatal("Failed to spawn worker: \(error)")
                    }
                }
            default:
                break
            }
        }
    }

    func createWorkers() throws {
      for _ in 0..<cpus.count {
          try self.createWorker()
      }
    }

    func createWorker() throws {
        let worker = try Cluster.fork(silent: false)
        self.observeWorker(worker)
        workers.append(worker)
    }

    func gracefulRestart() throws {
        let oldWorkers = workers

        for _ in 0..<cpus.count {
            try self.createWorker()
        }

        Timer.timeout(timeout: 5000) {
            do {
                for worker in oldWorkers {
                    try worker.kill(PosixSignal.term.value)
                    if let index = workers.index(of: worker) {
                        workers.remove(at: index)
                    }
                }
                logger.info("Old workers are killed")
            } catch {
                logger.fatal("\(error)")
                exit(1)
            }
        }
    }
}
