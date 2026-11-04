//
//  SmallestFirstPolicyTests.swift
//  MovieDownloadKit
//
//  Created by Keshav Raj on 02/11/26.
//

import XCTest
@testable import MovieDownloadKit

final class SmallestFirstPolicyTests: XCTestCase {
    
    func test_givenDownloadCandidates_selectSmallestSizeCandidate() throws {
        let sut = SmallestFirstPolicy()
        let candidates = [
            DownloadCandidate(id: 1, sizeInBytes: 500, priority: 1),
            DownloadCandidate(id: 2, sizeInBytes: 200, priority: 1),
            DownloadCandidate(id: 3, sizeInBytes: 800, priority: 1)
        ]
        let next = sut.selectNext(from: candidates)
        
        let selected = try XCTUnwrap(next)
        XCTAssertEqual(2, selected.id)
    }
    
    func test_givenEmptyDownloadCandidates_returnsNil() {
        let sut = SmallestFirstPolicy()
        let candidates:[DownloadCandidate] = []
        let next = sut.selectNext(from: candidates)
        XCTAssertNil(next)
    }
    
    func test_givenSameSmallestSize_selectsFirstCandidate() throws {
        let sut = SmallestFirstPolicy()
        let candidates = [
            DownloadCandidate(id: 1, sizeInBytes: 200, priority: 1),
            DownloadCandidate(id: 2, sizeInBytes: 200, priority: 1),
            DownloadCandidate(id: 3, sizeInBytes: 800, priority: 1)
        ]
        
        let next = sut.selectNext(from: candidates)
        
        let selected = try XCTUnwrap(next)
        
        XCTAssertEqual(1, selected.id)
    }
}
