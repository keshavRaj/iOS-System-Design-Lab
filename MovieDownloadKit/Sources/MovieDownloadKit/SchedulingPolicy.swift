//
//  File.swift
//  MovieDownloadKit
//
//  Created by Keshav Raj on 02/11/26.
//

public protocol SchedulingPolicy {
    func selectNext(from candidates: [DownloadCandidate]) -> DownloadCandidate?
}
