//
//  DownloadSchedulerTests.swift
//  MovieDownloadKit
//
//  Created by Keshav Raj on 03/11/26.
//

import XCTest
@testable import MovieDownloadKit

final class DownloadSchedulerTests: XCTestCase {
    private var sut: DownloadScheduler!
    private var downloadCandidates: [DownloadCandidate]!
    
    override func setUp() {
        super.setUp()
        sut = DownloadScheduler(maxConcurrentDownloads: 3, schedulerPolicy: SmallestFirstPolicy())
        downloadCandidates = [DownloadCandidate(id: 1, sizeInBytes: 800, priority: 1),
                              DownloadCandidate(id: 2, sizeInBytes: 600, priority: 1),
                              DownloadCandidate(id: 3, sizeInBytes: 200, priority: 1),
                              DownloadCandidate(id: 4, sizeInBytes: 300, priority: 1),
                              DownloadCandidate(id: 5, sizeInBytes: 7200, priority: 1)]
    }
    
    func test_enqueue_schedulesCandidatesUsingPolicy() async {
        let reserved = await sut.enqueue(downloadCandidates)
        let reservedIds = reserved.map { $0.id }
        let queuedIds = await sut.queuedDownloadIds()
        
        XCTAssertEqual([3,4,2], reservedIds)
        XCTAssertEqual([1,5], queuedIds)
    }
    
    func test_enqueue_ignoresAlreadyReservedCandidates() async {
        _ = await sut.enqueue(downloadCandidates)
        let duplicateReserve = await sut.enqueue([downloadCandidates[1]])
        let queuedAfterDuplicate = await sut.queuedDownloadIds()
        
        XCTAssertEqual(0, duplicateReserve.count)
        XCTAssertEqual([1,5], queuedAfterDuplicate)
    }
    
    func test_enqueue_ignoresAlreadyQueuedCandidates()  async {
        _ = await sut.enqueue(downloadCandidates)
        let duplicateQueued = await sut.enqueue([downloadCandidates[0]])
        let queuedAfterDuplicate = await sut.queuedDownloadIds()
        
        XCTAssertEqual(0, duplicateQueued.count)
        XCTAssertEqual([1,5], queuedAfterDuplicate)
    }

    override func tearDown() {
        super.tearDown()
        sut = nil
        downloadCandidates = nil
    }
}
