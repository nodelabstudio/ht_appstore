//
//  ChallengeWidget.swift
//  ChallengeWidget
//
//  Created by Angel Rodriguez on 1/27/26.
//

import WidgetKit
import SwiftUI

struct ChallengeEntry: TimelineEntry {
    let date: Date
    let challengeName: String
    let streakCount: Int
    let isCompletedToday: Bool
    let progressPercent: Double
    let challengeId: String
    let packEmoji: String
}

struct ChallengeProvider: TimelineProvider {
    // App Group ID for shared UserDefaults with Flutter app
    let userDefaults = UserDefaults(suiteName: "group.com.challengetracker.shared")

    func placeholder(in context: Context) -> ChallengeEntry {
        ChallengeEntry(
            date: Date(),
            challengeName: "No Sugar 30",
            streakCount: 7,
            isCompletedToday: false,
            progressPercent: 0.23,
            challengeId: "",
            packEmoji: "🍬"
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (ChallengeEntry) -> Void) {
        completion(readEntry())
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<ChallengeEntry>) -> Void) {
        let entry = readEntry()
        // Refresh at midnight to update completion status for new day
        let midnight = Calendar.current.startOfDay(for: Date()).addingTimeInterval(86400)
        let timeline = Timeline(entries: [entry], policy: .after(midnight))
        completion(timeline)
    }

    private func readEntry() -> ChallengeEntry {
        return ChallengeEntry(
            date: Date(),
            challengeName: userDefaults?.string(forKey: "challenge_name") ?? "Add a Challenge",
            streakCount: userDefaults?.integer(forKey: "streak_count") ?? 0,
            isCompletedToday: userDefaults?.bool(forKey: "is_completed_today") ?? false,
            progressPercent: userDefaults?.double(forKey: "progress_percent") ?? 0,
            challengeId: userDefaults?.string(forKey: "challenge_id") ?? "",
            packEmoji: userDefaults?.string(forKey: "pack_emoji") ?? "🎯"
        )
    }
}

struct ChallengeWidgetEntryView: View {
    var entry: ChallengeProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .systemSmall:
            smallWidget
        case .systemMedium:
            mediumWidget
        default:
            smallWidget
        }
    }

    var smallWidget: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.packEmoji)
                .font(.title)

            Text(entry.challengeName)
                .font(.headline)
                .lineLimit(2)
                .minimumScaleFactor(0.8)

            Spacer()

            HStack {
                Image(systemName: "flame.fill")
                    .foregroundColor(entry.streakCount > 0 ? .orange : .gray)
                Text("\(entry.streakCount)")
                    .font(.title2)
                    .fontWeight(.bold)
            }

            if entry.isCompletedToday {
                Label("Done", systemImage: "checkmark.circle.fill")
                    .font(.caption)
                    .foregroundColor(.green)
            } else if !entry.challengeId.isEmpty {
                Text("Tap to complete")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .widgetURL(URL(string: "challengetracker://challenge/\(entry.challengeId)"))
    }

    var mediumWidget: some View {
        HStack {
            // Left side - emoji and name
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.packEmoji)
                    .font(.largeTitle)

                Text(entry.challengeName)
                    .font(.headline)
                    .lineLimit(2)

                if entry.isCompletedToday {
                    Label("Completed Today", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                } else if !entry.challengeId.isEmpty {
                    Text("Tap to complete")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            // Right side - streak and progress
            VStack(alignment: .trailing, spacing: 8) {
                HStack {
                    Image(systemName: "flame.fill")
                        .foregroundColor(entry.streakCount > 0 ? .orange : .gray)
                    Text("\(entry.streakCount)")
                        .font(.title)
                        .fontWeight(.bold)
                }

                Text("Day \(Int(entry.progressPercent * 30))/30")
                    .font(.caption)
                    .foregroundColor(.secondary)

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.gray.opacity(0.3))
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.blue)
                            .frame(width: geo.size.width * entry.progressPercent)
                    }
                }
                .frame(width: 80, height: 8)
            }
        }
        .padding()
        .widgetURL(URL(string: "challengetracker://challenge/\(entry.challengeId)"))
    }
}

struct ChallengeWidget: Widget {
    let kind: String = "ChallengeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: ChallengeProvider()) { entry in
            if #available(iOS 17.0, *) {
                ChallengeWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else if #available(iOS 15.0, *) {
                ChallengeWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            } else {
                ChallengeWidgetEntryView(entry: entry)
                    .padding()
            }
        }
        .configurationDisplayName("Challenge Tracker")
        .description("Track your daily challenge progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    ChallengeWidget()
} timeline: {
    ChallengeEntry(date: Date(), challengeName: "No Sugar 30", streakCount: 7, isCompletedToday: false, progressPercent: 0.23, challengeId: "123", packEmoji: "🍬")
    ChallengeEntry(date: Date(), challengeName: "No Sugar 30", streakCount: 8, isCompletedToday: true, progressPercent: 0.27, challengeId: "123", packEmoji: "🍬")
}

@available(iOS 17.0, *)
#Preview(as: .systemMedium) {
    ChallengeWidget()
} timeline: {
    ChallengeEntry(date: Date(), challengeName: "No Sugar 30", streakCount: 7, isCompletedToday: false, progressPercent: 0.23, challengeId: "123", packEmoji: "🍬")
    ChallengeEntry(date: Date(), challengeName: "No Sugar 30", streakCount: 8, isCompletedToday: true, progressPercent: 0.27, challengeId: "123", packEmoji: "🍬")
}
