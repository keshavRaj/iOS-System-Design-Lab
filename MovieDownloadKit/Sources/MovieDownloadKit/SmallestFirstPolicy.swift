//
//  SmallestFirstPolicy.swift
//  MovieDownloadKit
//
//  Created by Keshav Raj on 02/11/26.
//

public struct SmallestFirstPolicy: SchedulingPolicy {
    
    public init() { }
    
    public func selectNext(from candidates: [DownloadCandidate]) -> DownloadCandidate? {
        guard let first = candidates.first else { return nil }
        var smallestSize = first.sizeInBytes
        var smallestIndex = 0
        
        for (index, candidate) in candidates.enumerated() {
            if candidate.sizeInBytes < smallestSize {
                smallestSize = candidate.sizeInBytes
                smallestIndex = index
            }
        }
        return candidates[smallestIndex]
    }
}
