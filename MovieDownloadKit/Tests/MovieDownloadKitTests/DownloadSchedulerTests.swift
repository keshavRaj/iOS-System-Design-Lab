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
    
    override func setUp() {
        super.setUp()
        sut = DownloadScheduler(maxConcurrentDownloads: 3, schedulerPolicy: SmallestFirstPolicy())
    }

    func test_whenEnquedDownloads_addsItToQueueInOrder() async {
        let candidate1 = DownloadCandidate(id: 1, sizeInBytes: 800, priority: 1)
        let candidate2 = DownloadCandidate(id: 2, sizeInBytes: 600, priority: 2)
        
        await sut.enqueue(candidate1)
        await sut.enqueue(candidate2)
        
        let queuedIds = await sut.queuedDownloadIds()
        
        XCTAssertEqual([1,2], queuedIds)
    }
    
    func test_whenEnqueDuplicate_doesNotAddToQueue() async {
        let candidate = DownloadCandidate(id: 1, sizeInBytes: 800, priority: 1)
        
        await sut.enqueue(candidate)
        await sut.enqueue(candidate)
        
        let queuedIds = await sut.queuedDownloadIds()
        
        XCTAssertEqual([1], queuedIds)
    }
    
    func test_whenReserveSlotOfNewId_reservesSlot() async {
        let isReserved = await sut.tryReserve(1)
        
        XCTAssertTrue(isReserved)
    }
    
    func test_whenReserveSlotOfReservedId_doesNotReserveSlot() async {
        _ = await sut.tryReserve(1)
        let isReserved = await sut.tryReserve(1)
        
        XCTAssertFalse(isReserved)
    }
    
    func test_whenReserveSlot_maxLimitReached_doesNotReserveSlot() async {
        let first = await sut.tryReserve(1)
        let second = await sut.tryReserve(2)
        let third = await sut.tryReserve(3)
        let isReserved = await sut.tryReserve(4)
        
        XCTAssertTrue(first)
        XCTAssertTrue(second)
        XCTAssertTrue(third)
        XCTAssertFalse(isReserved)
    }
    
    func test_whenReleaseSlot_releasesSlot() async {
        let first = await sut.tryReserve(1)
        let second = await sut.tryReserve(2)
        let third = await sut.tryReserve(3)
        await sut.release(3)
        let firstAgain = await sut.tryReserve(1)
        let secondAgain = await sut.tryReserve(2)
        let fourth = await sut.tryReserve(4)
        
        XCTAssertTrue(first)
        XCTAssertTrue(second)
        XCTAssertTrue(third)
        XCTAssertTrue(fourth)
        XCTAssertFalse(firstAgain)
        XCTAssertFalse(secondAgain)
    }
    
    func test_whenScheduleNext_selectsNextFromPolicy_reserveSlot_removeFromEnqueued() async {
        let candidate1 = DownloadCandidate(id: 1, sizeInBytes: 800, priority: 1)
        let candidate2 = DownloadCandidate(id: 2, sizeInBytes: 600, priority: 1)
        let candidate3 = DownloadCandidate(id: 3, sizeInBytes: 200, priority: 1)
        
        await sut.enqueue(candidate1)
        await sut.enqueue(candidate2)
        await sut.enqueue(candidate3)
        
        let downloadCandidate = await sut.scheduleNext()
        let queued = await sut.queuedDownloadIds()
        let reservedAgain = await sut.tryReserve(3)
        
        XCTAssertEqual(3, downloadCandidate?.id)
        XCTAssertEqual([1,2], queued)
        XCTAssertFalse(reservedAgain)
    }
    
    func test_scheduleNext_atCapacity_preservesWaitingQueue() async {
        let candidate1 = DownloadCandidate(id: 1, sizeInBytes: 800, priority: 1)
        let candidate2 = DownloadCandidate(id: 2, sizeInBytes: 600, priority: 1)
        let candidate3 = DownloadCandidate(id: 3, sizeInBytes: 200, priority: 1)
        let candidate4 = DownloadCandidate(id: 4, sizeInBytes: 300, priority: 1)
        let candidate5 = DownloadCandidate(id: 5, sizeInBytes: 7200, priority: 1)
        
        await sut.enqueue(candidate1)
        await sut.enqueue(candidate2)
        await sut.enqueue(candidate3)
        await sut.enqueue(candidate4)
        await sut.enqueue(candidate5)
        
        let first = await sut.scheduleNext()
        let second = await sut.scheduleNext()
        let third = await sut.scheduleNext()
        let fourth = await sut.scheduleNext()
        let queuedIds = await sut.queuedDownloadIds()
        
        XCTAssertEqual(3, first?.id)
        XCTAssertEqual(4, second?.id)
        XCTAssertEqual(2, third?.id)
        XCTAssertNil(fourth)
        XCTAssertEqual([1,5], queuedIds)
    }
    
    override func tearDown() {
        super.tearDown()
        sut = nil
    }
}
