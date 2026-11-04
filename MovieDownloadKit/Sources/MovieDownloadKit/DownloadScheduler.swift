//
//  DownloadScheduler.swift
//  MovieDownloadKit
//
//  Created by Keshav Raj on 03/11/26.
//

public actor DownloadScheduler {
    private let maxConcurrentDownloads: Int
    private let schedulerPolicy: any SchedulingPolicy
    
    private var reservedDownloads: Set<Int> = []
    private var waitingQueue: [DownloadCandidate] = []
    
    public init(maxConcurrentDownloads: Int,
         schedulerPolicy: any SchedulingPolicy) {
        self.maxConcurrentDownloads = maxConcurrentDownloads
        self.schedulerPolicy = schedulerPolicy
    }
    
    public func enqueue(_ candidate: DownloadCandidate) {
        if !reservedDownloads.contains(candidate.id) &&
            !waitingQueue.contains(where: { $0.id == candidate.id } ) {
            waitingQueue.append(candidate)
        }
    }
    
    public func scheduleNext() ->  DownloadCandidate? {
        guard let candidate = schedulerPolicy.selectNext(from: waitingQueue),
              tryReserve(candidate.id) else { return nil }
        waitingQueue.removeAll(where: {$0.id == candidate.id})
        return candidate
    }
    
    func tryReserve(_ id: Int) -> Bool {
        guard reservedDownloads.count < maxConcurrentDownloads &&
                !reservedDownloads.contains(id) else { return false }
        reservedDownloads.insert(id)
        return true
    }
    
    func release(_ id: Int) {
        reservedDownloads.remove(id)
    }
    
    public func queuedDownloadIds() -> [Int] {
        return waitingQueue.map { $0.id }
    }
}

