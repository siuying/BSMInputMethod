# Package database builder as a SwiftPM CLI target

The Swift replacement for the Ruby preprocessing scripts will be a Swift Package Manager command-line target. SQLite.swift is an accepted dependency for the database path, and the builder can use it to create the preserved `ime` SQLite schema and populate the bundled database while remaining separate from the input method app target.
