import Suv

struct PM {

    private var workers = [Worker]()

    let cpus = OS.cpus()

    func observeWorker(_ worker: inout Worker){
        worker.on { event in
            switch event {
            case .online:
                logger.info("Worker [\(worker.id)] is online")
            case .message(let message):
                logger.info("\(message)")
            case .exit(let status):
                logger.info("Worker [\(worker.id)] was exited with \(status)")
                if status > 0 {
                    do {
                        worker = try Cluster.fork(silent: false)
                        self.observeWorker(&worker)
                    } catch {
                        logger.fatal("Failed to spawn worker: \(error)")
                    }
                }
            default:
                break
            }
        }
    }

    mutating func createWorkers() throws {
      for _ in 0..<cpus.count {
          try self.createWorker()
      }
    }

    mutating func createWorker() throws {
        var worker = try Cluster.fork(silent: false)
        self.observeWorker(&worker)
        self.workers.append(worker)
    }

    mutating func gracefulRestart() throws {
        let oldWorkers = self.workers

        for _ in 0..<cpus.count {
            try self.createWorker()
        }

        setTimeout(5000) {
            do {
                for worker in oldWorkers {
                    try worker.kill(SIGTERM)
                    if let index = self.workers.index(of: worker) {
                        self.workers.remove(at: index)
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
