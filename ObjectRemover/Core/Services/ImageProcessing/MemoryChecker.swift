//
//  MemoryChecker.swift
//  ObjectRemover
//
//  Utility for checking available memory and determining
//  if an image can be processed at full resolution.
//

import Foundation
import UIKit

enum OperationType {
    case objectRemoval
    case cloneStamp
    case simple

    var memoryMultiplier: CGFloat {
        switch self {
        case .objectRemoval: return 4.0  // Original + mask + processed + working buffer
        case .cloneStamp: return 2.5     // Original + working buffer
        case .simple: return 2.0         // Original + output
        }
    }
}

final class MemoryChecker {

    // MARK: - Constants

    private static let bytesPerPixel: Int = 4  // RGBA
    private static let safetyMarginMB: Double = 100  // Keep 100MB free

    // MARK: - Public Methods

    /// Check if an image of given size can be processed
    static func canProcess(
        imageSize: CGSize,
        operationType: OperationType = .objectRemoval
    ) -> MemoryCheckResult {
        let availableMemory = getAvailableMemoryMB()
        let requiredMemory = estimateRequiredMemory(for: imageSize, operation: operationType)

        let canProcess = availableMemory > (requiredMemory + safetyMarginMB)

        let recommendedScale: CGFloat
        if canProcess {
            recommendedScale = 1.0
        } else {
            let targetMemory = max(0, availableMemory - safetyMarginMB)
            let scaleFactor = sqrt(targetMemory / requiredMemory)
            recommendedScale = max(0.25, min(1.0, scaleFactor))
        }

        return MemoryCheckResult(
            canProcess: canProcess,
            availableMemoryMB: availableMemory,
            requiredMemoryMB: requiredMemory,
            recommendedScale: recommendedScale
        )
    }

    /// Get available memory in megabytes
    static func getAvailableMemoryMB() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size) / 4

        let result = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_, task_flavor_t(MACH_TASK_BASIC_INFO), $0, &count)
            }
        }

        guard result == KERN_SUCCESS else {
            // Fallback to a conservative estimate
            return 500
        }

        let usedMemory = Double(info.resident_size) / 1024 / 1024
        let totalMemory = Double(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024

        // iOS typically allows apps to use ~50% of physical memory
        let appLimit = totalMemory * 0.5

        return max(0, appLimit - usedMemory)
    }

    /// Estimate memory required for processing an image
    static func estimateRequiredMemory(
        for size: CGSize,
        operation: OperationType
    ) -> Double {
        let pixels = size.width * size.height
        let baseMemoryBytes = pixels * CGFloat(bytesPerPixel)
        let totalBytes = baseMemoryBytes * operation.memoryMultiplier

        return Double(totalBytes) / 1024 / 1024
    }

    /// Get memory pressure level
    static func getMemoryPressureLevel() -> MemoryPressureLevel {
        let available = getAvailableMemoryMB()
        let total = Double(ProcessInfo.processInfo.physicalMemory) / 1024 / 1024

        let ratio = available / total

        if ratio > 0.3 {
            return .normal
        } else if ratio > 0.15 {
            return .warning
        } else {
            return .critical
        }
    }
}

// MARK: - Memory Pressure Level

enum MemoryPressureLevel {
    case normal
    case warning
    case critical

    var description: String {
        switch self {
        case .normal: return "Normal"
        case .warning: return "Low Memory"
        case .critical: return "Critical"
        }
    }
}
